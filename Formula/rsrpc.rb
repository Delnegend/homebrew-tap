class Rsrpc < Formula
  desc "Discord Rich Presence server for Linux and macOS"
  homepage "https://github.com/Delnegend/rsRPC"
  version "0.29.4"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  # macOS builds from the release tag: only linux x64 ships prebuilt.
  on_macos do
    on_arm do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.4.tar.gz"
      sha256 "294ef3f9bf6513ebd554ee127264a23d92382b7e2c454b41a6000ab00851ab95"
      depends_on "rust" => :build
    end
    on_intel do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.4.tar.gz"
      sha256 "294ef3f9bf6513ebd554ee127264a23d92382b7e2c454b41a6000ab00851ab95"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.4/rsrpc-0.29.4-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "0052a22b4c3a7bf2846311762fe9d69dee6de0f492902bdc763d072fc8de5a15"
    end
    # No prebuilt linux-arm64 artifact yet, so build from the release tag.
    on_arm do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.4.tar.gz"
      sha256 "294ef3f9bf6513ebd554ee127264a23d92382b7e2c454b41a6000ab00851ab95"
      depends_on "rust" => :build
    end
  end

  service do
    # `opt_bin` survives `brew upgrade`, which `bin` does not.
    run [opt_bin/"rsrpc"]
    # The daemon runs until SIGINT, so keep it alive across crashes.
    keep_alive true
    # A port-1337 conflict is fatal by design and exits non-zero; the backoff
    # keeps a lost startup race from spinning the unit.
    restart_delay 5
    # The IPC socket resolves under $XDG_RUNTIME_DIR, never the working
    # directory, but pin it so nothing inherits the installer's cwd.
    working_dir HOMEBREW_PREFIX
    log_path "/tmp/rsrpc.log"
    error_log_path "/tmp/rsrpc.error.log"
  end

  def install
    if File.exist?("Cargo.toml")
      # Install crate without std_cargo_args --locked flag.
      cli = Dir["crates/cli", "crates/rsrpc"].first
      system "cargo", "install", "--path", cli, "--root", prefix
      bin.install Dir["bin/rsrpc", "bin/rsrpc-cli"].first => "rsrpc"
    else
      # Extract binary from release archive wrapper directory.
      bin.install Dir["**/rsrpc*"].find { |f| File.file?(f) } => "rsrpc"
    end
  end

  def caveats
    <<~EOS
      Run it as a managed background service:
        brew services start rsrpc

      Follow the logs with:
        tail -f /tmp/rsrpc.log
    EOS
  end

  test do
    # Assert the version, not the binary's own name: older releases still
    # report `rsrpc-cli` there.
    assert_match version.to_s, shell_output("#{bin}/rsrpc --version")
  end
end
