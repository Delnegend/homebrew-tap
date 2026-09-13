class Winbox < Formula
  desc "Configuration utility for MikroTik RouterOS devices"
  homepage "https://mikrotik.com/software"
  version "4.3"
  license :cannot_represent

  depends_on :linux

  on_linux do
    on_intel do
      url "https://download.mikrotik.com/routeros/winbox/4.3/WinBox_Linux.zip"
      sha256 "573600ac24df38a7a06ea4318b12754247eec4b54c6c90b0a57100d676787a4c"
    end
  end

  def install
    bin.install "WinBox" => "winbox"
    pkgshare.install "assets" if File.exist?("assets")
  end

  test do
    assert_path_exists bin/"winbox"
  end
end
