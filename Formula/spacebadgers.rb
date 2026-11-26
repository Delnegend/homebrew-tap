class Spacebadgers < Formula
  desc "Fast and clean SVG badge generator (installs the badgers-cli command)"
  homepage "https://github.com/SplittyDev/spacebadgers"
  # Upstream publishes no GitHub releases or tags, only crates.io versions, so
  # the source is the published `badgers-cli` crate.
  url "https://static.crates.io/crates/badgers-cli/badgers-cli-0.2.2.crate"
  sha256 "5c88e7e95a5c73d60f72f4b2d9366e924f143f7e74f10757ccc6bc9aa3df20e3"
  license "MIT"

  # The hourly updater only follows GitHub tags and release assets, which this
  # project does not have. Bump the url and sha256 by hand when crates.io
  # (https://crates.io/crates/badgers-cli) lists a newer badgers-cli.
  livecheck do
    skip "crates.io only; the updater cannot follow it, bump manually"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "badgers-cli #{version}", shell_output("#{bin}/badgers-cli --version")

    svg = shell_output("#{bin}/badgers-cli badge --label build --status passing")
    assert_match "<svg", svg
    assert_match "passing", svg
  end
end
