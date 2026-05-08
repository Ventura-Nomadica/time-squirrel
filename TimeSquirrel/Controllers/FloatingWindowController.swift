import AppKit
import SwiftUI

final class FloatingWindowController: NSObject, NSWindowDelegate {
    private var panel: NSPanel?
    private weak var appController: AppController?
    private var closingProgrammatically = false

    func open(appController: AppController) {
        self.appController = appController

        if let panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let content = FloatingSessionView().environmentObject(appController)
        let hosting = NSHostingView(rootView: content)
        let contentSize = hosting.fittingSize

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = appController.sessionController?.session.name ?? "Time Squirrel"
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.contentView = hosting
        panel.delegate = self

        if let screen = NSScreen.main {
            let sf = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(
                x: sf.maxX - contentSize.width - 20,
                y: sf.maxY - contentSize.height - 20
            ))
        }

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    func close() {
        closingProgrammatically = true
        panel?.close()
        panel = nil
        closingProgrammatically = false
    }

    func windowWillClose(_ notification: Notification) {
        guard !closingProgrammatically else { return }
        appController?.floatingWindowController = nil
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first(where: { !($0 is NSPanel) })?.makeKeyAndOrderFront(nil)
    }
}
