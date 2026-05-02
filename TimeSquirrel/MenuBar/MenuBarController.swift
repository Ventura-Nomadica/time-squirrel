import AppKit
import SwiftUI

final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var animationTimer: Timer?
    private var frameIndex: Int = 0
    private let idleImage: NSImage = MenuBarController.makeMenuBarImage(angle: 0)
    private let animationImages: [NSImage] = (0..<8).map {
        MenuBarController.makeMenuBarImage(angle: Double($0) * 45.0)
    }

    weak var appController: AppController? {
        didSet { rebuildMenu() }
    }

    override init() {
        super.init()
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = idleImage
        statusItem?.button?.imageScaling = .scaleProportionallyDown
        statusItem?.button?.toolTip = "Time Squirrel"
        rebuildMenu()
    }

    func startAnimation() {
        guard animationTimer == nil else { return }
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.frameIndex = (self.frameIndex + 1) % self.animationImages.count
            self.statusItem?.button?.image = self.animationImages[self.frameIndex]
        }
        RunLoop.main.add(animationTimer!, forMode: .common)
    }

    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        frameIndex = 0
        statusItem?.button?.image = idleImage
    }

    func rebuildMenu() {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "Time Squirrel", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        if let ac = appController, ac.sessionController != nil {
            let sessionItem = NSMenuItem(
                title: "Session running",
                action: #selector(bringToFront),
                keyEquivalent: ""
            )
            sessionItem.target = self
            menu.addItem(sessionItem)
            menu.addItem(.separator())
        }

        let showItem = NSMenuItem(
            title: "Open Time Squirrel",
            action: #selector(bringToFront),
            keyEquivalent: ""
        )
        showItem.target = self
        menu.addItem(showItem)

        let settingsItem = NSMenuItem(
            title: "Settings",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.keyEquivalentModifierMask = .command
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Time Squirrel",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func bringToFront() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }

    @objc private func openSettings() {
        bringToFront()
        appController?.showSettings = true
    }

    // Draws a simple clock-face icon at a given sweep angle (degrees).
    // At 0° the hand points up (12 o'clock). This creates the animation frames.
    private static func makeMenuBarImage(angle: Double) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius: CGFloat = 7.5
            let handLen: CGFloat = 5.5

            // Circle outline
            let circlePath = NSBezierPath(
                ovalIn: CGRect(x: center.x - radius, y: center.y - radius,
                               width: radius * 2, height: radius * 2)
            )
            NSColor.labelColor.setStroke()
            circlePath.lineWidth = 1.2
            circlePath.stroke()

            // Clock hand
            let radians = (angle - 90) * .pi / 180
            let handEnd = CGPoint(
                x: center.x + handLen * cos(radians),
                y: center.y + handLen * sin(radians)
            )
            let handPath = NSBezierPath()
            handPath.move(to: center)
            handPath.line(to: handEnd)
            NSColor.labelColor.setStroke()
            handPath.lineWidth = 1.5
            handPath.lineCapStyle = .round
            handPath.stroke()

            return true
        }
        image.isTemplate = true
        return image
    }
}
