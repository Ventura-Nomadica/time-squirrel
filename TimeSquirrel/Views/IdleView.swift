import SwiftUI

struct IdleView: View {
    @EnvironmentObject var appController: AppController

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Identity
            Image("AppLogo")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 200, height: 200)
                .accessibilityLabel("Time Squirrel")

            Spacer().frame(height: 48)

            // Mode selection
            HStack(spacing: 20) {
                ModeCard(
                    title: "Stopwatch",
                    description: "Count up from zero.",
                    systemImage: "stopwatch"
                ) {
                    appController.navigate(to: .stopwatchSetup)
                }

                ModeCard(
                    title: "Timer",
                    description: "Count down from a set duration.",
                    systemImage: "timer"
                ) {
                    appController.navigate(to: .timerSetup)
                }
            }
            .padding(.horizontal, 48)

            Spacer().frame(height: 32)

            // History link
            Button("View history") {
                appController.navigate(to: .history)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .font(.callout)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ModeCard: View {
    let title: String
    let description: String
    let systemImage: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 36))
                    .foregroundColor(Color.tsAccent)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovered ? Color.tsAccent.opacity(0.08) : Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isHovered ? Color.tsAccent.opacity(0.35) : Color.primary.opacity(0.10),
                            lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .accessibilityLabel("\(title): \(description)")
    }
}

extension Color {
    static let tsAccent = Color(red: 0.761, green: 0.388, blue: 0.165)
    static let tsLeaf   = Color(red: 0.420, green: 0.557, blue: 0.306)
    static let tsWarn   = Color(red: 0.690, green: 0.251, blue: 0.125)
}
