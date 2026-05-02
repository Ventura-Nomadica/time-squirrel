import SwiftUI

struct ActiveStopwatchView: View {
    @EnvironmentObject var appController: AppController

    @State private var showNotes = false
    @State private var showResetConfirm = false
    @State private var newLapName = ""
    @State private var editingLapID: UUID? = nil

    private var sc: SessionController? { appController.sessionController }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            sessionHeader

            Divider()

            // Main content
            HStack(alignment: .top, spacing: 0) {
                // Left: clock + controls
                VStack(spacing: 0) {
                    Spacer()

                    clockDisplay

                    Spacer().frame(height: 36)

                    controlRow

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                // Right: lap list (if any laps exist)
                if let sc, !sc.session.laps.isEmpty {
                    Divider()
                    lapList(sc: sc)
                        .frame(width: 220)
                }
            }

            // Notes panel
            if showNotes, let sc {
                Divider()
                NoteEditorView(text: Binding(
                    get: { sc.session.notes },
                    set: { sc.updateNotes($0) }
                ))
                .frame(height: 200)
            }

            Divider()
            bottomBar
        }
        .sheet(isPresented: $showResetConfirm) {
            ResetConfirmView(
                isPresented: $showResetConfirm,
                onConfirm: { appController.handleReset() }
            )
        }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(sc?.session.name ?? "Stopwatch")
                    .font(.headline)
                HStack(spacing: 6) {
                    Circle()
                        .fill(sc?.state == .running ? Color.tsLeaf : Color.tsWarn)
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)
                    Text(sc?.state == .running ? "Running" : "Paused")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let behavior = sc?.session.sleepBehavior {
                        Text("·").foregroundColor(.secondary).font(.caption)
                        Text("Sleep: \(behavior.displayName)")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            Button("Reset") { showResetConfirm = true }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.callout)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    private var clockDisplay: some View {
        VStack(spacing: 6) {
            Text((sc?.currentElapsed ?? 0).hmsString)
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                
                .accessibilityLabel((sc?.currentElapsed ?? 0).shortString)

            if let activeLap = sc?.session.laps.last, activeLap.isOpen {
                Text("Lap \(sc?.session.laps.count ?? 0): \((sc?.currentLapElapsed ?? 0).hmsString)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    
            }
        }
    }

    private var controlRow: some View {
        HStack(spacing: 20) {
            // Lap button
            CircleButton(
                icon: "flag",
                label: "Lap",
                color: .secondary
            ) { sc?.captureLap() }

            // Pause / Resume
            if sc?.state == .running {
                CircleButton(icon: "pause.fill", label: "Pause", color: Color.tsAccent, large: true) {
                    sc?.pause()
                }
            } else {
                CircleButton(icon: "play.fill", label: "Resume", color: Color.tsLeaf, large: true) {
                    sc?.resume()
                }
            }

            // Stop
            CircleButton(icon: "stop.fill", label: "Stop", color: Color.tsWarn) {
                appController.handleStop()
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            Button(action: { withAnimation { showNotes.toggle() } }) {
                Label("Notes", systemImage: showNotes ? "note.text.badge.plus" : "note.text")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private func lapList(sc: SessionController) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Laps")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sc.session.laps.reversed()) { lap in
                        LapRow(lap: lap, isEditing: editingLapID == lap.id) {
                            editingLapID = lap.id
                        } onRename: { name in
                            sc.renameLap(lap.id, name: name)
                            editingLapID = nil
                        }
                        Divider()
                    }
                }
            }
        }
    }
}

struct LapRow: View {
    let lap: Lap
    let isEditing: Bool
    let onEdit: () -> Void
    let onRename: (String) -> Void

    @State private var editName = ""

    var body: some View {
        HStack {
            if isEditing {
                TextField(lap.displayName, text: $editName, onCommit: { onRename(editName) })
                    .textFieldStyle(.roundedBorder)
                    .onAppear { editName = lap.name }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(lap.displayName)
                        .font(.callout)
                    if !lap.isOpen {
                        Text(lap.duration.hmsString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                    } else {
                        Text("running")
                            .font(.caption)
                            .foregroundColor(Color.tsLeaf)
                    }
                }
            }
            Spacer()
            if !isEditing {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct CircleButton: View {
    let icon: String
    let label: String
    let color: Color
    var large: Bool = false
    let action: () -> Void

    var size: CGFloat { large ? 64 : 48 }
    var iconSize: Font { large ? .title2 : .body }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(iconSize)
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .background(Circle().fill(color))
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct TimeLabel: View {
    let elapsed: TimeInterval
    var fontSize: CGFloat = 72

    var body: some View {
        Text(elapsed.hmsString)
            .font(.system(size: fontSize, weight: .thin, design: .monospaced))
            
            .accessibilityLabel(elapsed.shortString)
    }
}

struct ResetConfirmView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset the session?")
                .font(.headline)
            Text("The session will be discarded. Time will not be saved.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Button("Cancel") { isPresented = false }
                    .keyboardShortcut(.escape)
                Button("Reset") {
                    isPresented = false
                    onConfirm()
                }
                .foregroundColor(Color.tsWarn)
            }
        }
        .padding(28)
        .frame(width: 340, height: 160)
    }
}
