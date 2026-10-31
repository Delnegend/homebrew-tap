class ZeroG < Formula
  desc "OpenAI-compatible AI gateway for multiple providers"
  homepage "https://github.com/Delnegend/zero-g"
  version "0.5.8"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/zero-g/releases/download/v0.5.8/zero-g-0.5.8-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "96895bd334c3ec299036f8513375c3f93ff10e5ed4c3db3970964b4909e382a8"
    end
  end

  service do
    # `opt_bin` survives `brew upgrade`, which `bin` does not.
    run [opt_bin/"zero-g"]
    # The proxy serves until killed, so keep it alive across crashes.
    keep_alive true
    # Bind address comes from ZERO_G_BIND (default 127.0.0.1:8080);
    # a restart storm on a held port would spin the unit.
    restart_delay 5
    # Pin the working directory so nothing inherits the installer's cwd.
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
      Configure the required encryption key, dashboard authentication, and an
      absolute database path in the service environment before starting zero-g.
      See https://github.com/Delnegend/zero-g/blob/main/docs/deployment.md

      Start the service with:
        brew services start zero-g

      Follow the logs with:
        tail -f /tmp/zero-g.log
    EOS
  end

  test do
    require "net/http"
    require "socket"

    socket = TCPServer.new("127.0.0.1", 0)
    port = socket.addr[1]
    socket.close
    origin = "http://127.0.0.1:#{port}"
    env = {
      "ZERO_G_BIND" => "127.0.0.1:#{port}",
      "ZERO_G_LOG_DB" => (testpath/"logs.db").to_s,
      "ZERO_G_ENCRYPTION_KEY" => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
      "ZERO_G_DASHBOARD_AUTH" => "basic",
      "ZERO_G_DASHBOARD_ORIGIN" => origin,
      "ZERO_G_DASHBOARD_USERNAME" => "admin",
      "ZERO_G_DASHBOARD_PASSWORD" => "test-password-not-for-production",
    }
    pid = spawn(env, bin/"zero-g", out: testpath/"server.log", err: [:child, :out])
    begin
      response = nil
      60.times do
        begin
          response = Net::HTTP.get_response(URI("#{origin}/health"))
          break
        rescue Errno::ECONNREFUSED, Errno::ECONNRESET
          sleep 0.25
        end
      end
      assert_equal "200", response&.code, (testpath/"server.log").read
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
