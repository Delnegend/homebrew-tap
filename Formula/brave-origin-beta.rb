require_relative "../lib/brave_origin"

class BraveOriginBeta < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" beta build)"
  homepage "https://brave.com/"
  # Upstream ships the arm64 archive for this channel only intermittently
  # (1.98.47 has one, 1.98.48 does not), so beta stays amd64-only until every
  # release carries it.
  url "https://github.com/brave/brave-browser/releases/download/v1.101.52/brave-origin-beta-1.101.52-linux-amd64.zip"
  sha256 "d22ca9e1bcd2d45180163406b9cf2808cd4b4c658c8aad17cbff64b83e01d7c3"
  license "MPL-2.0"

  channel "brave-origin-beta"

  depends_on arch: :x86_64
  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin-beta --version")
  end
end
