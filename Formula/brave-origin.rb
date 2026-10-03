class BraveOrigin < Formula
  desc "Brave browser with every feature enabled (upstream's \"Origin\" build)"
  homepage "https://brave.com/"
  url "https://github.com/brave/brave-browser/releases/download/v1.97.53/brave-origin-1.97.53-linux-amd64.zip"
  sha256 "a02887f323f6782d3efcbb8cfac7ba8bfb8014599dfd7fbf67ebb8d898b28c78"
  license "MPL-2.0"

  livecheck do
    url "https://github.com/brave/brave-browser/releases"
    # Nightly and beta builds ship under the same plain semantic tags as the
    # stable release, so the version has to come from the asset name.
    strategy :github_releases do |releases|
      releases.filter_map do |release|
        release["assets"]&.filter_map do |asset|
          asset["name"][/^brave-origin-(\d+\.\d+\.\d+)-linux-amd64\.zip$/, 1]
        end&.max
      end&.max
    end
  end

  depends_on arch: :x86_64
  depends_on :linux

  def install
    # Desktop entry and icon. Homebrew sandboxes installs to the keg, so these
    # land next to the browser and the caveats give the one-line link into
    # `~/.local/share`, which is where desktop environments actually look.
    icon = "hicolor/256x256/apps/brave-origin.png"
    icon_path = prefix/"share/icons/#{icon}"
    icon_path.dirname.mkpath
    cp "product_logo_256.png", icon_path

    desktop = prefix/"share/applications/brave-origin.desktop"
    desktop.dirname.mkpath
    desktop.write <<~DESKTOP
      [Desktop Entry]
      Type=Application
      Name=Brave Origin
      GenericName=Web Browser
      Comment=Brave browser with every feature enabled
      Exec="#{opt_prefix}/bin/brave-origin" %U
      Icon=brave-origin
      Terminal=false
      StartupNotify=true
      StartupWMClass=Brave Origin
      Categories=Network;WebBrowser;
      MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
    DESKTOP

    # The zip unpacks into the build path as a flat Chromium tree: `brave` is
    # the ELF binary, and everything else (locales, .pak files, resources) is
    # looked up relative to it, so the tree has to stay in one directory.
    libexec.install Dir["*"]
    (bin/"brave-origin").write_env_script libexec/"brave", { "CHROME_WRAPPER" => libexec/"brave-origin" }
  end

  def caveats
    on_linux do
      <<~EOS
        Brave loads the system's Chromium runtime libraries (X11, GTK/glib, NSS,
        Mesa), so it needs a desktop Linux install; the formula only ships the
        browser itself.

        The sandbox helper needs to be a root-owned binary with the set-user-ID
        bit, which Homebrew cannot create inside its prefix. Enable
        unprivileged user namespaces (`sysctl -w kernel.unprivileged_userns_clone=1`)
        or start the browser with `--no-sandbox`.

        The menu entry and its icon ship with the browser, and Homebrew links
        them into `#{HOMEBREW_PREFIX}/share`. Desktop environments only scan
        that directory when it is on `XDG_DATA_DIRS`, so add this to your shell
        profile and log back in -- it also publishes the desktop files of every
        other brew formula:

          export XDG_DATA_DIRS="#{HOMEBREW_PREFIX}/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

        To publish only this one instead, link both files into `~/.local/share`
        (`applications/` and `icons/hicolor/256x256/apps/`), and remove those
        links again when uninstalling.

        The profile lives in `~/.config/BraveSoftware/Brave-Origin`, kept separate
        from a regular Brave install.
      EOS
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/brave-origin --version")
  end
end
