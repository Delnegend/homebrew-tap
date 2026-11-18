require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.58/brave-origin-1.100.58-linux-amd64.zip"
    sha256 "c10bb3951e03b430263024f35ae4356fe092e93cf7e5df54162b8982992baba2"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.58/brave-origin-1.100.58-linux-arm64.zip"
    sha256 "44af9de4370c0a34b2898d577bbf34318b56aa66047ce8760f1f6505751a5940"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
