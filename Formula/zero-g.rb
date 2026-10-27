class ZeroG < Formula
  desc "OpenAI-compatible proxy for Google Antigravity subscriptions"
  homepage "https://github.com/Delnegend/zero-g"
  version "0.5.4"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/zero-g/releases/download/v0.5.4/zero-g-0.5.4-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "206f04e81b2cc74de9def9e9202d7ec6049087733897bf5a99943d76ce2d707d"
    end
  end

  service do
    # `opt_bin` survives `brew upgrade`, which `bin` does not.
    run [opt_bin/"zero-g", "serve"]
    # The proxy serves until killed, so keep it alive across crashes.
    keep_alive true
    # Bind address comes from ZERO_G_BIND (default 127.0.0.1:8080);
    # a restart storm on a held port would spin the unit.
    restart_delay 5
    # Credentials live in ~/.config/zero-g; pin the working directory
    # so nothing inherits the installer's cwd.
    working_dir HOMEBREW_PREFIX
    log_path "/tmp/zero-g.log"
    error_log_path "/tmp/zero-g.error.log"
  end

  def install
    if File.exist?("Cargo.toml")
      system "cargo", "install", "--path", ".", "--root", prefix
      bin.install Dir["bin/zero-g"].first => "zero-g"
    else
      # Extract binary from release archive wrapper directory.
      bin.install Dir["**/zero-g"].find { |f| File.file?(f) } => "zero-g"
    end
  end

  def caveats
    <<~EOS
      Authenticate once, then run as a managed background service:
        zero-g login
        brew services start zero-g

      Follow the logs with:
        tail -f /tmp/zero-g.log
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zero-g --version")
  end
end
