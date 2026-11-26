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
      url "https://github.com/Delnegend/common-facade/releases/download/v0.1.3/common-facade-0.1.3-linux-amd64.tar.xz"
      sha256 "18874f4bd278b9b65946769867cf52f0065ff3b364327b315e44048566a701d8"
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
