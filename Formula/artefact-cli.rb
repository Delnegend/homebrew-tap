class ArtefactCli < Formula
  desc "Remove JPEG compression artefacts"
  homepage "https://github.com/Delnegend/artefact"
  url "https://github.com/Delnegend/artefact/archive/refs/tags/v1.1.0.tar.gz"
  version "1.1.0"
  sha256 "cd72546f1a7f369114d5f42e979f11f46e2b277e0d642bfa671f6b069080e363"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/Delnegend/artefact.git", branch: "main"

  livecheck do
    url "https://github.com/Delnegend/artefact/releases"
    strategy :github_releases
  end

  depends_on "rust" => :build

  def install
    # `artefact-core` uses `#![feature(portable_simd)]`, so the unstable feature
    # has to be unlocked on Homebrew's (stable) `rust`. Same approach as
    # Homebrew's own `rust-wasm` formula.
    ENV["RUSTC_BOOTSTRAP"] = "1"
    # Report the formula version from `--version` (the release workflow does the
    # same via `ARTEFACT_BUILD_VERSION`).
    ENV["ARTEFACT_BUILD_VERSION"] = version

    system "cargo", "install", *std_cargo_args(path: "backend/artefact-cli")
  end

  test do
    assert_match "artefact-cli #{version}", shell_output("#{bin}/artefact-cli --version")
  end
end
