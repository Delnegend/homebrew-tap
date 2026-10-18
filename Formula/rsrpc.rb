class Rsrpc < Formula
  desc "Discord Rich Presence server for Linux and macOS"
  homepage "https://github.com/Delnegend/rsRPC"
  version "0.29.5"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.5/rsrpc-0.29.5-aarch64-apple-darwin.tar.xz"
      sha256 "1f8e5615c1b6ffb1741813acd6008df2f2981508ccbc44beb775bf09c62693d1"
    end
    # No prebuilt macos-x86_64 artifact yet, so build from the release tag.
    on_intel do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.5.tar.gz"
      sha256 "5d74f8600bc9dfb7b4f43a073cedb1e3b422f128c7b1329103205811f46cd582"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.5/rsrpc-0.29.5-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "7ddc0dcf857fe6cd57ace60ddbb95b2f956cf4aedd015c3b2ab6e9a0c581f7f8"
    end
    # No prebuilt linux-arm64 artifact yet, so build from the release tag.
    on_arm do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.5.tar.gz"
      sha256 "5d74f8600bc9dfb7b4f43a073cedb1e3b422f128c7b1329103205811f46cd582"
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
      # Not `std_cargo_args`: that adds `--locked`, and a release tag cut
      # before the lock-sync fix ships a Cargo.lock still naming the previous
      # version, so a locked build fails on the member version alone. `cargo
      # install` resolves the workspace itself; only third-party pins matter
      # here, and those come from the lock as-is.
      system "cargo", "install", "--path", "crates/cli", "--root", prefix
      bin.install bin/"rsrpc-cli" => "rsrpc"
    else
      # The release archive wraps its contents in a directory named after
      # itself. Searched recursively so the formula does not care how deep
      # that wrapper sits.
      bin.install Dir["**/rsrpc-cli*"].fetch(0) => "rsrpc"
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
    assert_match "rsrpc-cli #{version}", shell_output("#{bin}/rsrpc --version")
  end
end
