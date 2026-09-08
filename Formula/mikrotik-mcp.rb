class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.3.1"
  license "MIT"
  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master"

  livecheck do
    url "https://github.com/Delnegend/mikrotik-mcp-server/releases"
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.1/mikrotik-mcp-darwin-arm64.tar.xz"
      sha256 "cd21e5057729eec5fb2fdbd5e68f267ec4a7cfeb227ebf45d2bf4951e3ebdf4c"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.3.1.tar.gz"
      sha256 "f0943e08324d1c87abedaaa66f07f6483730b7dd65dfabd6046aab74a4044264"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.1/mikrotik-mcp-linux-arm64.tar.xz"
      sha256 "946bf40ddf6335728ded1109f2526a70bd3f6e042ce911f354918a619cab482a"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.1/mikrotik-mcp-linux-amd64.tar.xz"
      sha256 "4582ed0ae9a2639bb17a484b9fd43c40b5ffdbad2d7a8be6657be5336307fc39"
    end
  end

  head do
    depends_on "go" => :build
  end

  def install
    if build.head? || File.exist?("go.mod")
      ldflags = "-s -w -X main.version=#{version}"
      system "go", "build", *std_go_args(ldflags: ldflags), "."
    else
      bin.install "mikrotik-mcp"
      bin.install "rosbackup" if File.exist?("rosbackup")
    end
  end

  test do
    assert_match "mikrotik-mcp #{version}", shell_output("#{bin}/mikrotik-mcp -version")
  end
end
