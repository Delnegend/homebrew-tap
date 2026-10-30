class Tsuzuri < Formula
  desc "Block-based notebook for the terminal"
  homepage "https://github.com/jaisuriya-11/tsuzuri"
  url "https://github.com/jaisuriya-11/tsuzuri/releases/download/v0.4.0/tsuzuri-linux.tar.gz"
  sha256 "4e3fdaf6494953baa2e64895f93c7e1dd9286a8dde5dd124c19797d4e99755cd"
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
