class Rsrpc < Formula
  desc "Discord Rich Presence server for Linux and macOS"
  homepage "https://github.com/Delnegend/rsRPC"
  version "0.28.1"
  license "MIT"

  livecheck do
    url "https://github.com/Delnegend/rsRPC/releases"
    strategy :github_releases
  end

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.28.1/rsrpc-x86_64-unknown-linux-gnu.zip"
      sha256 "848d153b5a242fe5fea73ca44b2e3e131d8c456549f1a64d9982d5b027e3f97b"
    end
    # No prebuilt linux-arm64 artifact yet, so build from the release tag.
    on_arm do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.28.1.tar.gz"
      sha256 "5ae5e581adc04bfb30e8b0defdb3f013912b943b587daa6110c099fad74f62fd"
      depends_on "rust" => :build
    end
  end

  on_macos do
    on_arm do
      url "https://github.com/Delnegend/rsRPC/releases/download/v0.28.1/rsrpc-aarch64-apple-darwin.zip"
      sha256 "76c4a40d84e6261e70db8c4fff5a93df4e679df4f1628ba3204bb3d8be0bf6e9"
    end
    on_intel do
      url "https://github.com/Delnegend/rsRPC/archive/refs/tags/v0.28.1.tar.gz"
      sha256 "5ae5e581adc04bfb30e8b0defdb3f013912b943b587daa6110c099fad74f62fd"
      depends_on "rust" => :build
    end
  end

  def install
    if File.exist?("Cargo.toml")
      system "cargo", "install", "--path", "crates/cli", *std_cargo_args
      bin.install bin/"rsrpc-cli" => "rsrpc"
    else
      bin.install Dir["rsrpc-*"].fetch(0) => "rsrpc"
    end
  end

  test do
    assert_match "rsrpc-cli #{version}", shell_output("#{bin}/rsrpc --version")
  end
end
