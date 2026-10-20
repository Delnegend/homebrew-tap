require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.59/brave-origin-1.98.59-linux-amd64.zip"
    sha256 "bbbfea5d7dae21a1fcbd52fc8b23882a5dee2521ac72292f9e30b1a2519819e2"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.59/brave-origin-1.98.59-linux-arm64.zip"
    sha256 "3b7e879e293bd8de2b078dc87755a12f03b3b533f5778ae82a76d7f9500cb458"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
