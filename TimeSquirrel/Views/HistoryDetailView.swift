import SwiftUI

struct HistoryDetailView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.presentationMode) var presentationMode

    let entry: HistoryEntry

    @State private var editingName: String
    @State private var editingNotes: String
    @State private var showDeleteConfirm = false
    @State private var exportMessage: String?
    @State private var isEditingName = false

    init(entry: HistoryEntry) {
        self.entry = entry
        _editingName = State(initialValue: entry.displayName)
        _editingNotes = State(initialValue: entry.session.notes)
    }

    private var session: Session { entry.session }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .medium
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if isEditingName {
                    TextField("Session name", text: $editingName, onCommit: { isEditingName = false })
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 280)
                } else {
                    Button(action: { isEditingName = true }) {
                        HStack(spacing: 6) {
                            Text(editingName)
                                .font(.headline)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                HStack(spacing: 12) {
                    Button("Re-export") { reexport() }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color.tsWarn)
                    Button("Done") { save() }
                        
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)

            if let msg = exportMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.tsLeaf)
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .background(Color.tsLeaf.opacity(0.08))
            }

            Divider()

            // Metadata
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary
                    GroupBox {
                        VStack(spacing: 0) {
                            MetaRow(label: "Mode", value: session.mode.displayName)
                            Divider()
                            MetaRow(label: "Started", value: dateFormatter.string(from: session.startDate))
                            if let end = session.endDate {
                                Divider()
                                MetaRow(label: "Ended", value: dateFormatter.string(from: end))
                            }
                            Divider()
                            MetaRow(label: "Active time", value: session.activeElapsed.shortString)
                            if session.mode == .stopwatch, let behavior = session.sleepBehavior {
                                Divider()
                                MetaRow(label: "Sleep", value: behavior.displayName)
                            }
                            if session.mode == .timer, let tc = session.timerConfig {
                                Divider()
                                MetaRow(label: "Duration", value: tc.duration.hmsString)
                                if tc.loops {
                                    Divider()
                                    MetaRow(label: "Loops", value: "\(session.loopCount)")
                                }
                            }
                        }
                    }

                    // Laps
                    if !session.laps.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Laps")
                                .font(.subheadline).bold()
                            ForEach(session.laps) { lap in
                                HStack {
                                    Text(lap.displayName).font(.callout)
                                    Spacer()
                                    Text(lap.isOpen ? "—" : lap.duration.hmsString)
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.subheadline).bold()
                        NoteEditorView(text: $editingNotes)
                            .frame(minHeight: 180)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1))
                            )
                    }
                }
                .padding(24)
            }
        }
        .alert(isPresented: $showDeleteConfirm) {
            Alert(
                title: Text("Delete this session?"),
                message: Text("Both the Markdown and JSON files will be removed from your save folder."),
                primaryButton: .destructive(Text("Delete")) {
                    appController.historyStore.delete(entry: entry)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func save() {
        var updated = entry.session
        updated.name = editingName.trimmingCharacters(in: .whitespaces)
        if updated.name.isEmpty { updated.name = entry.displayName }
        updated.notes = editingNotes
        try? appController.historyStore.update(entry: entry, session: updated)
        presentationMode.wrappedValue.dismiss()
    }

    private func reexport() {
        do {
            try appController.historyStore.reexport(entry: entry)
            exportMessage = "Exported to \(entry.slug)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exportMessage = nil
            }
        } catch {
            exportMessage = "Export failed."
        }
    }
}

struct MetaRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.callout)
            Spacer()
            Text(value)
                .font(.callout)
        }
        .padding(.vertical, 8)
    }
}
