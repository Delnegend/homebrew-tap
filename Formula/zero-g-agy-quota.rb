class ZeroGAgyQuota < Formula
  desc "Push the Antigravity CLI's quota and plan to a Zero-G gateway"
  homepage "https://github.com/Delnegend/zero-g"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on :linux

  on_linux do
    on_intel do
      url "https://github.com/Delnegend/zero-g/releases/download/v1.7.0/zero-g-agy-quota-1.7.0-x86_64-unknown-linux-musl.tar.xz"
      sha256 "bf14244d7b52a535ad66fd1ea788c56ce33a5e58b94a1681f3ff14f65fecbde3"
    end
    on_arm do
      url "https://github.com/Delnegend/zero-g/releases/download/v1.7.0/zero-g-agy-quota-1.7.0-aarch64-unknown-linux-musl.tar.xz"
      sha256 "4a24b9121ddce8b320949592e6acefba70e6827df23b6565f5069bb4bb0c1a7d"
    end
  end

  def install
    bin.install "zero-g-agy-quota"
  end

  service do
    # `opt_bin` survives `brew upgrade`, which `bin` does not.
    run [opt_bin/"zero-g-agy-quota"]
    # One short run every 15 minutes, and one at start. The collector reads
    # ~/.config/zero-g/agy-quota.env, so no secret lives in this formula.
    run_type :interval
    interval 900
    # `agy` is found on the Homebrew PATH.
    environment_variables PATH: std_service_path_env
    log_path var/"log/zero-g-agy-quota.log"
    error_log_path var/"log/zero-g-agy-quota.log"
  end

  def caveats
    <<~EOS
      Create ~/.config/zero-g/agy-quota.env (chmod 600) with:

        ZERO_G_URL=https://your-zero-g.example.com
        ZERO_G_VIRTUAL_KEY=<virtual key without a provider allowlist>
        ZERO_G_AGY_ACCOUNT=<name of the Google Antigravity credential in Zero-G>

      Check it once by hand (prints nothing on success):

        zero-g-agy-quota

      Then report every 15 minutes in the background:

        brew services start zero-g-agy-quota

      Follow the logs with:

        tail -f #{var}/log/zero-g-agy-quota.log
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zero-g-agy-quota --version")
    assert_match "ZERO_G_AGY_ACCOUNT", shell_output("#{bin}/zero-g-agy-quota --help")
    # With no settings the collector refuses to run and names what is missing.
    output = shell_output("#{bin}/zero-g-agy-quota 2>&1", 1)
    assert_match "ZERO_G_URL", output
  end
end
