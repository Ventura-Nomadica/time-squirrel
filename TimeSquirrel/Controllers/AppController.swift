import SwiftUI
import Combine

enum AppScreen: Equatable {
    case firstRun
    case idle
    case stopwatchSetup
    case timerSetup
    case activeStopwatch
    case activeTimer
    case history
}

final class AppController: ObservableObject {

    // MARK: - Navigation
    @Published var screen: AppScreen = .idle
    @Published var showSettings = false
    @Published var showAbout = false
    @Published var showKeyboardShortcuts = false
    @Published var showResetConfirm = false
    @Published var showQuitConfirm = false

    // MARK: - State
    @Published var settings: AppSettings
    @Published var sessionController: SessionController?
    @Published private(set) var historyStore: HistoryStore

    // MARK: - Weak link to AppDelegate for menu bar
    weak var appDelegate: AppDelegate?

    private var cancellables = Set<AnyCancellable>()
    private var sessionCancellable: AnyCancellable?

    init() {
        let s = SettingsStore.shared.load()
        self.settings = s
        let store = HistoryStore(saveLocationPath: s.saveLocationPath)
        self.historyStore = store

        if !s.firstRunComplete {
            self.screen = .firstRun
        } else if SessionRecoveryStore.shared.hasRecoveryState {
            restoreSession()
        } else {
            self.screen = .idle
        }

        // Forward nested store changes so observing views refresh
        store.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Navigation
    func navigate(to destination: AppScreen) {
        screen = destination
    }

    // MARK: - Session lifecycle
    func startStopwatch(
        name: String,
        sleepBehavior: SleepBehavior,
        alertConfig: AlertConfig?
    ) {
        let session = Session(
            name: name,
            mode: .stopwatch,
            startDate: Date(),
            sleepBehavior: sleepBehavior,
            alertConfig: alertConfig
        )
        let sc = SessionController(session: session)
        wireSessionController(sc)
        sessionController = sc
        screen = .activeStopwatch
        sc.writeRecoveryNow()
        appDelegate?.menuBarController?.startAnimation()
        appDelegate?.menuBarController?.rebuildMenu()
    }

    func startTimer(
        name: String,
        timerConfig: TimerConfig,
        alertConfig: AlertConfig?
    ) {
        let session = Session(
            name: name,
            mode: .timer,
            startDate: Date(),
            timerConfig: timerConfig,
            alertConfig: alertConfig
        )
        let sc = SessionController(session: session)
        wireSessionController(sc)
        sessionController = sc
        screen = .activeTimer
        sc.writeRecoveryNow()
        appDelegate?.menuBarController?.startAnimation()
        appDelegate?.menuBarController?.rebuildMenu()
    }

    func handleStop() {
        guard let sc = sessionController else { return }
        let finalSession = sc.finalize()
        sessionController = nil
        sessionCancellable = nil
        appDelegate?.menuBarController?.stopAnimation()
        appDelegate?.menuBarController?.rebuildMenu()

        let saveDir = URL(fileURLWithPath: settings.saveLocationPath, isDirectory: true)
        do {
            _ = try ExportWriter.write(session: finalSession, to: saveDir)
        } catch {
            // Failure to export is non-fatal; session data is not lost here
        }

        historyStore.reload()
        screen = .idle
    }

    func handleReset() {
        guard let sc = sessionController else { return }
        sc.discard()
        sessionController = nil
        sessionCancellable = nil
        appDelegate?.menuBarController?.stopAnimation()
        appDelegate?.menuBarController?.rebuildMenu()
        screen = .idle
    }

    func handleSaveAndQuit() {
        guard let sc = sessionController else {
            NSApp.reply(toApplicationShouldTerminate: true)
            return
        }
        let finalSession = sc.finalize()
        sessionController = nil
        sessionCancellable = nil

        let saveDir = URL(fileURLWithPath: settings.saveLocationPath, isDirectory: true)
        _ = try? ExportWriter.write(session: finalSession, to: saveDir)

        NSApp.reply(toApplicationShouldTerminate: true)
    }

    func handleQuitRequest() {
        if sessionController != nil {
            showQuitConfirm = true
        } else {
            NSApp.reply(toApplicationShouldTerminate: true)
        }
    }

    func cancelQuit() {
        NSApp.reply(toApplicationShouldTerminate: false)
    }

    // MARK: - Settings
    func updateSettings(_ updated: AppSettings) {
        let old = settings
        settings = updated
        SettingsStore.shared.save(updated)

        if old.saveLocationPath != updated.saveLocationPath {
            historyStore.updateSaveLocation(updated.saveLocationPath)
        }

        if old.appearance != updated.appearance {
            applyAppearance(updated.appearance)
        }
    }

    func completeFirstRun(settings newSettings: AppSettings) {
        var s = newSettings
        s.firstRunComplete = true
        updateSettings(s)
        screen = .idle
    }

    // MARK: - Sleep / Wake
    func handleSleep() {
        sessionController?.handleSleep()
    }

    func handleWake() {
        sessionController?.handleWake()
    }

    // MARK: - Private helpers
    private func restoreSession() {
        guard let recovery = SessionRecoveryStore.shared.load() else {
            screen = .idle
            return
        }
        let sc = SessionController(recovery: recovery)
        wireSessionController(sc)
        sessionController = sc
        screen = recovery.mode == .stopwatch ? .activeStopwatch : .activeTimer
        appDelegate?.menuBarController?.startAnimation()
        appDelegate?.menuBarController?.rebuildMenu()
    }

    private func wireSessionController(_ sc: SessionController) {
        // Forward every tick so active-session views stay live.
        sessionCancellable = sc.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }

        sc.onAlertFired = { [weak self] message in
            NotificationManager.shared.post(title: "Time Squirrel", body: message)
        }
        sc.onTimerCompleted = { [weak self] in
            guard let self else { return }
            NotificationManager.shared.post(title: "Time Squirrel", body: "Timer complete.")
            self.handleStop()
        }
        sc.onSleepStop = { [weak self] in
            guard let self else { return }
            NotificationManager.shared.post(
                title: "Time Squirrel",
                body: "Session stopped because your Mac went to sleep."
            )
            self.handleStop()
        }
    }

    private func applyAppearance(_ appearance: Appearance) {
        switch appearance {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

// Allow SessionController to trigger an immediate save (used on session start)
extension SessionController {
    func writeRecoveryNow() {
        let state = RecoveryState(
            sessionID: session.id,
            mode: session.mode,
            name: session.name,
            startDate: session.startDate,
            pauseDate: nil,
            totalPaused: 0,
            isPaused: false,
            laps: [],
            notes: session.notes,
            alertConfig: session.alertConfig,
            timerConfig: session.timerConfig,
            sleepBehavior: session.sleepBehavior,
            loopCount: 0,
            openLapStartElapsed: nil,
            lastAlertFiredAt: nil,
            targetAlertFired: false,
            lastWrittenAt: Date()
        )
        SessionRecoveryStore.shared.save(state)
    }
}
