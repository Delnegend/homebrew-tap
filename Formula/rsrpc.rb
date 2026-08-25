class Rsrpc < Formula
  desc "Alternative Discord RPC server"
  homepage "https://github.com/SpikeHD/rsRPC"
  url "https://github.com/SpikeHD/rsRPC/archive/refs/tags/v0.28.0.tar.gz"
  sha256 "023664a9c12bfd15bfd5db4d9cbc7942b9e0d23d57099cf4924da4cb4fb546bd"
  license "MIT"

  livecheck do
    url "https://github.com/SpikeHD/rsRPC/releases"
    strategy :github_releases
  end

  depends_on "rust" => :build

  def install
    cd "cli" do
      system "cargo", "install", "--locked", "--root", prefix, "--path", "."
    end
    bin.install bin/"rsrpc-cli" => "rsrpc"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rsrpc --version")
  end
end
