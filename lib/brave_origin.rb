# frozen_string_literal: true

# Shared body for the Brave Origin channels. The upstream stable, beta and
# nightly releases differ only in the asset name, so each formula declares its
# channel with `channel "brave-origin-beta"` and inherits the rest: the flat
# Chromium tree, the launcher in bin, and the desktop entry.
class BraveOriginFormula < Formula
  # Shared defaults; every channel formula overrides both.
  desc "Brave browser with every feature enabled"
  homepage "https://brave.com/"

  class << self
    attr_reader :channel_name
  end

  # Declares this formula's channel and its livecheck. The asset name carries
  # the version, which is what makes the check work: nightly and beta builds
  # ship under the same plain semantic tags as the stable release, so the
  # newest tag is usually a build this formula does not track.
  def self.channel(name)
    @channel_name = name
    livecheck do
      url "https://github.com/brave/brave-browser/releases"
      strategy :github_releases do |releases|
        BraveOriginFormula.channel_versions(releases, name)
      end
    end
  end

  # Highest version that actually ships this channel's Linux archive. Versions
  # are compared numerically; a plain string sort puts 1.9.10 below 1.99.9.
  def self.channel_versions(releases, name)
    pattern = /\A#{Regexp.escape(name)}-(\d+\.\d+\.\d+)-linux-amd64\.zip\z/
    versions = releases.flat_map do |release|
      release["assets"].to_a.filter_map { |asset| asset["name"][pattern, 1] }
    end
    versions.max_by { Gem::Version.new(it) }
  end

  def channel = self.class.channel_name

  # "brave-origin-nightly" -> "Brave Origin Nightly"
  def display_name = channel.split("-").map(&:capitalize).join(" ")

  # Upstream names the 256px brand logo `product_logo_256.png` for the stable
  # channel and appends the channel with an underscore for the others, e.g.
  # `product_logo_256_beta.png`.
  def logo_file = "product_logo_256#{channel.delete_prefix('brave-origin').tr('-', '_')}.png"

  def install
    # Desktop entry and icon. Homebrew sandboxes installs to the keg, so these
    # land next to the browser and the caveats give the one-line link into
    # `~/.local/share`, which is where desktop environments actually look. The
    # icon is copied before the tree install, which empties the build path.
    icon_path = prefix/"share/icons/hicolor/256x256/apps/#{channel}.png"
    icon_path.dirname.mkpath
    cp logo_file, icon_path

    desktop = prefix/"share/applications/#{channel}.desktop"
    desktop.dirname.mkpath
    desktop.write <<~DESKTOP
      [Desktop Entry]
      Type=Application
      Name=#{display_name}
      GenericName=Web Browser
      Comment=Brave browser with every feature enabled
      Exec="#{opt_prefix}/bin/#{channel}" %U
      Icon=#{channel}
      Terminal=false
      StartupNotify=true
      StartupWMClass=#{display_name}
      Categories=Network;WebBrowser;
      MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
    DESKTOP

    # The zip unpacks into the build path as a flat Chromium tree: `brave` is
    # the ELF binary, and everything else (locales, .pak files, resources) is
    # looked up relative to it, so the tree has to stay in one directory.
    libexec.install Dir["*"]
    (bin/channel).write_env_script libexec/"brave", { "CHROME_WRAPPER" => libexec/channel }
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

        All three channels share one profile directory,
        `~/.config/BraveSoftware/Brave-Origin`. Start them with separate
        `--user-data-dir` arguments if you want to keep them apart.
      EOS
    end
  end
end
