import Foundation

enum ExportError: Error {
    case encodingFailed
    case writeFailed(Error)
}

final class ExportWriter {

    static func write(session: Session, to directory: URL) throws -> (markdown: URL, json: URL) {
        let accessing = directory.startAccessingSecurityScopedResource()
        defer { if accessing { directory.stopAccessingSecurityScopedResource() } }
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)

        SaveLocationManager.writeMarker(to: directory)

        let slug = sessionSlug(name: session.name, date: session.startDate)
        let mdURL = directory.appendingPathComponent("\(slug).md")
        let jsonURL = directory.appendingPathComponent("\(slug).json")

        let mdContent = markdownContent(for: session)
        guard let mdData = mdContent.data(using: .utf8) else { throw ExportError.encodingFailed }
        do { try mdData.write(to: mdURL, options: .atomic) } catch { throw ExportError.writeFailed(error) }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let jsonData = try? encoder.encode(session) else { throw ExportError.encodingFailed }
        do { try jsonData.write(to: jsonURL, options: .atomic) } catch { throw ExportError.writeFailed(error) }

        do {
            try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: mdURL.path)
            try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: jsonURL.path)
        } catch {
            throw ExportError.writeFailed(error)
        }

        return (mdURL, jsonURL)
    }

    static func rewrite(session: Session, slug existingSlug: String, to directory: URL) throws -> (markdown: URL, json: URL) {
        let accessing = directory.startAccessingSecurityScopedResource()
        defer { if accessing { directory.stopAccessingSecurityScopedResource() } }
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)

        SaveLocationManager.writeMarker(to: directory)

        let mdURL = directory.appendingPathComponent("\(existingSlug).md")
        let jsonURL = directory.appendingPathComponent("\(existingSlug).json")

        let mdContent = markdownContent(for: session)
        guard let mdData = mdContent.data(using: .utf8) else { throw ExportError.encodingFailed }
        do { try mdData.write(to: mdURL, options: .atomic) } catch { throw ExportError.writeFailed(error) }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let jsonData = try? encoder.encode(session) else { throw ExportError.encodingFailed }
        do { try jsonData.write(to: jsonURL, options: .atomic) } catch { throw ExportError.writeFailed(error) }

        do {
            try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: mdURL.path)
            try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: jsonURL.path)
        } catch {
            throw ExportError.writeFailed(error)
        }

        return (mdURL, jsonURL)
    }

    static func sessionSlug(name: String, date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: date)
        let words = name
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .prefix(5)
            .joined(separator: "-")
        return words.isEmpty ? dateStr : "\(dateStr)-\(words)"
    }

    private static func markdownContent(for session: Session) -> String {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .medium

        var lines: [String] = []
        lines.append("# \(session.name.isEmpty ? "Session" : session.name)")
        lines.append("")
        lines.append("| Field | Value |")
        lines.append("|---|---|")
        lines.append("| Mode | \(session.mode.displayName) |")
        lines.append("| Date | \(df.string(from: session.startDate)) |")
        if let end = session.endDate {
            lines.append("| Ended | \(df.string(from: end)) |")
        }
        lines.append("| Active time | \(session.activeElapsed.hmsString) |")
        lines.append("| Total elapsed | \(session.totalElapsed.hmsString) |")

        if session.mode == .stopwatch, let behavior = session.sleepBehavior {
            lines.append("| Sleep behavior | \(behavior.displayName) |")
        }

        if session.mode == .timer, let tc = session.timerConfig {
            lines.append("| Timer duration | \(tc.duration.hmsString) |")
            lines.append("| Loop | \(tc.loops ? "Yes" : "No") |")
            if session.loopCount > 0 {
                lines.append("| Loops completed | \(session.loopCount) |")
            }
        }

        if let ac = session.alertConfig {
            if let target = ac.targetDuration {
                lines.append("| Target alert | \(target.hmsString) |")
            }
            if let interval = ac.repeatingInterval {
                lines.append("| Repeating alert | every \(interval.hmsString) |")
            }
        }

        if !session.laps.isEmpty {
            lines.append("")
            lines.append("## Laps")
            lines.append("")
            lines.append("| # | Name | Start | Duration |")
            lines.append("|---|---|---|---|")
            for (i, lap) in session.laps.enumerated() {
                let name = lap.displayName
                let start = lap.startElapsed.hmsString
                let dur = lap.isOpen ? "—" : lap.duration.hmsString
                lines.append("| \(i + 1) | \(name) | \(start) | \(dur) |")
            }
        }

        if !session.notes.isEmpty {
            lines.append("")
            lines.append("## Notes")
            lines.append("")
            lines.append(session.notes)
        }

        return lines.joined(separator: "\n") + "\n"
    }
}
