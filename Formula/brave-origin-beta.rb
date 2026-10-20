require_relative "../lib/brave_origin"

class BraveOriginBeta < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" beta build)"
  homepage "https://brave.com/"
  # Upstream ships the arm64 archive for this channel only intermittently
  # (1.98.47 has one, 1.98.48 does not), so beta stays amd64-only until every
  # release carries it.
  url "https://github.com/brave/brave-browser/releases/download/v1.99.47/brave-origin-beta-1.99.47-linux-amd64.zip"
  sha256 "e1336281d5fa52696475a13c96ffed35116df6614fbf166699b5386f86f1d3c5"
  license "MPL-2.0"

  channel "brave-origin-beta"

  depends_on arch: :x86_64
  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin-beta --version")
  end
end
