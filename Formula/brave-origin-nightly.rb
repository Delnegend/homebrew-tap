require_relative "../lib/brave_origin"

class BraveOriginNightly < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" nightly build)"
  homepage "https://brave.com/"
  url "https://github.com/brave/brave-browser/releases/download/v1.99.9/brave-origin-nightly-1.99.9-linux-amd64.zip"
  sha256 "cf355961fcef4b20ba1a1993f4fbc9761de958343fe1f07899ebb0966addad3f"
  license "MPL-2.0"

  channel "brave-origin-nightly"

  depends_on arch: :x86_64
  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin-nightly --version")
  end
end
