class Rsrpc < Formula
  desc "Alternative Discord RPC server"
  homepage "https://github.com/SpikeHD/rsRPC"
  url "https://github.com/SpikeHD/rsRPC/archive/refs/tags/v0.29.0.tar.gz"
  sha256 "bfef62e11596744d5249a20e6cca98436060fbf853d0e2fe1e907b3bae0c5842"
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
