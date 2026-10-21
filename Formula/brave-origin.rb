require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.60/brave-origin-1.98.60-linux-amd64.zip"
    sha256 "39a69cf12b5787f789d0a0b013f32253bddc9004d03e36c679a8daa61821b6e8"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.60/brave-origin-1.98.60-linux-arm64.zip"
    sha256 "9c02f03b691515a2eb81a17c5570fcc958915a4f1ee9973b69b578566c876a3b"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
