import Foundation

struct RecoveryState: Codable {
    var sessionID: UUID
    var mode: SessionMode
    var name: String
    var startDate: Date
    var pauseDate: Date?
    var totalPaused: TimeInterval
    var isPaused: Bool
    var laps: [Lap]
    var notes: String
    var alertConfig: AlertConfig?
    var timerConfig: TimerConfig?
    var sleepBehavior: SleepBehavior?
    var loopCount: Int
    var openLapStartElapsed: TimeInterval?
    var lastAlertFiredAt: TimeInterval?
    var targetAlertFired: Bool
    var lastWrittenAt: Date
}

final class SessionRecoveryStore {
    static let shared = SessionRecoveryStore()

    private let fileURL: URL

    private init() {
        let support = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        let dir = support.appendingPathComponent("TimeSquirrel", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("active-session.json")
    }

    var hasRecoveryState: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    func load() -> RecoveryState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(RecoveryState.self, from: data)
    }

    func save(_ state: RecoveryState) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
        do {
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
        } catch {
            assertionFailure("Failed to set permissions on recovery file: \(error)")
        }
    }

    func delete() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
