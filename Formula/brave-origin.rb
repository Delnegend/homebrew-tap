require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.63/brave-origin-1.98.63-linux-amd64.zip"
    sha256 "7714b3c2bb3e92c14f8f8ab373e2d298ff941abe1d81589c21c5f9227ac07c0b"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.98.63/brave-origin-1.98.63-linux-arm64.zip"
    sha256 "4fe49868e5adf5101eae03d8303b850bb16d86681b1158be026ac545dbba3c21"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
