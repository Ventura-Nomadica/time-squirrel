import Foundation

final class SettingsStore {
    static let shared = SettingsStore()

    private let fileURL: URL

    private init() {
        let support = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        let dir = support.appendingPathComponent("TimeSquirrel", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("settings.json")
    }

    private var bookmarkFileURL: URL {
        fileURL.deletingLastPathComponent().appendingPathComponent("save-folder-bookmark.dat")
    }

    func loadSaveFolderBookmark() -> Data? {
        try? Data(contentsOf: bookmarkFileURL)
    }

    func saveSaveFolderBookmark(_ data: Data?) {
        guard let data else {
            try? FileManager.default.removeItem(at: bookmarkFileURL)
            return
        }
        try? data.write(to: bookmarkFileURL, options: .atomic)
        do {
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: bookmarkFileURL.path)
        } catch {
            assertionFailure("Failed to set permissions on bookmark file: \(error)")
        }
    }

    var exists: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    func load() -> AppSettings {
        guard let data = try? Data(contentsOf: fileURL),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .defaultSettings
        }
        return settings
    }

    func save(_ settings: AppSettings) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(settings) else { return }
        try? data.write(to: fileURL, options: .atomic)
        do {
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
        } catch {
            assertionFailure("Failed to set permissions on settings file: \(error)")
        }
    }
}
