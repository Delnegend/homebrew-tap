class RsrpcBridge < Formula
  desc "Wine/Proton IPC bridge connecting Windows games to the host rsRPC socket"
  homepage "https://github.com/Delnegend/rsRPC"
  url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.3/rsrpc-bridge-0.29.3-i686-pc-windows-gnu.zip"
  version "0.29.3"
  sha256 "71c21bd308e26a0509ec9900ceec8cc081efcdc8d91a6a3b3161d42ce8cc045d"
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
