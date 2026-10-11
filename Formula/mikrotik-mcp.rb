class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.3.4"
  license "MIT"
  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master"

  livecheck do
    url "https://github.com/Delnegend/mikrotik-mcp-server/releases"
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.4/mikrotik-mcp-darwin-arm64.tar.xz"
      sha256 "ef3fcf2910189a21a89e2026f6b9396bd2d268e592915f375179a292e0c730f7"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.3.4.tar.gz"
      sha256 "49f78a64fbecc9a10a38f2c295c718036bb5fd446e744507174c07f69f1460fb"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.4/mikrotik-mcp-linux-arm64.tar.xz"
      sha256 "946bf40ddf6335728ded1109f2526a70bd3f6e042ce911f354918a619cab482a"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.4/mikrotik-mcp-linux-amd64.tar.xz"
      sha256 "f3a7ad0cc5a57763a0830c9467ffdac584667c83b4277e78034fcd06e51b9c52"
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
