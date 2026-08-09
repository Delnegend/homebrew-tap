class MikrotikMcp < Formula
  desc "MCP server for managing MikroTik routers through the RouterOS API"
  homepage "https://github.com/Delnegend/mikrotik-mcp-server"
  url "https://github.com/Delnegend/mikrotik-mcp-server/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "1aeea8cf773a340be4751fd2adcdd033ce2009f4e8b2cb8a5e93c208907f8b63"
  license "MIT"

  depends_on "go" => :build

  livecheck do
    url "https://github.com/Delnegend/mikrotik-mcp-server/releases"
    strategy :github_releases
  end

  def install
    ldflags = "-s -w -X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags), "."
  end

  test do
    assert_match "mikrotik-mcp #{version}", shell_output("#{bin}/mikrotik-mcp -version")
  end
end
