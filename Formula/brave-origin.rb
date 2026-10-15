require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.57/brave-origin-1.98.57-linux-amd64.zip"
    sha256 "082d0cdadd13896bc7119d59bb50107ff294a8b15b609d6f2b6408b3cd614746"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.57/brave-origin-1.98.57-linux-arm64.zip"
    sha256 "a7df7645952e0baf8f0345962792ffee0e9c6341b8eadece8b172a35ec5bd993"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
