class RsrpcBridge < Formula
  desc "Wine/Proton IPC bridge connecting Windows games to the host rsRPC socket"
  homepage "https://github.com/Delnegend/rsRPC"
  url "https://github.com/Delnegend/rsRPC/releases/download/v0.30.2/rsrpc-bridge-0.30.2-i686-pc-windows-gnu.zip"
  version "0.30.2"
  sha256 "2f234ab6e75880563e3dd78981ff73b8efab1e0e1c3e2e8e70225d571b554897"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on :linux

  def install
    # Locate extracted assets inside the wrapper directory.
    src = File.dirname(Dir["**/bridge.sh"].fetch(0)) + "/"
    # bridge.sh and rsrpc-bridge.exe stay in libexec since the exe runs in Wine.
    libexec.install "#{src}rsrpc-bridge.exe", "#{src}bridge.sh"
    chmod 0755, libexec/"bridge.sh"
  end

  def caveats
    <<~EOS
      Set the Steam launch options of a Proton game to:
        #{opt_prefix}/libexec/bridge.sh %command%
    EOS
  end

  test do
    # Windows binary runs in Wine; assert presence and launcher permissions.
    assert_path_exists "#{libexec}/rsrpc-bridge.exe"
    assert_predicate libexec/"bridge.sh", :executable?
  end
end
