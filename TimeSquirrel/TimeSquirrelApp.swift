import SwiftUI

@main
struct TimeSquirrelApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appController = AppController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appController)
                .frame(minWidth: 640, minHeight: 480)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Time Squirrel") {
                    appController.showAbout = true
                }
            }
            CommandGroup(replacing: .systemServices) { }
            TimeSquirrelCommands(appController: appController)
        }
    }
}

struct TimeSquirrelCommands: Commands {
    @ObservedObject var appController: AppController

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Divider()
            Button("Settings") {
                appController.showSettings = true
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        CommandMenu("History") {
            Button("Show History") {
                appController.navigate(to: .history)
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])
        }

        CommandGroup(replacing: .help) {
            Button("Keyboard Shortcuts") {
                appController.showKeyboardShortcuts = true
            }
            Link("Time Squirrel on GitHub",
                 destination: URL(string: "https://github.com/Ventura-Nomadica/time-squirrel")!)
        }
    }
}
