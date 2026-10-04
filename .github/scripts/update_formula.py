#!/usr/bin/env python3
"""Bumps every formula to the newest upstream release and refreshes its sha256.

Run: python3 .github/scripts/update_formula.py

Standard library only, so the runner needs no setup step: it already ships
Python 3.

Two resolution strategies, because release tags lie. A formula that downloads
a release asset is matched by asset name across recent releases, since a
project's newest tag is often a build (a Brave nightly, say) that never ships
that asset. Anything else falls back to the newest ``vX.Y.Z`` git tag. The
highest version wins either way: projects back-publish patch releases, so a
release published yesterday can carry a lower version than today's.

Formulae are checked concurrently, capped at CONCURRENCY: a bump run downloads
several hundred megabytes of archives to hash, and doing that one formula at a
time is most of the runtime. The cap keeps the GitHub API from seeing a burst
and keeps parallel archive downloads from saturating memory. Results are sorted
before printing, so the log and the commit summary stay identical to a
sequential run.
"""

import concurrent.futures
import hashlib
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

FORMULA_DIR = "Formula"
CONCURRENCY = 4
# A page of releases is megabytes of JSON and the match is almost always on
# the first page, so ask for a small page and scan further instead. Deep
# scanning only happens when an asset has gone missing upstream.
RELEASES_PER_PAGE = 30
RELEASE_PAGES = 10
SUMMARY_FILE = "/tmp/updated.txt"

GITHUB_SLUG = re.compile(r'https://github\.com/([^/"]+/[^/"]+)')
URL_LINE = re.compile(r'^\s*url "([^"]+)"', re.MULTILINE)
CURRENT_VERSION = re.compile(r'version "(\d+\.\d+\.\d+)"')
TAG_VERSION = re.compile(r"tags/v(\d+\.\d+\.\d+)")
DOWNLOAD_VERSION = re.compile(r"releases/download/v(\d+\.\d+\.\d+)")
VERSION_LINE = re.compile(r"^\s*(url|head) \"")
SHA256_LINE = re.compile(r'sha256 "[a-f0-9]*"')
TAG = re.compile(r"^v\d+\.\d+\.\d+$")

RELEASE_CACHE: dict[tuple[str, int], list] = {}


@dataclass
class Result:
    """What checking one formula produced."""

    path: str
    notices: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    summary: str | None = None


def highest(versions: list[str]) -> str | None:
    """Newest dotted version; numeric, so 1.99.9 beats 1.9.10."""
    return max(versions, key=lambda value: [int(part) for part in value.split(".")], default=None)


def newest_asset_version(repo: str, asset_name: str, current: str) -> str | None:
    """Newest version that actually ships ``asset_name``, or None.

    One page of hits is enough in practice; scanning further only costs quota.
    """
    prefix, _, suffix = asset_name.partition(current)
    pattern = re.compile(rf"^{re.escape(prefix)}(\d+\.\d+\.\d+){re.escape(suffix)}$")
    headers = {"Accept": "application/vnd.github+json"}
    token = os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"

    for page in range(1, RELEASE_PAGES + 1):
        releases = RELEASE_CACHE.get((repo, page))
        if releases is None:
            url = (
                f"https://api.github.com/repos/{repo}/releases"
                f"?per_page={RELEASES_PER_PAGE}&page={page}"
            )
            try:
                with urllib.request.urlopen(urllib.request.Request(url, headers=headers)) as response:
                    releases = json.loads(response.read())
            except (urllib.error.URLError, json.JSONDecodeError) as error:
                raise RuntimeError(f"release lookup for {repo} failed: {error}") from error
            # One page of releases is around ten megabytes of JSON, and the
            # Brave formulae all read the same repository's page.
            RELEASE_CACHE[(repo, page)] = releases
        if not releases:
            return None
        versions = [
            match.group(1)
            for release in releases
            for asset in release.get("assets") or []
            if (match := pattern.fullmatch(asset.get("name") or ""))
        ]
        best = highest(versions)
        if best is not None:
            return best
    return None


