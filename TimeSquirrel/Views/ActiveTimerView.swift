import SwiftUI

struct ActiveTimerView: View {
    @EnvironmentObject var appController: AppController

    @State private var showNotes = false
    @State private var showResetConfirm = false

    private var sc: SessionController? { appController.sessionController }

    private var progress: Double {
        guard let sc, let tc = sc.session.timerConfig, tc.duration > 0 else { return 0 }
        let loopDuration = tc.duration
        let loopElapsed = sc.currentElapsed - Double(sc.session.loopCount) * loopDuration
        return min(1.0, max(0.0, 1.0 - loopElapsed / loopDuration))
    }

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader

            Divider()

            Spacer(minLength: 0)
            progressRing
            Spacer().frame(height: 32)
            controlRow
            Spacer(minLength: 0)

            if showNotes, let sc {
                Divider()
                NoteEditorView(text: Binding(
                    get: { sc.session.notes },
                    set: { sc.updateNotes($0) }
                ))
                .frame(minHeight: 80, maxHeight: 200)
                .layoutPriority(1)
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
                Text(sc?.session.name ?? "Timer")
                    .font(.headline)
                HStack(spacing: 6) {
                    Circle()
                        .fill(sc?.state == .running ? Color.tsLeaf : Color.tsWarn)
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)
                    Text(sc?.state == .running ? "Running" : "Paused")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let sc, let tc = sc.session.timerConfig, tc.loops {
                        Text("·").foregroundColor(.secondary).font(.caption)
                        Text("Loop \(sc.session.loopCount + 1)")
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

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 6)
                .frame(width: 180, height: 180)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    sc?.state == .running ? Color.tsAccent : Color.secondary,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            VStack(spacing: 4) {
                Text((sc?.remaining ?? 0).hmsString)
                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                    
                    .accessibilityLabel((sc?.remaining ?? 0).shortString)
                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var controlRow: some View {
        HStack(spacing: 20) {
            if sc?.state == .running {
                CircleButton(icon: "pause.fill", label: "Pause", color: Color.tsAccent, large: true) {
                    sc?.pause()
                }
            } else {
                CircleButton(icon: "play.fill", label: "Resume", color: Color.tsLeaf, large: true) {
                    sc?.resume()
                }
            }

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
            Button(action: { appController.openFloatingWindow() }) {
                VStack(spacing: 3) {
                    Image(systemName: "pip.fill")
                        .font(.callout)
                    Text("Always On Top")
                        .font(.caption2)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }
}
