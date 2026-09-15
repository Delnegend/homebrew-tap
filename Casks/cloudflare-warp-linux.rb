cask "cloudflare-warp-linux" do
  arch arm: "arm64", intel: "amd64"

  version "2026.7.1377.0"
  sha256 arm:   "5593a0d2cf827414a5d7b48c70dba42d4e2f130083b910280eab1932281d0ec6",
         intel: "a73429701c47ee9dc3c8307a0ead67054530787239bd71a12e7f93acdbe96f65"

  url "https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_#{version}_#{arch}.deb"
  name "Cloudflare WARP"
  desc "Free app that makes your Internet safer"
  homepage "https://cloudflarewarp.com/"

  livecheck do
    url "https://pkg.cloudflareclient.com/dists/noble/main/binary-amd64/Packages"
    regex(/cloudflare-warp[._-]v?(\d+(?:\.\d+)+)[._-]amd64\.deb/i)
  end

  conflicts_with cask: "cloudflare-warp"
  depends_on :linux
  container type: :naked

  binary "usr/bin/warp-cli"
  binary "usr/bin/warp-dex"
  binary "usr/bin/warp-diag"
  binary "usr/bin/warp-svc"

  preflight_steps do
    run "/bin/sh", args: [
      "-c",
      <<~SH,
        set -e
        deb=$(find . -maxdepth 1 -name "*.deb" -print -quit)
        [ -n "$deb" ] || exit 1
        if command -v dpkg-deb >/dev/null 2>&1; then
          dpkg-deb -x "$deb" .
        elif command -v ar >/dev/null 2>&1; then
          ar x "$deb"
          data_tar=$(find . -maxdepth 1 -name "data.tar.*" -print -quit)
          tar -xf "$data_tar"
        fi
        for b in warp-cli warp-dex warp-diag warp-svc; do
          if [ -f "bin/$b" ] && [ ! -f "usr/bin/$b" ]; then
            mkdir -p usr/bin
            cp "bin/$b" "usr/bin/$b"
          fi
        done
      SH
    ]
  end

  uninstall quit:   [
              "com.cloudflare.Warp",
              "warp-svc",
            ],
            delete: [
              "#{HOMEBREW_PREFIX}/bin/warp-cli",
              "#{HOMEBREW_PREFIX}/bin/warp-dex",
              "#{HOMEBREW_PREFIX}/bin/warp-diag",
              "#{HOMEBREW_PREFIX}/bin/warp-svc",
            ]

  zap trash: [
    "/etc/cloudflare-warp",
    "/var/lib/cloudflare-warp",
    "/var/log/cloudflare-warp",
    "~/.cache/cloudflare-warp",
    "~/.config/cloudflare-warp",
    "~/.local/share/cloudflare-warp",
  ]

  caveats <<~EOS
    Cloudflare WARP requires the background service (warp-svc) to be running.

    To run warp-svc manually:
      sudo warp-svc

    To enable and start warp-svc via systemd, copy or symlink the service file:
      sudo cp #{staged_path}/lib/systemd/system/warp-svc.service /etc/systemd/system/
      sudo systemctl daemon-reload
      sudo systemctl enable --now warp-svc

    Once running, register and connect using warp-cli:
      warp-cli registration new
      warp-cli connect
      warp-cli status
  EOS
end
