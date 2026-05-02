import Foundation

struct HistoryEntry: Identifiable {
    var id: UUID { session.id }
    var session: Session
    var slug: String
    var markdownURL: URL
    var jsonURL: URL

    var displayName: String { session.name.isEmpty ? "Session" : session.name }
}

final class HistoryStore: ObservableObject {
    @Published private(set) var entries: [HistoryEntry] = []

    private var saveLocationPath: String

    init(saveLocationPath: String) {
        self.saveLocationPath = saveLocationPath
        reload()
    }

    func updateSaveLocation(_ path: String) {
        saveLocationPath = path
        reload()
    }

    func reload() {
        let dir = URL(fileURLWithPath: saveLocationPath, isDirectory: true)
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            entries = []
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        var loaded: [HistoryEntry] = []
        let jsonFiles = contents.filter { $0.pathExtension == "json" }

        for jsonURL in jsonFiles {
            guard let data = try? Data(contentsOf: jsonURL),
                  let session = try? decoder.decode(Session.self, from: data) else {
                continue
            }
            let slug = jsonURL.deletingPathExtension().lastPathComponent
            let mdURL = jsonURL.deletingPathExtension().appendingPathExtension("md")
            loaded.append(HistoryEntry(
                session: session,
                slug: slug,
                markdownURL: mdURL,
                jsonURL: jsonURL
            ))
        }

        entries = loaded.sorted { $0.session.startDate > $1.session.startDate }
    }

    func delete(entry: HistoryEntry) {
        try? FileManager.default.removeItem(at: entry.jsonURL)
        try? FileManager.default.removeItem(at: entry.markdownURL)
        entries.removeAll { $0.id == entry.id }
    }

    func update(entry: HistoryEntry, session: Session) throws {
        let dir = URL(fileURLWithPath: saveLocationPath, isDirectory: true)
        let (_, _) = try ExportWriter.rewrite(session: session, slug: entry.slug, to: dir)
        reload()
    }

    func reexport(entry: HistoryEntry) throws {
        let dir = URL(fileURLWithPath: saveLocationPath, isDirectory: true)
        _ = try ExportWriter.rewrite(session: entry.session, slug: entry.slug, to: dir)
    }
}
