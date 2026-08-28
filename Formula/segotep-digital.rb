class SegotepDigital < Formula
  desc "Driver and daemon for Segotep Ice Moon / Digital series AIO CPU coolers"
  homepage "https://github.com/Delnegend/segotep-digital"
  version "0.1.0"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Delnegend/segotep-digital.git", branch: "main"

  livecheck do
    url "https://github.com/Delnegend/segotep-digital/releases"
    strategy :github_releases
  end

  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v0.1.0/segotep-digital-v0.1.0-linux-amd64.tar.xz"
      sha256 "712b5ed037db5678b7ec3fe08047c9255d8e8ef0d04622f73c3ed189385e9c7e"
    end
    on_arm do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v0.1.0/segotep-digital-v0.1.0-linux-arm64.tar.xz"
      sha256 "11b03908393b7275ed1ab4cf2d0e33459b15a5772388b8e4500abd21e691c411"
    end
  end

  head do
    depends_on "rust" => :build
  end

  def install
    if build.head? || File.exist?("Cargo.toml")
      system "cargo", "install", *std_cargo_args
      pkgshare.install "udev/99-segotep.rules" if File.exist?("udev/99-segotep.rules")
      pkgshare.install "systemd/segotep-digital.service" if File.exist?("systemd/segotep-digital.service")
    else
      bin.install "segotep-digital"
      pkgshare.install "99-segotep.rules" if File.exist?("99-segotep.rules")
      pkgshare.install "segotep-digital.service" if File.exist?("segotep-digital.service")
    end
  end

  def caveats
    <<~EOS
      To allow non-root USB communication and enable the background service:

        sudo cp #{opt_pkgshare}/99-segotep.rules /etc/udev/rules.d/
        sudo udevadm control --reload-rules && sudo udevadm trigger

        sudo cp #{opt_pkgshare}/segotep-digital.service /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable --now segotep-digital.service
    EOS
  end

  test do
    assert_match "segotep-digital", shell_output("#{bin}/segotep-digital --version")
  end
end
