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
//
// Formulae are checked concurrently, capped at CONCURRENCY: a bump run
// downloads several hundred megabytes of archives to hash, and doing that one
// formula at a time is most of the runtime. The cap keeps the GitHub API from
// seeing a burst and keeps parallel archive downloads from saturating memory.
// Results are sorted before printing so the log and the commit summary stay
// identical to a sequential run.

import { readdirSync, readFileSync, writeFileSync } from "node:fs";

const FORMULA_DIR = "Formula";
const RELEASE_PAGES = 5;
const RELEASES_PER_PAGE = 100;
const CONCURRENCY = 4;
const SUMMARY_FILE = "/tmp/updated.txt";

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

interface Result {
  path: string;
  notices: string[];
  warnings: string[];
  summary: string | null;
}

// Refetches every versioned url and rewrites the sha256 on the following line.
// A formula can carry several (one per architecture), so these run together.
async function refreshChecksums(
  source: string,
  latest: string,
  warnings: string[],
): Promise<string> {
  const lines = source.split("\n");
  const versioned = VERSIONED_URL(latest);

  const targets = lines.flatMap((line, index) => {
    const url = firstMatch(line, /^\s*url "([^"]+)"/);
    if (url === null || !versioned.test(url)) return [];

    const offset = lines.slice(index + 1).findIndex((entry) => /sha256 "/.test(entry));
    if (offset === -1) {
      warnings.push(`no sha256 line follows ${url}`);
      return [];
    }
    return [{ url, shaIndex: index + 1 + offset }];
  });

  const checksums = await Promise.all(
    targets.map(async ({ url, shaIndex }) => {
      console.log(`Fetching ${url} ...`);
      const sha = await sha256(url);
      if (sha === null) {
        warnings.push(`Failed to fetch ${url}`);
        return null;
      }
      console.log(`  sha256 ${sha}`);
      return { shaIndex, sha };
    }),
  );

  for (const check of checksums) {
    if (check === null) continue;
    lines[check.shaIndex] = lines[check.shaIndex].replace(
      /sha256 "[a-f0-9]*"/,
      `sha256 "${check.sha}"`,
    );
  }
  return lines.join("\n");
}

// Never throws: a formula that cannot be checked is reported, not fatal.
async function updateFormula(path: string): Promise<Result> {
  const notices: string[] = [];
  const warnings: string[] = [];
  const original = readFileSync(path, "utf8");

  try {
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
      warnings.push(`${path}: could not determine current version`);
      return { path, notices, warnings, summary: null };
    }

    let latest: string | null = null;
    const asset = downloadUrl === null ? "" : downloadUrl.split("/").pop() ?? "";
    if (repo !== null && downloadUrl?.includes("/releases/download/") && asset.includes(current)) {
      latest = await newestAssetVersion(repo, asset, current);
      if (latest === null) warnings.push(`${path}: no release asset matching ${asset}`);
    } else if (repo !== null) {
      latest = await newestTag(repo);
      if (latest === null) warnings.push(`${path}: could not determine latest for ${repo}`);
    } else {
      warnings.push(`${path}: could not determine git repository URL`);
    }
    if (latest === null) return { path, notices, warnings, summary: null };

    notices.push(`${path}: current=${current} latest=${latest}`);
    if (latest === current) return { path, notices, warnings, summary: null };

    let updated = original.replace(/version "\d+\.\d+\.\d+"/g, `version "${latest}"`);
    const carried = new RegExp(escapeForRegExp(current), "g");
    updated = updated
      .split("\n")
      .map((line) => (/^\s*(url|head) "/.test(line) ? line.replace(carried, latest) : line))
      .join("\n");

    updated = await refreshChecksums(updated, latest, warnings);

    if (updated === original) return { path, notices, warnings, summary: null };
    writeFileSync(path, updated);
    return { path, notices, warnings, summary: `${path}: v${current} -> v${latest}` };
  } catch (error) {
    warnings.push(`${path}: ${(error as Error).message}`);
    return { path, notices, warnings, summary: null };
  }
}

async function main(): Promise<void> {
  const formulas = readdirSync(FORMULA_DIR)
    .filter((name) => name.endsWith(".rb"))
    .sort()
    .map((name) => `${FORMULA_DIR}/${name}`);
  const results: Result[] = [];
  let next = 0;
  await Promise.all(
    Array.from({ length: Math.min(CONCURRENCY, formulas.length) }, async () => {
      // Claim the index before awaiting: reading it after the await lets two
      // workers pick up the same formula.
      while (next < formulas.length) {
        const index = next;
        next += 1;
        results.push(await updateFormula(formulas[index]));
      }
    }),
  );
  results.sort((a, b) => a.path.localeCompare(b.path));

  for (const result of results) {
    for (const message of result.notices) console.log(`::notice::${message}`);
    for (const message of result.warnings) console.log(`::warning::${message}`);
  }

  const noticeCount = results.flatMap((result) => result.notices).length;
  const warningCount = results.flatMap((result) => result.warnings).length;
  console.log(`checked ${formulas.length} formulas, ${noticeCount} notices, ${warningCount} warnings`);

  const changed = results.flatMap((result) => (result.summary === null ? [] : [result.summary]));
  if (changed.length === 0) return;

  if (Bun.env.GITHUB_OUTPUT !== undefined) {
    await Bun.write(Bun.env.GITHUB_OUTPUT, "updated=true\n");
  }
  await Bun.write(SUMMARY_FILE, `${changed.join("\n")}\n`);
  console.log(changed.join("\n"));
}

await main();