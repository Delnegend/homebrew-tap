class SegotepDigital < Formula
  desc "Driver and daemon for Segotep Ice Moon / Digital series AIO CPU coolers"
  homepage "https://github.com/Delnegend/segotep-digital"
  version "1.0.1"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Delnegend/segotep-digital.git" do
    depends_on "rust" => :build
  end

  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v1.0.1/segotep-digital-v1.0.1-linux-amd64.tar.xz"
      sha256 "2ee1aff0afb97d053b08b8b4364ad188ad41dc3ec2b3cc8fa5fae31e7d04269e"
    end
    on_arm do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v1.0.1/segotep-digital-v1.0.1-linux-arm64.tar.xz"
      sha256 "fab6a093d4573369742de073ca1acd924fb240f5e8295d163d6a582d90aab27a"
    end
  end

  service do
    # `opt_bin` survives `brew upgrade`, which `bin` does not.
    run [opt_bin/"segotep-digital", "--interval-ms", "1000"]
    # The shipped unit uses Restart=always with a 3s delay: the daemon is
    # expected to outlive cooler sleep and power-cycle events.
    keep_alive true
    restart_delay 3
    log_path "/tmp/segotep-digital.log"
    error_log_path "/tmp/segotep-digital.error.log"
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

      Or as a managed background service:

        brew services start segotep-digital

      Follow the logs with:

        tail -f /tmp/segotep-digital.log

      Only one daemon may drive the display at a time: a second instance opens
      the same HID device without complaining, so stop any existing unit before
      starting this one.
    EOS
  end

  test do
    assert_match "segotep-digital", shell_output("#{bin}/segotep-digital --version")
  end
end
