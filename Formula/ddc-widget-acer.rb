class DdcWidgetAcer < Formula
  desc "Unofficial menu bar app to control Acer monitors over DDC/CI"
  homepage "https://github.com/JustBoryata/ddc-widget-acer"
  url "https://github.com/JustBoryata/ddc-widget-acer/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "611796dc332e67cd21689dbda99b01dee52460269f9bf42915bb44c4c594d26b"
  license "MIT"

  # DDC goes through IOAVService, which only exists on Apple Silicon.
  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    cd "app" do
      system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "DDCWidget"
      system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "acer-ddc"
      app = prefix/"DDC Widget.app"
      (app/"Contents/MacOS").install ".build/release/DDCWidget"
      (app/"Contents").install "Resources/Info.plist"
      system "codesign", "--force", "--sign", "-", app
      bin.install ".build/release/acer-ddc"
    end
  end

  def caveats
    <<~EOS
      To add the app to Applications and start it:
        ln -sf "#{opt_prefix}/DDC Widget.app" /Applications/
        open "/Applications/DDC Widget.app"
      The monitor needs DDC/CI turned on in its own menu.
      For the HDR / Local Dimming toggles, see the one-time monitor setup:
        https://github.com/JustBoryata/ddc-widget-acer#one-time-monitor-setup-for-the-hdr--local-dimming-toggles
      Unofficial; not affiliated with Acer.
    EOS
  end

  test do
    assert_match "usage", shell_output("#{bin}/acer-ddc 2>&1", 2)
  end
end
