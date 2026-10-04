// Bumps every formula to the newest upstream release and refreshes its sha256.
//
// Run with Bun: `bun run .github/scripts/update-formula.ts`
//
// Two resolution strategies, because release tags lie. A formula that downloads
// a release asset is matched by asset name across recent releases, since a
// project's newest tag is often a build (a Brave nightly, say) that never ships
// that asset. Anything else falls back to the newest `vX.Y.Z` git tag. The
// highest version wins either way: projects back-publish patch releases, so a
// release published yesterday can carry a lower version than today's.

import { readdirSync, readFileSync, writeFileSync } from "node:fs";

const FORMULA_DIR = "Formula";
const RELEASE_PAGES = 5;
const RELEASES_PER_PAGE = 100;
const SUMMARY_FILE = "/tmp/updated.txt";

const warnings: string[] = [];
const notices: string[] = [];
const summary: string[] = [];

function warn(message: string): void {
  warnings.push(message);
  console.log(`::warning::${message}`);
}

function notice(message: string): void {
  notices.push(message);
  console.log(`::notice::${message}`);
}

const VERSIONED_URL = (version: string) => new RegExp(`v${version}|_${version}_`);
const GITHUB_SLUG = /https:\/\/github\.com\/([^/"]+\/[^/"]+)/;

function escapeForRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function firstMatch(source: string, pattern: RegExp): string | null {
  return pattern.exec(source)?.[1] ?? null;
}

// Newest version that actually ships `assetName`, whose current version is
// `current`. Returns null when nothing in the recent releases matches.
async function newestAssetVersion(
  repo: string,
  assetName: string,
  current: string,
): Promise<string | null> {
  const prefix = assetName.slice(0, assetName.indexOf(current));
  const suffix = assetName.slice(assetName.indexOf(current) + current.length);
  const pattern = new RegExp(`^${escapeForRegExp(prefix)}(\\d+\\.\\d+\\.\\d+)${escapeForRegExp(suffix)}$`);
  const token = process.env.GH_TOKEN;

  for (let page = 1; page <= RELEASE_PAGES; page += 1) {
    const url = `https://api.github.com/repos/${repo}/releases?per_page=${RELEASES_PER_PAGE}&page=${page}`;
    const headers: Record<string, string> = { Accept: "application/vnd.github+json" };
    if (token) headers.Authorization = `Bearer ${token}`;

    let releases: { assets?: { name?: string }[] }[];
    try {
      const response = await fetch(url, { headers });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      releases = await response.json();
    } catch (error) {
      throw new Error(`release lookup for ${repo} failed: ${(error as Error).message}`);
    }
    if (releases.length === 0) return null;

    const versions = releases.flatMap((release) =>
      (release.assets ?? [])
        .map((asset) => pattern.exec(asset.name ?? ""))
        .filter((match): match is RegExpExecArray => match !== null)
        .map((match) => match[1]),
    );
    // One page of hits is enough in practice; scanning further only costs quota.
    if (versions.length > 0) {
      return versions.reduce((best, version) =>
        version.localeCompare(best, undefined, { numeric: true }) > 0 ? version : best,
      );
    }
  }
  return null;
}

// Newest `vX.Y.Z` tag, for formulas that download a source archive.
async function newestTag(repo: string): Promise<string | null> {
  const child = Bun.spawn(
    ["git", "-c", "credential.helper=", "ls-remote", "--tags", `https://github.com/${repo}.git`],
    { stdout: "pipe", stderr: "ignore" },
  );
  const output = await new Response(child.stdout).text();
  if ((await child.exited) !== 0) return null;

  const tags = output
    .split("\n")
    .map((line) => line.split("/").pop() ?? "")
    .filter((tag) => /^v\d+\.\d+\.\d+$/.test(tag))
    .map((tag) => tag.slice(1));
  if (tags.length === 0) return null;
  return tags.reduce((best, tag) =>
    tag.localeCompare(best, undefined, { numeric: true }) > 0 ? tag : best,
  );
}

