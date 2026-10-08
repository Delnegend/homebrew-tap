class Tsuzuri < Formula
  desc "Block-based notebook for the terminal"
  homepage "https://github.com/jaisuriya-11/tsuzuri"
  url "https://github.com/jaisuriya-11/tsuzuri/releases/download/v0.2.1/tsuzuri-linux.tar.gz"
  sha256 "0dfd1f7a492b26f2769385c96bc29908838c5e6ebf8d06bcb162f67522bde94f"
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
