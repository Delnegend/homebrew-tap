class Tsuzuri < Formula
  desc "Block-based notebook for the terminal"
  homepage "https://github.com/jaisuriya-11/tsuzuri"
  url "https://github.com/jaisuriya-11/tsuzuri/releases/download/v0.3.1/tsuzuri-linux.tar.gz"
  sha256 "c31ce82afab33823f10fb4b77b6449234f9815370a4f6d92e4742552a0caae30"
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
