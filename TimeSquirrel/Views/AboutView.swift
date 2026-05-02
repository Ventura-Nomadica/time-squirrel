import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Identity
            VStack(spacing: 10) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 52))
                    .foregroundColor(Color.tsAccent)

                Text("Time Squirrel")
                    .font(.title2).bold()

                Text("Version \(version)")
                    .foregroundColor(.secondary)
                    .font(.callout)
            }

            // Description
            Text("A local, private time tracker for macOS.\nSessions save as Markdown and JSON files on your machine.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            // Links
            VStack(spacing: 8) {
                Link("Time Squirrel on GitHub",
                     destination: URL(string: "https://github.com/timesquirrel/timesquirrel")!)
                    .font(.callout)

                Text("MIT License")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Close") { presentationMode.wrappedValue.dismiss() }
                .keyboardShortcut(.escape)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
