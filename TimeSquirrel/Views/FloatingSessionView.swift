import SwiftUI

struct FloatingSessionView: View {
    @EnvironmentObject var appController: AppController

    private var sc: SessionController? { appController.sessionController }
    private var isStopwatch: Bool { sc?.session.mode == .stopwatch }

    var body: some View {
        VStack(spacing: 14) {
            timeDisplay
            controlRow
            Button {
                appController.closeFloatingWindow()
            } label: {
                Label("Return to Main Window", systemImage: "macwindow")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(20)
    }

    private var timeDisplay: some View {
        VStack(spacing: 4) {
            if isStopwatch {
                Text((sc?.currentElapsed ?? 0).hmsString)
                    .font(.system(size: 42, weight: .thin, design: .monospaced))
            } else {
                Text((sc?.remaining ?? 0).hmsString)
                    .font(.system(size: 42, weight: .thin, design: .monospaced))
                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var controlRow: some View {
        HStack(spacing: 12) {
            if isStopwatch {
                CircleButton(icon: "flag", label: "Lap", color: .secondary) {
                    sc?.captureLap()
                }
            }

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
}
