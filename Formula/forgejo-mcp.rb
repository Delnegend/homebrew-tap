class ForgejoMcp < Formula
  desc "MCP server for Forgejo"
  homepage "https://git.b4mad.industries/agentic-forges/forgejo-mcp"
  version "3.2.0"
  license "GPL-3.0-or-later"

  livecheck do
    url :head
    strategy :git
  end

  head do
    url "https://git.b4mad.industries/agentic-forges/forgejo-mcp.git", branch: "main"
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://git.b4mad.industries/agentic-forges/forgejo-mcp/releases/download/v3.2.0/forgejo-mcp_3.2.0_darwin_arm64.tar.gz"
      sha256 "dc031918c3fcaaa90109b5ffeeb0c13e85bda2728788dc759c9ce8925cf3300e"
    end
    on_intel do
      url "https://git.b4mad.industries/agentic-forges/forgejo-mcp/releases/download/v3.2.0/forgejo-mcp_3.2.0_darwin_amd64.tar.gz"
      sha256 "8879f0bb428d891bce7b8eb9fe5769bec852248b5eca6a1d61f8d28078e9ddf0"
    end
  end

  on_linux do
    on_arm do
      url "https://git.b4mad.industries/agentic-forges/forgejo-mcp/releases/download/v3.2.0/forgejo-mcp_3.2.0_linux_arm64.tar.gz"
      sha256 "b434a5874afe87bfe2e985d563b0cdbf029530aa5cfac85f2bf80be145c90d0a"
    end
    on_intel do
      url "https://git.b4mad.industries/agentic-forges/forgejo-mcp/releases/download/v3.2.0/forgejo-mcp_3.2.0_linux_amd64.tar.gz"
      sha256 "bf8f744d53dd06c0e7830ee13a0507464b3ab301fcf01de4744db03d770039df"
    end
  end

  def install
    if build.head? || File.exist?("go.mod")
      ldflags = "-s -w -X main.Version=#{version}"
      system "go", "build", *std_go_args(ldflags: ldflags), "."
    else
      bin.install "forgejo-mcp"
    end
  end

  test do
    assert_match "forgejo-mcp #{version}", shell_output("#{bin}/forgejo-mcp --version")
  end
end
