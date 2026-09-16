class ArtefactCli < Formula
  desc "Remove JPEG compression artefacts"
  homepage "https://github.com/Delnegend/artefact"
  version "1.0.8"
  url "https://github.com/Delnegend/artefact/archive/refs/tags/v1.0.8.tar.gz"
  sha256 "d074d1526374a28c4ee96664982585775c2dcb7146478ced6fe3bb703e8102fd"
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

    system "cargo", "install", "--path", "backend/artefact-cli", *std_cargo_args
  end

  test do
    assert_match "artefact-cli", shell_output("#{bin}/artefact-cli --version")
  end
end
