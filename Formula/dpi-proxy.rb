class DpiProxy < Formula
  desc "HTTP proxy for networks with traffic inspection"
  homepage "https://github.com/Delnegend/dpi-proxy"
  url "https://github.com/Delnegend/dpi-proxy/releases/download/v0.1.0/dpi-proxy-0.1.0-x86_64-unknown-linux-musl.tar.xz"
  sha256 "6977e1db628e5b0987e9094b6e211d05e57b4e6713b798f1d3a18d385b55a6f9"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on arch: :x86_64
  depends_on :linux

  def install
    bin.install "dpi-proxy"
  end

  service do
    run [opt_bin/"dpi-proxy"]
    keep_alive true
    restart_delay 3
    working_dir HOMEBREW_PREFIX
    environment_variables DPI_PROXY_HOST:           "127.0.0.1",
                          DPI_PROXY_PORT:           "18118",
                          DPI_PROXY_SPLIT_SNI:      "true",
                          DPI_PROXY_RETRY_ON_RESET: "true",
                          DPI_PROXY_TIMEOUT_SECS:   "3"
  end

  test do
    require "socket"
    require "timeout"

    origin = TCPServer.new("127.0.0.1", 0)
    origin_port = origin.addr[1]
    reservation = TCPServer.new("127.0.0.1", 0)
    proxy_port = reservation.addr[1]
    reservation.close
    upstream = Thread.new do
      client = origin.accept
      request = +""
      request << client.gets until request.end_with?("\r\n\r\n")
      client.write "HTTP/1.1 200 OK\r\nContent-Length: 8\r\nConnection: close\r\n\r\nproxy-ok"
      client.close
      request
    end
    pid = spawn({ "DPI_PROXY_HOST" => "127.0.0.1", "DPI_PROXY_PORT" => proxy_port.to_s },
                bin/"dpi-proxy", out: File::NULL, err: File::NULL)

    begin
      Timeout.timeout(10) do
        begin
          client = TCPSocket.new("127.0.0.1", proxy_port)
        rescue Errno::ECONNREFUSED
          sleep 0.05
          retry
        end
        client.write "GET http://127.0.0.1:#{origin_port}/test HTTP/1.1\r\nHost: 127.0.0.1:#{origin_port}\r\n\r\n"
        response = client.read
        client.close
        assert_match "HTTP/1.1 200 OK", response
        assert_match "proxy-ok", response
        assert_match "GET /test HTTP/1.1", upstream.value
      end
    ensure
      begin
        Process.kill("TERM", pid)
      rescue Errno::ESRCH
        # The proxy may have exited before the test finished.
      end
      Process.wait(pid)
      origin.close
      upstream.kill
    end
  end
end
