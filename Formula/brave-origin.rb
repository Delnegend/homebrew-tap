require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.58/brave-origin-1.98.58-linux-amd64.zip"
    sha256 "b8a8670c79ac9d3b494acd2513eb825a5320b4cfb7096d036134bb93eee4eccd"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.58/brave-origin-1.98.58-linux-arm64.zip"
    sha256 "af29ebfe9f5e6d25b09ed77495fb22e52203e25289b18348cdcf39d2707b0c2c"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
