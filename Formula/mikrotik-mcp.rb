class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.3.3"
  license "MIT"
  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master"

  livecheck do
    url "https://github.com/Delnegend/mikrotik-mcp-server/releases"
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.3/mikrotik-mcp-darwin-arm64.tar.xz"
      sha256 "c0a5e3d6d43556adf260ee6e1ec4dc4120762355f7c53c9b97ade734f8190275"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.3.3.tar.gz"
      sha256 "8d0280151733337dfd3cc9bcd2049ecdda77b2cb47f42bb175b747ea9082e4c2"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.3/mikrotik-mcp-linux-arm64.tar.xz"
      sha256 "946bf40ddf6335728ded1109f2526a70bd3f6e042ce911f354918a619cab482a"
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.3.3/mikrotik-mcp-linux-amd64.tar.xz"
      sha256 "a1e6b1e58c8b6eb5f86cae2954b870ba2e002cbee5d66e1a298dfcae250f10ed"
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
