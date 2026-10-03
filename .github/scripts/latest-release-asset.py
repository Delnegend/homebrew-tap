#!/usr/bin/env python3
"""Print the newest version of a GitHub release asset a formula downloads.

Usage: latest-release-asset.py OWNER/REPO ASSET_NAME CURRENT_VERSION

Release tags are not always the version a formula tracks: Brave tags nightly and
beta builds with the same plain semantic tags as its stable release, so the
newest tag points at a build that has no stable asset at all. Matching the asset
name a formula already downloads picks the channel that formula actually tracks.

Exits 1 with a message on stderr when no matching asset is found.
"""

import json
import os
import re
import sys
import urllib.error
import urllib.request

PER_PAGE = 100
PAGES = 5


def fetch(url: str) -> list:
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "homebrew-tap"}
    token = os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request) as response:
        return json.load(response)

def newest_version(repo: str, pattern: re.Pattern) -> str | None:
    newest = None
    for page in range(1, PAGES + 1):
        url = f"https://api.github.com/repos/{repo}/releases?per_page={PER_PAGE}&page={page}"
        releases = fetch(url)
        if not releases:
            break
        for release in releases:
            for asset in release.get("assets", []):
                match = pattern.fullmatch(asset.get("name", ""))
                if not match:
                    continue
                version = match.group(1)
                # Not the first match in page order: releases are listed by
                # date, and a back-published patch release (Brave shipped
                # 1.96.61 a day after 1.97.53) can sort ahead of a higher
                # version.
                key = tuple(int(part) for part in version.split("."))
                if newest is None or key > newest[0]:
                    newest = (key, version)
        if newest is not None:
            break
    return newest[1] if newest else None


def main() -> int:
    if len(sys.argv) != 4:
        print(__doc__, file=sys.stderr)
        return 2
    repo, asset_name, current = sys.argv[1:]
    if current not in asset_name:
        print(f"current version {current} not in asset name {asset_name}", file=sys.stderr)
        return 2
    prefix, _, suffix = asset_name.partition(current)
    pattern = re.compile(rf"{re.escape(prefix)}([0-9]+\.[0-9]+\.[0-9]+){re.escape(suffix)}")

    try:
        version = newest_version(repo, pattern)
    except (urllib.error.HTTPError, json.JSONDecodeError) as error:
        print(f"release lookup for {repo} failed: {error}", file=sys.stderr)
        return 1
    if version is None:
        print(f"no release of {repo} in the last {PAGES * PER_PAGE} has an asset like {asset_name}", file=sys.stderr)
        return 1
    print(version)
    return 0


if __name__ == "__main__":
    sys.exit(main())
