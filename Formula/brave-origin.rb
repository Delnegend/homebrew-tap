require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.56/brave-origin-1.100.56-linux-amd64.zip"
    sha256 "dd8878680f1877463bc643b6c5667f075b47e376703e25f5a581260428490492"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.56/brave-origin-1.100.56-linux-arm64.zip"
    sha256 "5069a5801b23c2a84eaef6faa0dc324098818be04cc56da60cda0064249fc2a5"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
