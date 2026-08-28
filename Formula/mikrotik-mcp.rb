class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.3.0"
  license "MIT"
  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master"

  livecheck do
    url "https://github.com/Delnegend/mikrotik-mcp-server/releases"
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.0/mikrotik-mcp-darwin-arm64.tar.xz"
      sha256 "e27ee63b18b441c31d3b21e25523235174e40e15aede0954e557141e321d4fe7"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.3.0.tar.gz"
      sha256 "379aaed3a19a6031f1b4142f82a97e79472b6a7ae0ba05722c39f7fd6329ad59"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.0/mikrotik-mcp-linux-arm64.tar.xz"
      sha256 "946bf40ddf6335728ded1109f2526a70bd3f6e042ce911f354918a619cab482a"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.0/mikrotik-mcp-linux-amd64.tar.xz"
      sha256 "b2a4a3137cf3483ccb37eb9fff3a4a814eef21c822dcd7c63a6e5260af1aa6ae"
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