async function sha256(url: string): Promise<string | null> {
  try {
    const response = await fetch(url, { redirect: "follow" });
    if (!response.ok || !response.body) return null;
    const hasher = new Bun.CryptoHasher("sha256");
    for await (const chunk of response.body) hasher.update(chunk);
    return hasher.digest("hex");
  } catch {
    return null;
  }
}

// Refetches every versioned url and rewrites the sha256 on the following line.
async function refreshChecksums(source: string, latest: string): Promise<string> {
  const lines = source.split("\n");
  const versioned = VERSIONED_URL(latest);

  for (let i = 0; i < lines.length; i += 1) {
    const url = firstMatch(lines[i], /^\s*url "([^"]+)"/);
    if (url === null || !versioned.test(url)) continue;

    const offset = lines.slice(i + 1).findIndex((line) => /sha256 "/.test(line));
    if (offset === -1) {
      warn(`no sha256 line follows ${url}`);
      continue;
    }

    console.log(`Fetching ${url} ...`);
    const sha = await sha256(url);
    if (sha === null) {
      warn(`Failed to fetch ${url}`);
      continue;
    }
    console.log(`  sha256 ${sha}`);

    const shaIndex = i + 1 + offset;
    lines[shaIndex] = lines[shaIndex].replace(/sha256 "[a-f0-9]*"/, `sha256 "${sha}"`);
  }
  return lines.join("\n");
}

async function updateFormula(path: string): Promise<void> {
  const original = readFileSync(path, "utf8");

  const downloadUrl = firstMatch(original, /^\s*url "([^"]+)"/m);
  const homepage = firstMatch(original, /homepage "([^"]+)"/);
  const repo =
    GITHUB_SLUG.exec(homepage ?? "")?.[1] ??
    GITHUB_SLUG.exec(downloadUrl ?? "")?.[1] ??
    null;

  const current =
    firstMatch(original, /version "(\d+\.\d+\.\d+)"/) ??
    firstMatch(original, /tags\/v(\d+\.\d+\.\d+)/) ??
    firstMatch(original, /releases\/download\/v(\d+\.\d+\.\d+)/);
  if (current === null) {
    warn(`${path}: could not determine current version`);
    return;
  }

  let latest: string | null = null;
  const asset = downloadUrl === null ? "" : downloadUrl.split("/").pop() ?? "";
  if (repo !== null && downloadUrl?.includes("/releases/download/") && asset.includes(current)) {
    latest = await newestAssetVersion(repo, asset, current);
    if (latest === null) warn(`${path}: no release asset matching ${asset}`);
  } else if (repo !== null) {
    latest = await newestTag(repo);
    if (latest === null) warn(`${path}: could not determine latest for ${repo}`);
  } else {
    warn(`${path}: could not determine git repository URL`);
  }
  if (latest === null) return;

  notice(`${path}: current=${current} latest=${latest}`);
  if (latest === current) return;

  let updated = original.replace(/version "\d+\.\d+\.\d+"/g, `version "${latest}"`);
  const carried = new RegExp(escapeForRegExp(current), "g");
  updated = updated
    .split("\n")
    .map((line) => (/^\s*(url|head) "/.test(line) ? line.replace(carried, latest) : line))
    .join("\n");

  updated = await refreshChecksums(updated, latest);

  if (updated === original) return;
  writeFileSync(path, updated);
  summary.push(`${path}: v${current} -> v${latest}`);
}

async function main(): Promise<void> {
  const formulas = readdirSync(FORMULA_DIR)
    .filter((name) => name.endsWith(".rb"))
    .sort()
    .map((name) => `${FORMULA_DIR}/${name}`);

  for (const formula of formulas) {
    try {
      await updateFormula(formula);
    } catch (error) {
      warn(`${formula}: ${(error as Error).message}`);
    }
  }

  console.log(`checked ${formulas.length} formulas, ${notices.length} notices, ${warnings.length} warnings`);
  if (summary.length === 0) return;

  if (Bun.env.GITHUB_OUTPUT !== undefined) {
    await Bun.write(Bun.env.GITHUB_OUTPUT, "updated=true\n");
  }
  await Bun.write(SUMMARY_FILE, `${summary.join("\n")}\n`);
  console.log(summary.join("\n"));
}

await main();