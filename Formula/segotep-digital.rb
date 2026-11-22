class SegotepDigital < Formula
  desc "Driver and daemon for Segotep Ice Moon / Digital series AIO CPU coolers"
  homepage "https://github.com/Delnegend/segotep-digital"
  version "1.1.6"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Delnegend/segotep-digital.git" do
    depends_on "rust" => :build
  end

  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v1.1.6/segotep-digital-1.1.6-x86_64-unknown-linux-musl.tar.xz"
      sha256 "f4fdbdec8e4fd5f0b70cab95bb8da7993371539cb986b3b59cdd716be650110b"
    end
    on_arm do
      url "https://github.com/Delnegend/segotep-digital/releases/download/v1.1.6/segotep-digital-1.1.6-aarch64-unknown-linux-musl.tar.xz"
      sha256 "36bfab01b81eead5500c3826d45df2856e11d935d19a6a43d68c0f8b96b2a206"
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
      Runs entirely in userspace; no root privileges, udev rules, or system
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
