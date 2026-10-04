require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  url "https://github.com/brave/brave-browser/releases/download/v1.97.53/brave-origin-1.97.53-linux-amd64.zip"
  sha256 "a02887f323f6782d3efcbb8cfac7ba8bfb8014599dfd7fbf67ebb8d898b28c78"
  license "MPL-2.0"

  channel "brave-origin"

  depends_on arch: :x86_64
  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
