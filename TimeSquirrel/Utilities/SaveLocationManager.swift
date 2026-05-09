import Foundation

enum SaveLocationError: LocalizedError {
    case sourceNotReadable
    case noOwnedFilesFound
    case copyFailed(Error)
    case verifyFailed
    case rollbackFailed(Error)
    case deleteFailed(Error)
    case bookmarkCreationFailed(Error)
    case bookmarkResolutionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .sourceNotReadable:
            return "The current save folder cannot be read."
        case .noOwnedFilesFound:
            return "The folder contains no Time Squirrel session files to migrate."
        case .copyFailed(let e):
            return "Copy failed: \(e.localizedDescription)"
        case .verifyFailed:
            return "Verification failed after copy. The old location is still in use."
        case .rollbackFailed(let e):
            return "Rollback of partial copy failed: \(e.localizedDescription)"
        case .deleteFailed(let e):
            return "Old files could not be removed after successful migration: \(e.localizedDescription)"
        case .bookmarkCreationFailed(let e):
            return "Could not bookmark the save folder: \(e.localizedDescription)"
        case .bookmarkResolutionFailed(let e):
            return "Could not resolve the saved folder bookmark: \(e.localizedDescription)"
        }
    }
}

final class SaveLocationManager {

    static func persistBookmark(for url: URL) throws {
        do {
            let data = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            SettingsStore.shared.saveSaveFolderBookmark(data)
        } catch {
            throw SaveLocationError.bookmarkCreationFailed(error)
        }
    }

    static func resolveBookmark() throws -> URL? {
        guard let data = SettingsStore.shared.loadSaveFolderBookmark() else { return nil }
        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale, let refreshed = try? url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            ) {
                SettingsStore.shared.saveSaveFolderBookmark(refreshed)
            }
            return url
        } catch {
            throw SaveLocationError.bookmarkResolutionFailed(error)
        }
    }

    // Matches YYYY-MM-DD-<slug>.md and YYYY-MM-DD-<slug>.json produced by ExportWriter.
    private static func isTimeSquirrelFile(_ name: String) -> Bool {
        let pattern = #"^\d{4}-\d{2}-\d{2}-.+\.(md|json)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        return regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) != nil
    }

    // Copy-verify-pointer flip migration, restricted to Time Squirrel-owned files.
    // Each source file is deleted only after its destination is verified.
    // The source directory is never deleted.
    static func migrate(
        from oldPath: String,
        to newPath: String,
        flipPointer: () -> Void
    ) throws {
        let fm = FileManager.default
        let oldDir = URL(fileURLWithPath: oldPath, isDirectory: true)
        let newDir = URL(fileURLWithPath: newPath, isDirectory: true)
        let accessingOld = oldDir.startAccessingSecurityScopedResource()
        let accessingNew = newDir.startAccessingSecurityScopedResource()
        defer {
            if accessingOld { oldDir.stopAccessingSecurityScopedResource() }
            if accessingNew { newDir.stopAccessingSecurityScopedResource() }
        }

        guard fm.fileExists(atPath: oldPath) else {
            try fm.createDirectory(at: newDir, withIntermediateDirectories: true)
            writeMarker(to: newDir)
            flipPointer()
            return
        }

        let contents: [URL]
        do {
            contents = try fm.contentsOfDirectory(
                at: oldDir,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
        } catch {
            throw SaveLocationError.sourceNotReadable
        }

        let owned = contents.filter { isTimeSquirrelFile($0.lastPathComponent) }
        guard !owned.isEmpty else {
            throw SaveLocationError.noOwnedFilesFound
        }

        try fm.createDirectory(at: newDir, withIntermediateDirectories: true)

        for src in owned {
            let dst = newDir.appendingPathComponent(src.lastPathComponent)
            do {
                try fm.copyItem(at: src, to: dst)
            } catch {
                throw SaveLocationError.copyFailed(error)
            }

            let srcSize = (try? fm.attributesOfItem(atPath: src.path))?[.size] as? Int
            let dstSize = (try? fm.attributesOfItem(atPath: dst.path))?[.size] as? Int
            guard fm.fileExists(atPath: dst.path),
                  let s = srcSize, let d = dstSize, s == d,
                  (try? Data(contentsOf: dst)) != nil
            else {
                try? fm.removeItem(at: dst)
                throw SaveLocationError.verifyFailed
            }

            try? fm.removeItem(at: src)
        }

        writeMarker(to: newDir)
        flipPointer()
    }

    static func writeMarker(to directory: URL) {
        let markerURL = directory.appendingPathComponent(".timesquirrel")
        guard !FileManager.default.fileExists(atPath: markerURL.path) else { return }
        try? Data().write(to: markerURL, options: .atomic)
        do {
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: markerURL.path)
        } catch {
            assertionFailure("Failed to set permissions on marker file: \(error)")
        }
    }
}
