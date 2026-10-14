require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.57/brave-origin-1.97.57-linux-amd64.zip"
    sha256 "3c1ef2d52d38f3477a9636b2dc3a6ab4ceae9eb96c9fa19123192b81a1c6d7ba"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.57/brave-origin-1.97.57-linux-arm64.zip"
    sha256 "8b98add132b2955e7d4a95fabde2508410b14456b2aa7d54a91d3b32288ebd6c"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
