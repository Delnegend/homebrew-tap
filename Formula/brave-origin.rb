require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.54/brave-origin-1.99.54-linux-amd64.zip"
    sha256 "e73a8b19aec85fc66afc605ab66680fedcaca1a54b60f44e55f08b5ca378a68d"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.99.54/brave-origin-1.99.54-linux-arm64.zip"
    sha256 "1ff68a4c3f6b414aee47ebdc4b57fdc75b2e911a20c60cb9cb08eda26aaf1ab9"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
