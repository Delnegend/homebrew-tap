class ZeroGAgyIntegration < Formula
  desc "Report the Antigravity CLI's quota, plan and usage to a Zero-G gateway"
  homepage "https://github.com/Delnegend/zero-g"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/zero-g/releases/download/v1.9.0/zero-g-agy-integration-1.9.0-x86_64-unknown-linux-musl.tar.xz"
      sha256 "8e9b82c40ae00bfda54bde939f693d86874561aae738c7e7d5da50c6ba6c5b8d"
    end
    on_arm do
      url "https://github.com/Delnegend/zero-g/releases/download/v1.9.0/zero-g-agy-integration-1.9.0-aarch64-unknown-linux-musl.tar.xz"
      sha256 "6048280c2e4acd5066dfd28b62f94e3c8146a95f48b8309ef05556598f3764cc"
    end
  end

  def install
    bin.install "zero-g-agy-integration"
  end

  service do
    # `opt_bin` survives `brew upgrade`, which `bin` does not.
    run [opt_bin/"zero-g-agy-integration", "quota"]
    # One short run every 15 minutes, and one at start. The program reads
    # ~/.config/zero-g/agy-integration.env, so no secret lives in this formula.
    run_type :interval
    interval 900
    # `agy` is found on the Homebrew PATH.
    environment_variables PATH: std_service_path_env
    log_path var/"log/zero-g-agy-integration.log"
    error_log_path var/"log/zero-g-agy-integration.log"
  end

  def caveats
    <<~EOS
      Create ~/.config/zero-g/agy-integration.env (chmod 600) with:

        ZERO_G_URL=https://your-zero-g.example.com
        ZERO_G_VIRTUAL_KEY=<virtual key without a provider allowlist>
        ZERO_G_AGY_ACCOUNT=<name of the Google Antigravity credential in Zero-G>

      Check the quota report once by hand (prints nothing on success):

        zero-g-agy-integration quota

      Then report every 15 minutes in the background:

        brew services start zero-g-agy-integration

      To record agy's model responses too, add this hook to
      ~/.gemini/config/hooks.json (keep your existing hooks):

        "zero-g-observations": {
          "PostInvocation": [
            { "type": "command", "command": "zero-g-agy-integration observe", "timeout": 5 }
          ]
        }

      Follow the logs with:

        tail -f #{var}/log/zero-g-agy-integration.log
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zero-g-agy-integration --version")
    assert_match "ZERO_G_AGY_ACCOUNT", shell_output("#{bin}/zero-g-agy-integration --help")
    # With no settings, `quota` refuses and names what is missing.
    assert_match "ZERO_G_URL", shell_output("#{bin}/zero-g-agy-integration quota 2>&1", 1)
    # The hook stays silent and succeeds whatever goes wrong.
    assert_equal "{}\n", shell_output("#{bin}/zero-g-agy-integration observe </dev/null")
  end
end
