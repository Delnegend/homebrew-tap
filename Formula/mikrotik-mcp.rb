class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.4.0"
  license "MIT"
  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master"

  livecheck do
    url "https://github.com/Delnegend/mikrotik-mcp-server/releases"
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.0/mikrotik-mcp-darwin-arm64.tar.xz"
      sha256 "263d5ae23e97c86a753a9ae6f846bf647ae00713615031251560aa95bab80297"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.0.tar.gz"
      sha256 "808216c68fe853abf8e8ca71252cbc171462706ef694cbd30ef648f6871d3730"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.0/mikrotik-mcp-linux-arm64.tar.xz"
      sha256 "946bf40ddf6335728ded1109f2526a70bd3f6e042ce911f354918a619cab482a"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.0/mikrotik-mcp-linux-amd64.tar.xz"
      sha256 "e3a02c87579732c20864a013016d8138fefa1e0f363641bc50ab90cb107b1828"
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
