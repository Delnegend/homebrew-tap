require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.56/brave-origin-1.99.56-linux-amd64.zip"
    sha256 "9c23fa625c124222c6c59d6d6f9819831838a715a7b8109c7f7ef8d85ec636a3"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.56/brave-origin-1.99.56-linux-arm64.zip"
    sha256 "c376f02aabcc54325663014e0c9ffb972be28db95abcae7684f57a9702a69714"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
