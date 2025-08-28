import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }

  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    centerTrafficLightsVertically()
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

    // Ensure traffic lights are vertically aligned with our combined custom frame
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.onWindowDidResize(_:)),
      name: NSWindow.didResizeNotification,
      object: self
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.onWindowDidLayout(_:)),
      name: NSWindow.didEndLiveResizeNotification,
      object: self
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.onWindowDidBecomeKey(_:)),
      name: NSWindow.didBecomeKeyNotification,
      object: self
    )
    DispatchQueue.main.async { [weak self] in
      self?.centerTrafficLightsVertically()
    }
  }
}

private extension MainFlutterWindow {
  @objc func onWindowDidResize(_ notification: Notification) {
    centerTrafficLightsVertically()
  }

  @objc func onWindowDidLayout(_ notification: Notification) {
    centerTrafficLightsVertically()
  }

  @objc func onWindowDidBecomeKey(_ notification: Notification) {
    centerTrafficLightsVertically()
  }

  func centerTrafficLightsVertically() {
    guard let closeBtn = self.standardWindowButton(.closeButton),
          let miniBtn = self.standardWindowButton(.miniaturizeButton),
          let zoomBtn = self.standardWindowButton(.zoomButton),
          let container = closeBtn.superview else { return }

    // Use frame-based layout so we can adjust Y
    for btn in [closeBtn, miniBtn, zoomBtn] {
      btn.translatesAutoresizingMaskIntoConstraints = true
      if let sv = btn.superview {
        for c in sv.constraints where (c.firstItem as AnyObject?) === btn || (c.secondItem as AnyObject?) === btn {
          if c.firstAttribute == .top || c.firstAttribute == .centerY || c.firstAttribute == .bottom {
            c.isActive = false
          }
        }
      }
    }

    let superHeight = container.bounds.height
    let buttonHeight = closeBtn.frame.height
    let base = round((superHeight - buttonHeight) / 2.0)
    let y = container.isFlipped ? (base + 6.0) : (base - 6.0)

    for btn in [closeBtn, miniBtn, zoomBtn] {
      var f = btn.frame
      f.origin.y = y
      btn.frame = f
    }
    // Do not trigger layout here; AppKit may reset frames
  }
}

