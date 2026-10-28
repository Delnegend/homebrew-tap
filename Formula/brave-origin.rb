require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.62/brave-origin-1.98.62-linux-amd64.zip"
    sha256 "fbabdb9db411f4ef44ab49b1d1c9fb932c156128a5ac54881b1199fb5505222f"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.62/brave-origin-1.98.62-linux-arm64.zip"
    sha256 "3f92c354c69eef38fe1cf1f91844c74af2775fee06d9edf62706e74fcfcef85d"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
