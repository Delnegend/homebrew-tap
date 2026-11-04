require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.55/brave-origin-1.99.55-linux-amd64.zip"
    sha256 "9d0e39e4020bfdf7aafc51308017d440ec009f8f3bbd91b67876b0d65a55505d"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.55/brave-origin-1.99.55-linux-arm64.zip"
    sha256 "6000e3cbc78ef4a1683d59c2b2a1d8d58749aabb288e0c083f29241971f1a31d"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
