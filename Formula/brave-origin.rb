require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.54/brave-origin-1.97.54-linux-amd64.zip"
    sha256 "bfbc732d3dbf3095009e9877d26c15d83b993f30ef4a841b7ea3d9b963f33ad4"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.97.54/brave-origin-1.97.54-linux-arm64.zip"
    sha256 "88ea1cadd3e6c55c9c151d3f5c00e25f348aa059a4df5741fd159412dec44aa6"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
