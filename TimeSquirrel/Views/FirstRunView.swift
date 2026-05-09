import SwiftUI

struct FirstRunView: View {
    @EnvironmentObject var appController: AppController

    @State private var step = 0
    @State private var updateBehavior: UpdateBehavior = .manual
    @State private var sleepBehavior: SleepBehavior = .pause
    @State private var saveLocationPath: String = AppSettings.defaultSettings.saveLocationPath

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text("Set up Time Squirrel")
                    .font(.title2).bold()
                Text("Step \(step + 1) of 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 36)
            .padding(.bottom, 28)

            Divider()

            // Step content
            Group {
                switch step {
                case 0:  UpdateBehaviorStep(selected: $updateBehavior)
                case 1:  SaveLocationStep(path: $saveLocationPath)
                default: SleepBehaviorStep(selected: $sleepBehavior)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 40)
            .padding(.vertical, 24)

            Divider()

            // Navigation
            HStack {
                if step > 0 {
                    Button("Back") { step -= 1 }
                        .keyboardShortcut(.escape)
                } else {
                    Spacer()
                }
                Spacer()
                if step < 2 {
                    Button("Next") { step += 1 }
                        .keyboardShortcut(.return)
                        
                } else {
                    Button("Get started") { finish() }
                        .keyboardShortcut(.return)
                        
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
        .frame(width: 520, height: 400)
    }

    private func finish() {
        var s = AppSettings.defaultSettings
        s.updateBehavior = updateBehavior
        s.defaultSleepBehavior = sleepBehavior
        s.saveLocationPath = saveLocationPath
        appController.completeFirstRun(settings: s)
    }
}

private struct UpdateBehaviorStep: View {
    @Binding var selected: UpdateBehavior

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Update behavior")
                .font(.headline)
            Text("How should Time Squirrel handle updates? You can change this later in Settings.")
                .foregroundColor(.secondary)

            VStack(spacing: 10) {
                ForEach(UpdateBehavior.allCases, id: \.self) { choice in
                    ChoiceRow(
                        title: choice.displayName,
                        detail: choice.description,
                        isSelected: selected == choice
                    ) { selected = choice }
                }
            }
        }
    }
}

private struct SaveLocationStep: View {
    @Binding var path: String
    @State private var showPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Save location")
                .font(.headline)
            Text("Sessions save as Markdown and JSON files in a folder you choose. The default is your Documents folder.")
                .foregroundColor(.secondary)

            HStack {
                Text(path)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("Choose") { choosePath() }
            }
            .padding(10)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(8)

            Text("Session data, including notes, is stored as unencrypted files in the location you choose.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func choosePath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Choose"
        panel.message = "Choose a folder for your session files."
        if panel.runModal() == .OK, let url = panel.url {
            path = url.path
            try? SaveLocationManager.persistBookmark(for: url)
        }
    }
}

private struct SleepBehaviorStep: View {
    @Binding var selected: SleepBehavior

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sleep behavior")
                .font(.headline)
            Text("What should the stopwatch do when your Mac sleeps? This is the default for new sessions.")
                .foregroundColor(.secondary)

            VStack(spacing: 10) {
                ForEach(SleepBehavior.allCases, id: \.self) { choice in
                    ChoiceRow(
                        title: choice.displayName,
                        detail: choice.description,
                        isSelected: selected == choice
                    ) { selected = choice }
                }
            }
        }
    }
}

struct ChoiceRow: View {
    let title: String
    let detail: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.tsAccent : .secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.callout).bold()
                    Text(detail).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.tsAccent.opacity(0.06) : Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.tsAccent.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
