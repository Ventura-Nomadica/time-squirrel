import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appController: AppController

    var body: some View {
        Group {
            switch appController.screen {
            case .firstRun:
                FirstRunView()
            case .idle:
                IdleView()
            case .stopwatchSetup:
                StopwatchSetupView()
            case .timerSetup:
                TimerSetupView()
            case .activeStopwatch:
                ActiveStopwatchView()
            case .activeTimer:
                ActiveTimerView()
            case .history:
                HistoryView()
            }
        }
        .frame(minWidth: 640, minHeight: 480)
        .sheet(isPresented: $appController.showSettings) {
            SettingsView()
                .environmentObject(appController)
                .frame(width: 520, height: 560)
        }
        .sheet(isPresented: $appController.showAbout) {
            AboutView()
                .frame(width: 400, height: 320)
        }
        .sheet(isPresented: $appController.showKeyboardShortcuts) {
            KeyboardShortcutsView()
                .frame(width: 400, height: 320)
        }
        .sheet(isPresented: $appController.showQuitConfirm) {
            QuitConfirmView()
                .environmentObject(appController)
                .frame(width: 380, height: 180)
        }
        .onAppear {
            if let delegate = NSApp.delegate as? AppDelegate {
                delegate.linkController(appController)
                appController.appDelegate = delegate
            }
            NotificationManager.shared.requestAuthorization()
            SparkleController.shared.configure(updateBehavior: appController.settings.updateBehavior)
        }
    }
}

struct QuitConfirmView: View {
    @EnvironmentObject var appController: AppController

    var body: some View {
        VStack(spacing: 20) {
            Text("A session is running.")
                .font(.headline)
            Text("Save the session before quitting, or cancel to return.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Button("Cancel") {
                    appController.showQuitConfirm = false
                    appController.cancelQuit()
                }
                .keyboardShortcut(.escape)

                Button("Save and Quit") {
                    appController.showQuitConfirm = false
                    appController.handleSaveAndQuit()
                }
                .keyboardShortcut(.return)
                
            }
        }
        .padding(28)
    }
}

struct KeyboardShortcutsView: View {
    @Environment(\.presentationMode) var presentationMode

    private let shortcuts: [(String, String)] = [
        ("⌘,", "Settings"),
        ("⇧⌘H", "History"),
        ("⌘Q", "Quit"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.title2).bold()
                Spacer()
                Button("Done") { presentationMode.wrappedValue.dismiss() }
            }
            .padding(.bottom, 20)

            ForEach(shortcuts, id: \.0) { item in
                HStack {
                    Text(item.1)
                    Spacer()
                    Text(item.0)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                Divider()
            }
            Spacer()
        }
        .padding(28)
    }
}
