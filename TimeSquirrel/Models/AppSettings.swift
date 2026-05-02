import Foundation

enum UpdateBehavior: String, Codable, CaseIterable {
    case manual
    case automatic

    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .automatic: return "Automatic"
        }
    }

    var description: String {
        switch self {
        case .manual:
            return "Check for updates manually. No background network requests."
        case .automatic:
            return "Check for updates in the background when you launch the app."
        }
    }
}

enum Appearance: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

enum SleepBehavior: String, Codable, CaseIterable {
    case pause
    case `continue`
    case stop

    var displayName: String {
        switch self {
        case .pause: return "Pause"
        case .continue: return "Continue"
        case .stop: return "Stop"
        }
    }

    var description: String {
        switch self {
        case .pause:
            return "Pause the stopwatch when your Mac sleeps. Resume when it wakes."
        case .continue:
            return "Keep the clock running through sleep. Elapsed time includes sleep."
        case .stop:
            return "Stop the session when your Mac sleeps. Save manually when you return."
        }
    }
}

struct CustomTimerPreset: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var duration: TimeInterval

    init(id: UUID = UUID(), name: String, duration: TimeInterval) {
        self.id = id
        self.name = name
        self.duration = duration
    }
}

struct AppSettings: Codable, Equatable {
    var firstRunComplete: Bool
    var updateBehavior: UpdateBehavior
    var saveLocationPath: String
    var defaultSleepBehavior: SleepBehavior
    var customTimerPresets: [CustomTimerPreset]
    var appearance: Appearance
    var fontSize: Double

    static var defaultSettings: AppSettings {
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        let path = docs.appendingPathComponent("TimeSquirrel").path
        return AppSettings(
            firstRunComplete: false,
            updateBehavior: .manual,
            saveLocationPath: path,
            defaultSleepBehavior: .pause,
            customTimerPresets: [],
            appearance: .system,
            fontSize: 15.0
        )
    }
}
