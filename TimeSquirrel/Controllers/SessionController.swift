import Foundation
import Combine

enum SessionState: Equatable {
    case running
    case paused
}

final class SessionController: ObservableObject {

    // MARK: - Published state
    @Published private(set) var session: Session
    @Published private(set) var state: SessionState = .running
    @Published private(set) var currentElapsed: TimeInterval = 0
    @Published private(set) var currentLapElapsed: TimeInterval = 0

    // MARK: - Private timing
    private var sessionStartDate: Date
    private var pauseDate: Date?
    private var accumulatedPaused: TimeInterval = 0
    private var openLapStartElapsed: TimeInterval?

    // MARK: - Alert tracking
    private var targetAlertFired = false
    private var lastRepeatingAlertAt: TimeInterval = 0

    // MARK: - Timer
    private var displayTimer: Timer?
    private var saveWorkItem: DispatchWorkItem?

    // MARK: - Callbacks
    var onAlertFired: ((String) -> Void)?
    var onTimerCompleted: (() -> Void)?
    var onSleepStop: (() -> Void)?

    // MARK: - Init (new session)
    init(session: Session) {
        self.session = session
        self.sessionStartDate = session.startDate
        self.accumulatedPaused = 0
        self.pauseDate = nil
        startDisplayTimer()
    }

    // MARK: - Init (recovered session)
    init(recovery: RecoveryState) {
        let s = Session(
            id: recovery.sessionID,
            name: recovery.name,
            mode: recovery.mode,
            startDate: recovery.startDate,
            totalElapsed: 0,
            totalPaused: recovery.totalPaused,
            sleepBehavior: recovery.sleepBehavior,
            timerConfig: recovery.timerConfig,
            alertConfig: recovery.alertConfig,
            laps: recovery.laps,
            notes: recovery.notes,
            loopCount: recovery.loopCount
        )
        self.session = s
        self.sessionStartDate = recovery.startDate
        self.accumulatedPaused = recovery.totalPaused
        self.openLapStartElapsed = recovery.openLapStartElapsed

        self.targetAlertFired = recovery.targetAlertFired
        self.lastRepeatingAlertAt = recovery.lastAlertFiredAt ?? 0

        if recovery.isPaused, let pd = recovery.pauseDate {
            self.pauseDate = pd
            self.state = .paused
        } else {
            self.pauseDate = nil
            self.state = .running
        }
        startDisplayTimer()
    }

    deinit {
        displayTimer?.invalidate()
    }

    // MARK: - Computed elapsed
    var elapsed: TimeInterval {
        if let pd = pauseDate {
            return max(0, pd.timeIntervalSince(sessionStartDate) - accumulatedPaused)
        }
        return max(0, Date().timeIntervalSince(sessionStartDate) - accumulatedPaused)
    }

    var remaining: TimeInterval {
        guard let tc = session.timerConfig else { return 0 }
        let loopOffset = Double(session.loopCount) * tc.duration
        return max(0, tc.duration - (elapsed - loopOffset))
    }

    // MARK: - Controls
    func pause() {
        guard state == .running else { return }
        pauseDate = Date()
        state = .paused
        scheduleSave()
    }

    func resume() {
        guard state == .paused, let pd = pauseDate else { return }
        accumulatedPaused += Date().timeIntervalSince(pd)
        pauseDate = nil
        state = .running
        scheduleSave()
    }

    func captureLap() {
        let now = elapsed
        if let lapStart = openLapStartElapsed {
            // Close the open lap
            if let idx = session.laps.lastIndex(where: { $0.isOpen }) {
                session.laps[idx].endElapsed = now
                session.laps[idx].duration = now - lapStart
                session.laps[idx].isOpen = false
            }
        }
        // Open a new lap
        let newLap = Lap(startElapsed: now)
        session.laps.append(newLap)
        openLapStartElapsed = now
        scheduleSave()
    }

