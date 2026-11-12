class Libjxl < Formula
  desc "JPEG XL reference implementation (cjxl and djxl binaries)"
  homepage "https://github.com/libjxl/libjxl"
  url "https://github.com/libjxl/libjxl/releases/download/v0.13.0/jxl-linux-x86_64-static.tar.lz"
  sha256 "637599dae477dbb4e6d6ee71b0554e8a65c20dc25fd2892cf2bebb935d54d527"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_releases
  end

  depends_on arch: :x86_64
  depends_on :linux

  def install
    bin.install "tools/cjxl", "tools/djxl"
  end

  test do
    assert_match "cjxl v#{version}", shell_output("#{bin}/cjxl --version")
    assert_match "djxl v#{version}", shell_output("#{bin}/djxl --version")

    File.binwrite(testpath/"test.ppm", "P6\n2 2\n255\n" + "\xFF\x00\x00\x00\xFF\x00\x00\x00\xFF\xFF\xFF\xFF".b)
    system bin/"cjxl", testpath/"test.ppm", testpath/"test.jxl"
    assert_path_exists testpath/"test.jxl"
    system bin/"djxl", testpath/"test.jxl", testpath/"output.ppm"
    assert_path_exists testpath/"output.ppm"
  end
end
