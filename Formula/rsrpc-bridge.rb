class RsrpcBridge < Formula
  desc "Wine/Proton IPC bridge connecting Windows games to the host rsRPC socket"
  homepage "https://github.com/Delnegend/rsRPC"
  url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.5/rsrpc-bridge-0.29.5-i686-pc-windows-gnu.zip"
  version "0.29.5"
  sha256 "975cc70d5cd98dceabc6f3c0abe1e8b35ad49f34c93c1ca8287e18a5a6af7e65"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on :linux

  def install
    # The archive wraps its contents in a directory named after it.
    src = Dir["rsrpc-bridge-*/"].fetch(0)
    # bridge.sh resolves rsrpc-bridge.exe from its own directory and passes it
    # into the game's Proton prefix, so the pair stays side by side and neither
    # goes on PATH: the exe is not runnable on the host.
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
    # The bridge is a windows-gnu exe meant to run inside a Wine prefix, so
    # the test only asserts the pair that Steam launch options depend on.
    assert_path_exists "#{libexec}/rsrpc-bridge.exe"
    assert_predicate libexec/"bridge.sh", :executable?
  end
end