def newest_tag(repo: str) -> str | None:
    """Newest ``vX.Y.Z`` tag, for formulas that download a source archive."""
    try:
        remote = subprocess.run(
            ["git", "-c", "credential.helper=", "ls-remote", "--tags", f"https://github.com/{repo}.git"],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return None
    if remote.returncode != 0:
        return None

    tags = [
        line.rsplit("/", 1)[-1][1:]
        for line in remote.stdout.splitlines()
        if TAG.fullmatch(line.rsplit("/", 1)[-1])
    ]
    return highest(tags)


def sha256(url: str) -> str | None:
    """sha256 of a URL, hashed as it streams; None if it cannot be fetched."""
    try:
        with urllib.request.urlopen(url) as response:
            return hashlib.file_digest(response, "sha256").hexdigest()
    except (urllib.error.URLError, OSError):
        return None


def refresh_checksums(source: str, latest: str, warnings: list[str]) -> str:
    """Refetch every versioned url and rewrite the sha256 on the line below it.

    A formula can carry several (one per architecture), so these run together.
    """
    lines = source.split("\n")
    versioned = re.compile(rf"v{re.escape(latest)}|_{re.escape(latest)}_")

    targets = []
    for index, line in enumerate(lines):
        url = URL_LINE.match(line)
        if url is None or not versioned.search(url.group(1)):
            continue
        offset = next((i for i, entry in enumerate(lines[index + 1 :]) if SHA256_LINE.search(entry)), None)
        if offset is None:
            warnings.append(f"no sha256 line follows {url.group(1)}")
            continue
        targets.append((url.group(1), index + 1 + offset))

    def fetch(target: tuple[str, int]) -> tuple[int, str] | None:
        url, sha_index = target
        print(f"Fetching {url} ...")
        checksum = sha256(url)
        if checksum is None:
            warnings.append(f"Failed to fetch {url}")
            return None
        print(f"  sha256 {checksum}")
        return sha_index, checksum

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(targets) or 1) as pool:
        checksums = [check for check in pool.map(fetch, targets) if check is not None]

    for sha_index, checksum in checksums:
        lines[sha_index] = SHA256_LINE.sub(f'sha256 "{checksum}"', lines[sha_index])
    return "\n".join(lines)


def update_formula(path: str) -> Result:
    """Check one formula and rewrite it if upstream moved.

    Never raises: a formula that cannot be checked is reported, not fatal.
    """
    result = Result(path=path)
    original = Path(path).read_text()

    try:
        download_url = URL_LINE.search(original)
        homepage = re.search(r'homepage "([^"]+)"', original)
        repo = None
        for candidate in (homepage.group(1) if homepage else None, download_url.group(1) if download_url else None):
            if candidate and (match := GITHUB_SLUG.search(candidate)):
                repo = match.group(1)
                break

        current = None
        for pattern in (CURRENT_VERSION, TAG_VERSION, DOWNLOAD_VERSION):
            if match := pattern.search(original):
                current = match.group(1)
                break
        if current is None:
            result.warnings.append(f"{path}: could not determine current version")
            return result

        asset = download_url.group(1).rsplit("/", 1)[-1] if download_url else ""
        latest = None
        if repo and download_url and "/releases/download/" in download_url.group(1) and current in asset:
            latest = newest_asset_version(repo, asset, current)
            if latest is None:
                result.warnings.append(f"{path}: no release asset matching {asset}")
        elif repo:
            latest = newest_tag(repo)
            if latest is None:
                result.warnings.append(f"{path}: could not determine latest for {repo}")
        else:
            result.warnings.append(f"{path}: could not determine git repository URL")
        if latest is None:
            return result

        result.notices.append(f"{path}: current={current} latest={latest}")
        if latest == current:
            return result

        updated = CURRENT_VERSION.sub(f'version "{latest}"', original)
        carried = re.compile(re.escape(current))
        updated = "\n".join(
            carried.sub(latest, line) if VERSION_LINE.match(line) else line for line in updated.split("\n")
        )
        updated = refresh_checksums(updated, latest, result.warnings)

        if updated != original:
            Path(path).write_text(updated)
            result.summary = f"{path}: v{current} -> v{latest}"
    except Exception as error:  # noqa: BLE001 - one bad formula must not stop the rest
        result.warnings.append(f"{path}: {error}")
    return result


def main() -> None:
    formulas = sorted(str(path) for path in Path(FORMULA_DIR).glob("*.rb"))
    with concurrent.futures.ThreadPoolExecutor(max_workers=CONCURRENCY) as pool:
        results = sorted(pool.map(update_formula, formulas), key=lambda result: result.path)

    for result in results:
        for message in result.notices:
            print(f"::notice::{message}")
        for message in result.warnings:
            print(f"::warning::{message}")

    notices = sum(len(result.notices) for result in results)
    warnings = sum(len(result.warnings) for result in results)
    print(f"checked {len(formulas)} formulas, {notices} notices, {warnings} warnings")

    changed = [result.summary for result in results if result.summary is not None]
    if not changed:
        return

    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output is not None:
        Path(github_output).write_text("updated=true\n")
    Path(SUMMARY_FILE).write_text("\n".join(changed) + "\n")
    print("\n".join(changed))


if __name__ == "__main__":
    sys.exit(main())