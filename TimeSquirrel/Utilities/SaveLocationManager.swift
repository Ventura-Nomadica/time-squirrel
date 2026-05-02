import Foundation

enum SaveLocationError: LocalizedError {
    case sourceNotReadable
    case copyFailed(Error)
    case verifyFailed
    case rollbackFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .sourceNotReadable:
            return "The current save folder cannot be read."
        case .copyFailed(let e):
            return "Copy failed: \(e.localizedDescription)"
        case .verifyFailed:
            return "Verification failed after copy. The old location is still in use."
        case .rollbackFailed(let e):
            return "Rollback of partial copy failed: \(e.localizedDescription)"
        case .deleteFailed(let e):
            return "Old files could not be removed after successful migration: \(e.localizedDescription)"
        }
    }
}

final class SaveLocationManager {

    // Copy-verify-pointer flip-delete migration.
    // The pointer flip is updating the settings value; that happens in the callback.
    // On any failure before the flip, partial copies are cleaned up.
    static func migrate(
        from oldPath: String,
        to newPath: String,
        flipPointer: () -> Void
    ) throws {
        let fm = FileManager.default
        let oldDir = URL(fileURLWithPath: oldPath, isDirectory: true)
        let newDir = URL(fileURLWithPath: newPath, isDirectory: true)

        guard fm.fileExists(atPath: oldPath) else {
            // Nothing to migrate — just flip the pointer.
            try fm.createDirectory(at: newDir, withIntermediateDirectories: true)
            flipPointer()
            return
        }

        let contents: [URL]
        do {
            contents = try fm.contentsOfDirectory(
                at: oldDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        } catch {
            throw SaveLocationError.sourceNotReadable
        }

        // Step 1: Copy
        try fm.createDirectory(at: newDir, withIntermediateDirectories: true)
        var copied: [URL] = []
        do {
            for src in contents {
                let dst = newDir.appendingPathComponent(src.lastPathComponent)
                try fm.copyItem(at: src, to: dst)
                copied.append(dst)
            }
        } catch {
            // Rollback before pointer flip
            for dst in copied {
                try? fm.removeItem(at: dst)
            }
            throw SaveLocationError.copyFailed(error)
        }

        // Step 2: Verify (confirm all source files exist in destination)
        for src in contents {
            let dst = newDir.appendingPathComponent(src.lastPathComponent)
            guard fm.fileExists(atPath: dst.path) else {
                // Verification failed — rollback
                for c in copied { try? fm.removeItem(at: c) }
                throw SaveLocationError.verifyFailed
            }
        }

        // Step 3: Pointer flip (no going back after this)
        flipPointer()

        // Step 4: Delete old files
        for src in contents {
            try? fm.removeItem(at: src)
        }
        // Remove empty old directory if possible
        try? fm.removeItem(at: oldDir)
    }
}
