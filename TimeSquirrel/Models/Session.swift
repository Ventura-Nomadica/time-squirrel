import Foundation

enum SessionMode: String, Codable, CaseIterable {
    case stopwatch
    case timer

    var displayName: String {
        switch self {
        case .stopwatch: return "Stopwatch"
        case .timer: return "Timer"
        }
    }
}

struct AlertConfig: Codable, Equatable {
    var targetDuration: TimeInterval?
    var repeatingInterval: TimeInterval?
    var playSound: Bool

    init(
        targetDuration: TimeInterval? = nil,
        repeatingInterval: TimeInterval? = nil,
        playSound: Bool = true
    ) {
        self.targetDuration = targetDuration
        self.repeatingInterval = repeatingInterval
        self.playSound = playSound
    }
}

struct TimerConfig: Codable, Equatable {
    var duration: TimeInterval
    var loops: Bool

    init(duration: TimeInterval, loops: Bool = false) {
        self.duration = duration
        self.loops = loops
    }
}

struct Lap: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var startElapsed: TimeInterval
    var endElapsed: TimeInterval
    var duration: TimeInterval
    var isOpen: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        startElapsed: TimeInterval,
        endElapsed: TimeInterval = 0,
        duration: TimeInterval = 0,
        isOpen: Bool = true
    ) {
        self.id = id
        self.name = name
        self.startElapsed = startElapsed
        self.endElapsed = endElapsed
        self.duration = duration
        self.isOpen = isOpen
    }

    var displayName: String {
        name.isEmpty ? "Lap" : name
    }
}

struct Session: Codable, Identifiable {
    var id: UUID
    var name: String
    var mode: SessionMode

    var startDate: Date
    var endDate: Date?

    var totalElapsed: TimeInterval
    var totalPaused: TimeInterval

    var activeElapsed: TimeInterval {
        max(0, totalElapsed - totalPaused)
    }

    var sleepBehavior: SleepBehavior?
    var timerConfig: TimerConfig?
    var alertConfig: AlertConfig?

    var laps: [Lap]
    var notes: String

    var loopCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        mode: SessionMode,
        startDate: Date = Date(),
        endDate: Date? = nil,
        totalElapsed: TimeInterval = 0,
        totalPaused: TimeInterval = 0,
        sleepBehavior: SleepBehavior? = nil,
        timerConfig: TimerConfig? = nil,
        alertConfig: AlertConfig? = nil,
        laps: [Lap] = [],
        notes: String = "",
        loopCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.mode = mode
        self.startDate = startDate
        self.endDate = endDate
        self.totalElapsed = totalElapsed
        self.totalPaused = totalPaused
        self.sleepBehavior = sleepBehavior
        self.timerConfig = timerConfig
        self.alertConfig = alertConfig
        self.laps = laps
        self.notes = notes
        self.loopCount = loopCount
    }
}

extension TimeInterval {
    var hmsString: String {
        let total = Int(max(0, self))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    var shortString: String {
        let total = Int(max(0, self))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return "\(h)h \(m)m"
        }
        if m > 0 {
            return "\(m)m \(s)s"
        }
        return "\(s)s"
    }
}
