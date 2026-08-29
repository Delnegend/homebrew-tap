class SegotepDigital < Formula
  desc "Driver and daemon for Segotep Ice Moon / Digital series AIO CPU coolers"
  homepage "https://github.com/Delnegend/segotep-digital"
  version "1.0.0"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Delnegend/segotep-digital.git" do
    depends_on "rust" => :build
  end

  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v1.0.0/segotep-digital-v1.0.0-linux-amd64.tar.xz"
      sha256 "79d871105f899db802e85514ea9e8e726d46995fb28964f8e6534d1cb69dae89"
    end
    on_arm do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v1.0.0/segotep-digital-v1.0.0-linux-arm64.tar.xz"
      sha256 "b5b6fd51cc8546781c121b1f66423222cdef798ac902cc87f941297caa99d273"
    end
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
      Runs entirely in userspace — no root privileges, udev rules, or system
      service required. USB HID and telemetry are accessed directly.

      Run in the foreground (Ctrl+C to stop):

        segotep-digital -v

      Or as a background daemon via systemd --user, reusing the shipped unit:

        mkdir -p ~/.config/systemd/user
        sed -e 's|/usr/local/bin|#{HOMEBREW_PREFIX}/bin|' -e 's|multi-user.target|default.target|' \\
          #{opt_pkgshare}/segotep-digital.service > ~/.config/systemd/user/segotep-digital.service
        systemctl --user daemon-reload
        systemctl --user enable --now segotep-digital.service
    EOS
  end

  test do
    assert_match "segotep-digital", shell_output("#{bin}/segotep-digital --version")
  end
end
