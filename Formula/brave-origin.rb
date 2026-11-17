require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.57/brave-origin-1.100.57-linux-amd64.zip"
    sha256 "fd3e68982e90dd812b20cf108b5656ec2465d83be62401861afc4f0a085f0f1d"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.57/brave-origin-1.100.57-linux-arm64.zip"
    sha256 "d914a5459cd2f4ef0ef75c169e98977e415744c0d1bef407434de061003b1f71"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
