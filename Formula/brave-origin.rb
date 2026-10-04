require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.53/brave-origin-1.97.53-linux-amd64.zip"
    sha256 "a02887f323f6782d3efcbb8cfac7ba8bfb8014599dfd7fbf67ebb8d898b28c78"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.53/brave-origin-1.97.53-linux-arm64.zip"
    sha256 "6f8d969726e28026805936b408e839b551033af37fd9f973e18208cd5c0895b8"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
