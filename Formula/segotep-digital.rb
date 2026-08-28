class SegotepDigital < Formula
  desc "Driver and daemon for Segotep Ice Moon / Digital series AIO CPU coolers"
  homepage "https://github.com/Delnegend/segotep-digital"
  version "0.1.0"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Delnegend/segotep-digital.git" do
    depends_on "rust" => :build
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

      Or as a background daemon via systemd --user:

        mkdir -p ~/.config/systemd/user
        cat > ~/.config/systemd/user/segotep-digital.service <<UNIT
        [Unit]
        Description=Segotep Digital AIO display service

        [Service]
        Type=simple
        ExecStart=#{HOMEBREW_PREFIX}/bin/segotep-digital
        Restart=on-failure

        [Install]
        WantedBy=default.target
        UNIT
        systemctl --user daemon-reload
        systemctl --user enable --now segotep-digital.service
    EOS
  end

  test do
    assert_match "segotep-digital", shell_output("#{bin}/segotep-digital --version")
  end
end
