class RsrpcBridge < Formula
  desc "Wine/Proton IPC bridge connecting Windows games to the host rsRPC socket"
  homepage "https://github.com/Delnegend/rsRPC"
  version "0.28.1"
  license "MIT"

  livecheck do
    url "https://github.com/Delnegend/rsRPC/releases"
    strategy :github_releases
  end

  url "https://github.com/Delnegend/rsRPC/releases/download/v0.28.1/rsrpc-bridge-x86_64-pc-windows-gnu.zip"
  sha256 "282bae9b49972d4d5dca4e7d4520105f9f89ecf8acd8f46d0ab7aa73dbf5c73b"

  depends_on :linux

  def install
    # bridge.sh resolves rsrpc-bridge.exe from its own directory and passes it
    # into the game's Proton prefix, so the pair stays side by side and neither
    # goes on PATH: the exe is not runnable on the host.
    libexec.install "rsrpc-bridge.exe", "bridge.sh"
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
    assert_file_executable "#{libexec}/bridge.sh"
    assert_file "#{libexec}/rsrpc-bridge.exe"
  end
end
