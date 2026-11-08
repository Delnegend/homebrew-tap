class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  version "0.4.3"
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
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.3.tar.gz"
      sha256 "9181b35e78f903ea7f9297b41ad4a4d3acc1880e7bf9fc2a06546d1aacda4bfa"
      depends_on "go" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.3.tar.gz"
      sha256 "9181b35e78f903ea7f9297b41ad4a4d3acc1880e7bf9fc2a06546d1aacda4bfa"
      depends_on "go" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.4.3.tar.gz"
      sha256 "9181b35e78f903ea7f9297b41ad4a4d3acc1880e7bf9fc2a06546d1aacda4bfa"
      depends_on "go" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/mikrotik-mcp-server/releases/download/v0.4.3/mikrotik-mcp-0.4.3-linux-amd64.tar.xz"
      sha256 "b9d155ccdbca1f081fefb2d49557b6c5168ced366f6e141d0896c01121628f12"
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
