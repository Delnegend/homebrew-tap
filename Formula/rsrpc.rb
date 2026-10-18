class Rsrpc < Formula
  desc "Discord Rich Presence server for Linux and macOS"
  homepage "https://github.com/Delnegend/rsRPC"
  version "0.29.1"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.1/rsrpc-0.29.1-aarch64-apple-darwin.tar.xz"
      sha256 "ff92bf7d32647777b8a5836ed1e6ea72422ffee2ba7cf0b5c8863ac702b3b320"
    end
    # No prebuilt macos-x86_64 artifact yet, so build from the release tag.
    on_intel do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.1.tar.gz"
      sha256 "c6cd260dfe7d0c434fbbc5ccf7a258e726b9e22e716dfbc5650f02d24730ccec"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.1/rsrpc-0.29.1-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "837494fafa87454558950e32a14d0c0223b224c3a1686ed9093e0cf4f23fa399"
    end
    # No prebuilt linux-arm64 artifact yet, so build from the release tag.
    on_arm do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.1.tar.gz"
      sha256 "c6cd260dfe7d0c434fbbc5ccf7a258e726b9e22e716dfbc5650f02d24730ccec"
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
