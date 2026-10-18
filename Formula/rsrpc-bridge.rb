class RsrpcBridge < Formula
  desc "Wine/Proton IPC bridge connecting Windows games to the host rsRPC socket"
  homepage "https://github.com/Delnegend/rsRPC"
  url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.1/rsrpc-bridge-0.29.1-i686-pc-windows-gnu.zip"
  version "0.29.1"
  sha256 "55e65fa6abcce174d99b92b816efb8750e2d6b363f4df34f38fc170e8ffbba52"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on :linux

  def install
    # The release archive wraps its contents in a directory named after
    # itself. Searched recursively so the formula does not care how deep that
    # wrapper sits.
    src = File.dirname(Dir["**/bridge.sh"].fetch(0)) + "/"
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
