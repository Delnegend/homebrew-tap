class Tsuzuri < Formula
  desc "Block-based notebook for the terminal"
  homepage "https://github.com/jaisuriya-11/tsuzuri"
  url "https://github.com/jaisuriya-11/tsuzuri/releases/download/v0.2.0/tsuzuri-linux.tar.gz"
  sha256 "619069055015f2005f72c8ca02a334c607ccac795259352eb19527f38e9fb89d"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on arch: :x86_64
  depends_on :linux

  def install
    bin.install "tsuzuri"
  end

  test do
    assert_match "tsuzuri #{version}", shell_output("#{bin}/tsuzuri --version")
  end
end
