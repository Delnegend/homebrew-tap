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
      url "https://github.com/Delnegend/common-facade/releases/download/v0.1.1/common-facade-0.1.1-linux-amd64.tar.xz"
      sha256 "eea990c4b942fe9706b9d47c962c106a30a0b99077604f80308251ab51043cbd"
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
