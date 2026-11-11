class CommonFacade < Formula
  desc "Validate and generate README.md and LICENSE files from README.yml"
  homepage "https://github.com/Delnegend/common-facade"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_releases
  end

  head "https://github.com/Delnegend/common-facade.git", branch: "main" do
    depends_on "go" => :build
  end

  depends_on arch: :x86_64
  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/common-facade/releases/download/v0.1.0/common-facade-0.1.0-linux-amd64.tar.xz"
      sha256 "c7e12ad409ba0f0a28a90cca546627f4fc423bc1618530d7cb1d76d995503a90"
    end
  end

  def install
    if build.head? || File.exist?("go.mod")
      system "go", "build", *std_go_args(ldflags: "-s -w")
    else
      bin.install "common-facade"
    end
  end

  test do
    assert_match "Usage: common-facade", shell_output("#{bin}/common-facade --help")
  end
end
