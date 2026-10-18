class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.4.1"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master" do
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.1/mikrotik-mcp-0.4.1-darwin-arm64.tar.xz"
      sha256 "32bfece9dffd1891b46577110a2cedda95831a37de2150e86d3190cbeb996806"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.1.tar.gz"
      sha256 "eab8d6ee74b6dd7cd90512c2ae72f8a891821eeaf8d3a51185f100c8610182c4"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.1/mikrotik-mcp-0.4.1-linux-arm64.tar.xz"
      sha256 "a83304f31e24a2860da08d2b213fec68df746351ac62dd233a2750d2a2fedef5"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.1/mikrotik-mcp-0.4.1-linux-amd64.tar.xz"
      sha256 "6576dd6c6ea582c0b3fda7a51c0e57d752e01f8806574d7d6cf2ab50cede4463"
    end
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
