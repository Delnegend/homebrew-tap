class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.4.4"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  head "https://github.com/Delnegend/mikrotik-mcp-server.git", branch: "master" do
    depends_on "go" => :build
  end

  # Prebuilt binaries ship for Linux x64 and Windows x64 only. Every other
  # platform builds from the source tag, so the formula and the release
  # assets cannot disagree about what exists.
  on_macos do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.4.tar.gz"
      sha256 "29e45b0557306cc747387e92f5335aec6b992ba24fa19ec3874ec26bfb308b4b"
      depends_on "go" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.4.tar.gz"
      sha256 "29e45b0557306cc747387e92f5335aec6b992ba24fa19ec3874ec26bfb308b4b"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.4.tar.gz"
      sha256 "29e45b0557306cc747387e92f5335aec6b992ba24fa19ec3874ec26bfb308b4b"
      depends_on "go" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.4/mikrotik-mcp-0.4.4-linux-amd64.tar.xz"
      sha256 "cc51d7a5e5bc103abe6e1de870d5eb7f6842d129d359e1dec7cdcb9e3c132f8e"
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
