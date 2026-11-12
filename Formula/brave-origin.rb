require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.57/brave-origin-1.99.57-linux-amd64.zip"
    sha256 "d59a4b6368d6b6e48c086b984c3b26287c850a580d4907128ead545f3428b65b"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.57/brave-origin-1.99.57-linux-arm64.zip"
    sha256 "ac6c445db7f254b4e24344ba91536384586cc740328afc4b37c6381b6afcc28b"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
