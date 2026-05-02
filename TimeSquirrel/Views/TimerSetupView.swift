import SwiftUI

private let builtInPresets: [(label: String, seconds: TimeInterval)] = [
    ("1 min",  60),
    ("5 min",  300),
    ("10 min", 600),
    ("15 min", 900),
    ("30 min", 1800),
    ("60 min", 3600),
]

struct TimerSetupView: View {
    @EnvironmentObject var appController: AppController

    @State private var sessionName = ""
    @State private var selectedPreset: TimeInterval? = 300
    @State private var customHours = 0
    @State private var customMinutes = 5
    @State private var customSeconds = 0
    @State private var useCustom = false
    @State private var loops = false
    @State private var enableRepeatingAlert = false
    @State private var repeatHours = 0
    @State private var repeatMinutes = 0
    @State private var repeatSeconds = 0
    @State private var alertSound = true

    private var chosenDuration: TimeInterval {
        if useCustom {
            return TimeInterval(customHours * 3600 + customMinutes * 60 + customSeconds)
        }
        return selectedPreset ?? 300
    }

    private var canStart: Bool {
        chosenDuration > 0
    }

    private var customPresets: [CustomTimerPreset] {
        appController.settings.customTimerPresets
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { appController.navigate(to: .idle) }) {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Timer")
                        .font(.title2).bold()

                    // Session name
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Session name", systemImage: "tag")
                            .font(.subheadline).foregroundColor(.secondary)
                        TextField("Optional", text: $sessionName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Duration
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Duration", systemImage: "timer")
                            .font(.subheadline).foregroundColor(.secondary)

                        // Built-in presets
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(builtInPresets, id: \.seconds) { preset in
                                PresetButton(
                                    label: preset.label,
                                    isSelected: !useCustom && selectedPreset == preset.seconds
                                ) {
                                    useCustom = false
                                    selectedPreset = preset.seconds
                                }
                            }
                        }

                        // Custom presets from settings
                        if !customPresets.isEmpty {
                            Text("Your presets")
                                .font(.caption).foregroundColor(.secondary)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(customPresets) { preset in
                                    PresetButton(
                                        label: preset.name,
                                        isSelected: !useCustom && selectedPreset == preset.duration
                                    ) {
                                        useCustom = false
                                        selectedPreset = preset.duration
                                    }
                                }
                            }
                        }

                        // Custom entry
                        Button(action: { useCustom = true }) {
                            HStack {
                                Image(systemName: useCustom ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(useCustom ? Color.tsAccent : .secondary)
                                Text("Custom duration")
                                    .font(.callout)
                            }
                        }
                        .buttonStyle(.plain)

                        if useCustom {
                            DurationPicker(
                                hours: $customHours,
                                minutes: $customMinutes,
                                seconds: $customSeconds,
                                label: "Set"
                            )
                        }
                    }

                    // Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Options")
                            .font(.subheadline).foregroundColor(.secondary)

                        Toggle("Loop when the timer completes", isOn: $loops)

                        Toggle("Repeating interval alert", isOn: $enableRepeatingAlert)
                        if enableRepeatingAlert {
                            DurationPicker(
                                hours: $repeatHours,
                                minutes: $repeatMinutes,
                                seconds: $repeatSeconds,
                                label: "Every"
                            )
                        }

                        Toggle("Play sound with alerts", isOn: $alertSound)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }

            Divider()

            HStack {
                Spacer()
                Button("Start") { start() }
                    .keyboardShortcut(.return)
                    
                    .disabled(!canStart)
                    .controlSize(.large)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func start() {
        let timerConfig = TimerConfig(duration: chosenDuration, loops: loops)
        let alertConfig: AlertConfig? = enableRepeatingAlert ? AlertConfig(
            repeatingInterval: TimeInterval(repeatHours * 3600 + repeatMinutes * 60 + repeatSeconds),
            playSound: alertSound
        ) : nil

        let name = sessionName.trimmingCharacters(in: .whitespaces)
        let defaultName = chosenDuration.hmsString + " timer"
        appController.startTimer(
            name: name.isEmpty ? defaultName : name,
            timerConfig: timerConfig,
            alertConfig: alertConfig
        )
    }
}

struct PresetButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.callout)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.tsAccent : Color.primary.opacity(0.06))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