    func renameLap(_ lapID: UUID, name: String) {
        if let idx = session.laps.firstIndex(where: { $0.id == lapID }) {
            session.laps[idx].name = name
            scheduleSave()
        }
    }

    func updateNotes(_ text: String) {
        session.notes = text
        scheduleSave()
    }

    // MARK: - Sleep handling
    func handleSleep() {
        switch session.sleepBehavior {
        case .pause:
            if state == .running { pause() }
        case .stop:
            onSleepStop?()
        case .continue, .none:
            break
        }
        if session.mode == .timer && state == .running {
            pause()
        }
    }

    func handleWake() {
        // For pause behavior: resume is user-initiated; for auto-pause-on-sleep we resume
        if session.sleepBehavior == .pause && state == .paused {
            resume()
        }
        // Timer always paused on sleep — user resumes manually
    }

    // MARK: - Finalize
    func finalize() -> Session {
        displayTimer?.invalidate()
        displayTimer = nil
        closeOpenLap()

        let now = Date()
        session.endDate = now
        session.totalElapsed = elapsed
        session.totalPaused = accumulatedPaused
        SessionRecoveryStore.shared.delete()
        return session
    }

    func discard() {
        displayTimer?.invalidate()
        displayTimer = nil
        SessionRecoveryStore.shared.delete()
    }

    // MARK: - Private
    private func startDisplayTimer() {
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(displayTimer!, forMode: .common)
    }

    private func tick() {
        let e = elapsed
        currentElapsed = e
        currentLapElapsed = e - (openLapStartElapsed ?? 0)
        session.totalElapsed = e
        session.totalPaused = accumulatedPaused

        checkAlerts(elapsed: e)
        checkTimerCompletion(elapsed: e)
    }

    private func checkAlerts(elapsed: TimeInterval) {
        guard let ac = session.alertConfig else { return }

        if let target = ac.targetDuration, !targetAlertFired, elapsed >= target {
            targetAlertFired = true
            onAlertFired?("Reached \(target.hmsString)")
        }

        if let interval = ac.repeatingInterval, interval > 0 {
            let nextFire = lastRepeatingAlertAt + interval
            if elapsed >= nextFire {
                lastRepeatingAlertAt = elapsed
                onAlertFired?("Interval: \(interval.hmsString)")
            }
        }
    }

    private func checkTimerCompletion(elapsed: TimeInterval) {
        guard session.mode == .timer, let tc = session.timerConfig, state == .running else { return }
        let loopElapsed = elapsed - Double(session.loopCount) * tc.duration
        guard loopElapsed >= tc.duration else { return }

        if tc.loops {
            session.loopCount += 1
            lastRepeatingAlertAt = elapsed
            onAlertFired?("Loop \(session.loopCount) complete")
        } else {
            onTimerCompleted?()
        }
    }

    private func closeOpenLap() {
        guard let lapStart = openLapStartElapsed,
              let idx = session.laps.lastIndex(where: { $0.isOpen }) else { return }
        let e = elapsed
        session.laps[idx].endElapsed = e
        session.laps[idx].duration = e - lapStart
        session.laps[idx].isOpen = false
        openLapStartElapsed = nil
    }

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.writeRecovery() }
        saveWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    private func writeRecovery() {
        let state = RecoveryState(
            sessionID: session.id,
            mode: session.mode,
            name: session.name,
            startDate: sessionStartDate,
            pauseDate: pauseDate,
            totalPaused: accumulatedPaused,
            isPaused: self.state == .paused,
            laps: session.laps,
            notes: session.notes,
            alertConfig: session.alertConfig,
            timerConfig: session.timerConfig,
            sleepBehavior: session.sleepBehavior,
            loopCount: session.loopCount,
            openLapStartElapsed: openLapStartElapsed,
            lastAlertFiredAt: lastRepeatingAlertAt,
            targetAlertFired: targetAlertFired,
            lastWrittenAt: Date()
        )
        SessionRecoveryStore.shared.save(state)
    }
}
