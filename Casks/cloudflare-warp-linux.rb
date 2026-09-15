cask "cloudflare-warp-linux" do
  arch arm: "arm64", intel: "amd64"

  version "2026.7.1377.0"
  sha256 arm64_linux:  "5593a0d2cf827414a5d7b48c70dba42d4e2f130083b910280eab1932281d0ec6",
         x86_64_linux: "a73429701c47ee9dc3c8307a0ead67054530787239bd71a12e7f93acdbe96f65"

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

  binary "bin/warp-cli"
  binary "bin/warp-dex"
  binary "bin/warp-diag"
  binary "bin/warp-svc"
  binary "bin/warp-taskbar"

  preflight_steps do
    run "/bin/sh", args: [
      "-c",
      <<~SH,
        set -e
        cd "{{staged_path}}"
        deb=$(find . -maxdepth 1 -name "*.deb" -print -quit)
        [ -n "$deb" ] || exit 1
        if command -v dpkg-deb >/dev/null 2>&1; then
          dpkg-deb -x "$deb" .
        elif command -v ar >/dev/null 2>&1; then
          ar x "$deb"
          data_tar=$(find . -maxdepth 1 -name "data.tar.*" -print -quit)
          tar -xf "$data_tar"
          rm -f "$deb" "$data_tar" control.tar.* debian-binary
        fi
        if [ -f "usr/lib/warp/warp-taskbar" ]; then
          printf '%s\n' \
            '#!/bin/sh' \
            'SCRIPT_PATH="$(readlink -f "$0")"' \
            'SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"' \
            'BASE_DIR="$(dirname "$SCRIPT_DIR")"' \
            'export LD_LIBRARY_PATH="{{HOMEBREW_PREFIX}}/lib:${BASE_DIR}/usr/lib/warp/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' \
            'exec "${BASE_DIR}/usr/lib/warp/warp-taskbar" "$@"' \
            > bin/warp-taskbar
          chmod +x bin/warp-taskbar
        fi
        if [ -f "lib/systemd/system/warp-svc.service" ]; then
          sed -i "s|ExecStart=/bin/warp-svc|ExecStart=/usr/local/bin/warp-svc|" lib/systemd/system/warp-svc.service
        fi
        if [ -f "usr/lib/systemd/user/warp-taskbar.service" ]; then
          sed -i "s|ExecStart=/bin/warp-taskbar|ExecStart={{HOMEBREW_PREFIX}}/bin/warp-taskbar|" usr/lib/systemd/user/warp-taskbar.service
        fi
        if [ -f "usr/share/applications/com.cloudflare.WarpTaskbar.desktop" ]; then
          sed -i "s|Exec=/bin/warp-taskbar|Exec={{HOMEBREW_PREFIX}}/bin/warp-taskbar|" usr/share/applications/com.cloudflare.WarpTaskbar.desktop
        fi
        if [ -f "usr/share/applications/com.cloudflare.warp.desktop" ]; then
          sed -i "s|Exec=/bin/warp-cli|Exec={{HOMEBREW_PREFIX}}/bin/warp-cli|" usr/share/applications/com.cloudflare.warp.desktop
        fi
      SH
    ]
  end

  uninstall_preflight_steps do
    run "/bin/sh", args: [
      "-c",
      <<~SH,
        systemctl --user disable --now warp-taskbar.service 2>/dev/null || true
        rm -f "$HOME/.config/systemd/user/warp-taskbar.service"
        rm -f "$HOME/.local/share/applications/com.cloudflare.WarpTaskbar.desktop"
        rm -f "$HOME/.local/share/applications/com.cloudflare.warp.desktop"
        rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/zero-trust-orange.svg"
        systemctl --user daemon-reload 2>/dev/null || true
      SH
    ]
  end

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

    To run warp-svc via systemd (recommended, avoids SELinux restrictions on Fedora/Bazzite):
      sudo cp #{HOMEBREW_PREFIX}/bin/warp-svc /usr/local/bin/warp-svc
      sudo cp #{staged_path}/lib/systemd/system/warp-svc.service /etc/systemd/system/
      sudo systemctl daemon-reload
      sudo systemctl enable --now warp-svc

    Once running, register and connect using warp-cli:
      warp-cli registration new
      warp-cli connect
      warp-cli status
    To use the GUI Taskbar / Tray icon:
      1. Ensure indicator support is installed:
           brew install libayatana-appindicator
      2. Install desktop launcher, icons, and autostart service:
           mkdir -p ~/.config/systemd/user ~/.local/share/applications ~/.local/share/icons/hicolor/scalable/apps
           cp #{staged_path}/usr/lib/systemd/user/warp-taskbar.service ~/.config/systemd/user/
           cp #{staged_path}/usr/share/applications/*.desktop ~/.local/share/applications/
           cp #{staged_path}/usr/share/icons/hicolor/scalable/apps/*.svg ~/.local/share/icons/hicolor/scalable/apps/
           systemctl --user daemon-reload
           systemctl --user enable --now warp-taskbar.service

    To enroll into Cloudflare One (Zero Trust / Teams):
      warp-cli registration token <your-token>
      or
      warp-cli teams-enroll <your-team-name>

    To stop and remove system services upon uninstall:
      sudo systemctl disable --now warp-svc
      sudo rm -f /etc/systemd/system/warp-svc.service /usr/local/bin/warp-svc
      sudo systemctl daemon-reload
  EOS
end
