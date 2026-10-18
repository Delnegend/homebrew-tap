class Rsrpc < Formula
  desc "Discord Rich Presence server for Linux and macOS"
  homepage "https://github.com/Delnegend/rsRPC"
  version "0.29.2"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.2/rsrpc-0.29.2-aarch64-apple-darwin.zip"
      sha256 "3d1cd7b47dcd4b608ec811366529951ed5e523e111370be8e38fce67185e9a5d"
    end
    # No prebuilt macos-x86_64 artifact yet, so build from the release tag.
    on_intel do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.2.tar.gz"
      sha256 "173dc5b7121e6f9ab598aeba11fc930ba50cd417112d61d21236fd68cc6ee1f6"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.29.2/rsrpc-0.29.2-x86_64-unknown-linux-gnu.zip"
      sha256 "c597fe1b241d3c1f51ac9aaba693029cc3819d631a9b06f520561886268d5c02"
    end
    # No prebuilt linux-arm64 artifact yet, so build from the release tag.
    on_arm do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.29.2.tar.gz"
      sha256 "173dc5b7121e6f9ab598aeba11fc930ba50cd417112d61d21236fd68cc6ee1f6"
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
      bin.install Dir["rsrpc-*"].fetch(0) => "rsrpc"
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
