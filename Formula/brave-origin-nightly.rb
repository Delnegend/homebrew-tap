require_relative "../lib/brave_origin"

class BraveOriginNightly < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" nightly build)"
  homepage "https://brave.com/"
  # Upstream ships the arm64 archive for this channel only intermittently
  # (1.99.7 has one, 1.99.9 does not), so nightly stays amd64-only until every
  # release carries it.
  url "https://github.com/brave/brave-browser/releases/download/v1.99.25/brave-origin-nightly-1.99.25-linux-amd64.zip"
  sha256 "80ef1ceb2555d138a166f335d77e832bedeb58f03d6a7d2920953e0c7e5bea9c"
  license "MPL-2.0"

  channel "brave-origin-nightly"

  depends_on arch: :x86_64
  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin-nightly --version")
  end
end
