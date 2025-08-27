import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Ensure Flutter surface background is white (prevents black render surface)
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.white.cgColor

    // Ensure the window's contentView backing layer is white as well
    self.contentView?.wantsLayer = true
    self.contentView?.layer?.backgroundColor = NSColor.white.cgColor

    // Ensure white, opaque window background (prevents dark/black window fill)
    self.isOpaque = true
    self.backgroundColor = NSColor.white
    if let aqua = NSAppearance(named: .aqua) {
      self.appearance = aqua
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
