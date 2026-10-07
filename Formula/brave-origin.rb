require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.56/brave-origin-1.97.56-linux-amd64.zip"
    sha256 "4710187525d4153d47c1d0366a69829f351b445f568ed091bf62215de25ddf34"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.56/brave-origin-1.97.56-linux-arm64.zip"
    sha256 "66789d7cd7d423f761d713edc9959ebff86b1493b1718c15346f627b02f6ef74"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
