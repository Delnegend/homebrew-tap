class SegotepDigital < Formula
  desc "Driver and daemon for Segotep Ice Moon / Digital series AIO CPU coolers"
  homepage "https://github.com/Delnegend/segotep-digital"
  url "https://github.com/Delnegend/segotep-digital/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "e995881b6655161a79f9318b6dbf972d203af1a092b4a2b413102089868de3df"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Delnegend/segotep-digital.git", branch: "main"

  livecheck do
    url "https://github.com/Delnegend/segotep-digital/releases"
    strategy :github_releases
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libusb"
  depends_on :linux

  def install
    system "cargo", "install", *std_cargo_args
    pkgshare.install "udev/99-segotep.rules"
    pkgshare.install "systemd/segotep-digital.service"
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
