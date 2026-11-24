require_relative "../lib/brave_origin"

class BraveOrigin < BraveOriginFormula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  license "MPL-2.0"

  # Upstream ships every stable release for both architectures.
  on_intel do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.59/brave-origin-1.100.59-linux-amd64.zip"
    sha256 "1b07d2dca20d8bc49dc00c9f22e8b9138feb71ca12b450cf8607f7d6497e9ad7"
  end

  on_arm do
    url "https://github.com/brave/brave-browser/releases/download/v1.100.59/brave-origin-1.100.59-linux-arm64.zip"
    sha256 "ddab46f891964af8eacc3da4a84bd7624fb1d35f664fa89157f0a6ee91f61aa2"
  end

  channel "brave-origin"

  depends_on :linux

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
