import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    weak var appController: AppController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let ac = appController, ac.sessionController != nil else {
            return .terminateNow
        }
        ac.handleQuitRequest()
        return .terminateLater
    }

    func applicationWillTerminate(_ notification: Notification) {
        menuBarController?.stopAnimation()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func systemWillSleep(_ notification: Notification) {
        appController?.handleSleep()
    }

    @objc private func systemDidWake(_ notification: Notification) {
        appController?.handleWake()
    }

    func linkController(_ controller: AppController) {
        appController = controller
        menuBarController?.appController = controller
    }
}
