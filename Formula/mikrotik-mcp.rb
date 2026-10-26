class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.4.2"
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
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.2.tar.gz"
      sha256 "743db1f6ba89a10859f9b09ab681cac6c2c9771b43ae066e0e19802709f11cdf"
      depends_on "go" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.2.tar.gz"
      sha256 "743db1f6ba89a10859f9b09ab681cac6c2c9771b43ae066e0e19802709f11cdf"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.2.tar.gz"
      sha256 "743db1f6ba89a10859f9b09ab681cac6c2c9771b43ae066e0e19802709f11cdf"
      depends_on "go" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.2/mikrotik-mcp-0.4.2-linux-amd64.tar.xz"
      sha256 "831cca4a6cc0366fa0227c8499a042980e0c0d2a1124b3efb40c5103e24b6bed"
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
