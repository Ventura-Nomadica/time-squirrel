import SwiftUI

struct StopwatchSetupView: View {
    @EnvironmentObject var appController: AppController

    @State private var sessionName = ""
    @State private var sleepBehavior: SleepBehavior
    @State private var enableTargetAlert = false
    @State private var targetHours = 0
    @State private var targetMinutes = 0
    @State private var targetSeconds = 0
    @State private var enableRepeatingAlert = false
    @State private var repeatHours = 0
    @State private var repeatMinutes = 0
    @State private var repeatSeconds = 0
    @State private var alertSound = true

    init() {
        _sleepBehavior = State(initialValue: AppSettings.defaultSettings.defaultSleepBehavior)
    }

    private var canStart: Bool {
        if enableTargetAlert && targetDuration <= 0 { return false }
        if enableRepeatingAlert && repeatDuration <= 0 { return false }
        return true
    }

    private var targetDuration: TimeInterval {
        TimeInterval(targetHours * 3600 + targetMinutes * 60 + targetSeconds)
    }

    private var repeatDuration: TimeInterval {
        TimeInterval(repeatHours * 3600 + repeatMinutes * 60 + repeatSeconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Back button row
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
                    // Title
                    Text("Stopwatch")
                        .font(.title2).bold()

                    // Session name
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Session name", systemImage: "tag")
                            .font(.subheadline).foregroundColor(.secondary)
                        TextField("Optional", text: $sessionName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Sleep behavior
                    VStack(alignment: .leading, spacing: 8) {
                        Label("When your Mac sleeps", systemImage: "moon")
                            .font(.subheadline).foregroundColor(.secondary)
                        Picker("", selection: $sleepBehavior) {
                            ForEach(SleepBehavior.allCases, id: \.self) {
                                Text($0.displayName).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        Text(sleepBehavior.description)
                            .font(.caption).foregroundColor(.secondary)
                    }

                    Divider()

                    // Alerts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Alerts")
                            .font(.subheadline).foregroundColor(.secondary)

                        Toggle("Alert at a target time", isOn: $enableTargetAlert)
                        if enableTargetAlert {
                            DurationPicker(
                                hours: $targetHours,
                                minutes: $targetMinutes,
                                seconds: $targetSeconds,
                                label: "Target"
                            )
                        }

                        Toggle("Repeating interval alert", isOn: $enableRepeatingAlert)
                        if enableRepeatingAlert {
                            DurationPicker(
                                hours: $repeatHours,
                                minutes: $repeatMinutes,
                                seconds: $repeatSeconds,
                                label: "Every"
                            )
                        }

                        if enableTargetAlert || enableRepeatingAlert {
                            Toggle("Play sound with alerts", isOn: $alertSound)
                        }
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
        .onAppear {
            sleepBehavior = appController.settings.defaultSleepBehavior
        }
    }

    private func start() {
        let alertConfig: AlertConfig? = (enableTargetAlert || enableRepeatingAlert) ? AlertConfig(
            targetDuration: enableTargetAlert ? targetDuration : nil,
            repeatingInterval: enableRepeatingAlert ? repeatDuration : nil,
            playSound: alertSound
        ) : nil

        let name = sessionName.trimmingCharacters(in: .whitespaces)
        appController.startStopwatch(
            name: name.isEmpty ? "Stopwatch" : name,
            sleepBehavior: sleepBehavior,
            alertConfig: alertConfig
        )
    }
}

struct DurationPicker: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.callout)
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .leading)
            IntField(value: $hours, placeholder: "h", max: 23)
            Text("h").foregroundColor(.secondary)
            IntField(value: $minutes, placeholder: "m", max: 59)
            Text("m").foregroundColor(.secondary)
            IntField(value: $seconds, placeholder: "s", max: 59)
            Text("s").foregroundColor(.secondary)
        }
        .padding(.leading, 8)
    }
}

struct IntField: View {
    @Binding var value: Int
    let placeholder: String
    let max: Int

    var body: some View {
        TextField(placeholder, value: $value, formatter: boundedFormatter(max: max))
            .textFieldStyle(.roundedBorder)
            .frame(width: 44)
            .multilineTextAlignment(.center)
    }

    private func boundedFormatter(max: Int) -> NumberFormatter {
        let f = NumberFormatter()
        f.minimum = 0
        f.maximum = NSNumber(value: max)
        f.allowsFloats = false
        return f
    }
}
