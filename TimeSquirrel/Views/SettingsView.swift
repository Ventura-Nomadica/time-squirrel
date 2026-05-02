import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.presentationMode) var presentationMode

    @State private var settings: AppSettings
    @State private var newPresetName = ""
    @State private var newPresetHours = 0
    @State private var newPresetMinutes = 0
    @State private var newPresetSeconds = 0
    @State private var migrationError: String?
    @State private var isMigrating = false

    init() {
        _settings = State(initialValue: AppSettings.defaultSettings)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2).bold()
                Spacer()
                Button("Done") {
                    appController.updateSettings(settings)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.return)
                
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // Appearance
                    settingsSection("Appearance") {
                        Picker("Theme", selection: $settings.appearance) {
                            ForEach(Appearance.allCases, id: \.self) {
                                Text($0.displayName).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            Text("Font size")
                            Spacer()
                            Slider(value: $settings.fontSize, in: 11...24, step: 1)
                                .frame(width: 160)
                            Text("\(Int(settings.fontSize)) pt")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .frame(width: 40)
                        }
                    }

                    // Session defaults
                    settingsSection("Session defaults") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Stopwatch sleep behavior")
                                .font(.callout)
                            Picker("", selection: $settings.defaultSleepBehavior) {
                                ForEach(SleepBehavior.allCases, id: \.self) {
                                    Text($0.displayName).tag($0)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            Text(settings.defaultSleepBehavior.description)
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }

                    // Timer presets
                    settingsSection("Custom timer presets") {
                        if settings.customTimerPresets.isEmpty {
                            Text("No custom presets.")
                                .foregroundColor(.secondary).font(.callout)
                        } else {
                            VStack(spacing: 6) {
                                ForEach(settings.customTimerPresets) { preset in
                                    HStack {
                                        Text(preset.name).font(.callout)
                                        Text("·").foregroundColor(.secondary)
                                        Text(preset.duration.hmsString)
                                            .font(.callout).foregroundColor(.secondary)
                                        Spacer()
                                        Button(action: { deletePreset(preset) }) {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(Color.tsWarn)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    Divider()
                                }
                            }
                        }

                        // Add preset
                        HStack(spacing: 8) {
                            TextField("Name", text: $newPresetName)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                            IntField(value: $newPresetHours, placeholder: "h", max: 23)
                            Text("h").foregroundColor(.secondary)
                            IntField(value: $newPresetMinutes, placeholder: "m", max: 59)
                            Text("m").foregroundColor(.secondary)
                            IntField(value: $newPresetSeconds, placeholder: "s", max: 59)
                            Text("s").foregroundColor(.secondary)
                            Button("Add") { addPreset() }
                                .disabled(newPresetName.isEmpty || presetDuration <= 0)
                        }
                    }

                    // Save location
                    settingsSection("Save location") {
                        HStack {
                            Text(settings.saveLocationPath)
                                .font(.system(.callout, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .truncationMode(.middle)
                            Spacer()
                            Button("Change") { chooseSaveLocation() }
                                .disabled(isMigrating)
                        }
                        .padding(10)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(8)

                        if let err = migrationError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(Color.tsWarn)
                                Text(err)
                                    .font(.caption)
                                    .foregroundColor(Color.tsWarn)
                            }
                        }
                    }

                    // Updates
                    settingsSection("Updates") {
                        VStack(spacing: 10) {
                            ForEach(UpdateBehavior.allCases, id: \.self) { choice in
                                ChoiceRow(
                                    title: choice.displayName,
                                    detail: choice.description,
                                    isSelected: settings.updateBehavior == choice
                                ) { settings.updateBehavior = choice }
                            }
                        }

                        if settings.updateBehavior == .manual {
                            Button("Check for updates now") {
                                SparkleController.shared.checkForUpdates()
                            }
                            .disabled(!SparkleController.shared.canCheckForUpdates)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            settings = appController.settings
        }
    }

    private var presetDuration: TimeInterval {
        TimeInterval(newPresetHours * 3600 + newPresetMinutes * 60 + newPresetSeconds)
    }

    private func addPreset() {
        let p = CustomTimerPreset(name: newPresetName, duration: presetDuration)
        settings.customTimerPresets.append(p)
        newPresetName = ""
        newPresetHours = 0
        newPresetMinutes = 0
        newPresetSeconds = 0
    }

    private func deletePreset(_ preset: CustomTimerPreset) {
        settings.customTimerPresets.removeAll { $0.id == preset.id }
    }

    private func chooseSaveLocation() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Choose"
        panel.message = "Choose a new save folder for your session files."
        guard panel.runModal() == .OK, let newURL = panel.url else { return }
        let newPath = newURL.path
        guard newPath != settings.saveLocationPath else { return }

        isMigrating = true
        migrationError = nil
        let oldPath = settings.saveLocationPath

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try SaveLocationManager.migrate(from: oldPath, to: newPath) {
                    // Pointer flip: update settings on main thread
                    DispatchQueue.main.sync {
                        self.settings.saveLocationPath = newPath
                        self.appController.updateSettings(self.settings)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.migrationError = error.localizedDescription
                }
            }
            DispatchQueue.main.async {
                self.isMigrating = false
            }
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            content()
        }
    }
}
