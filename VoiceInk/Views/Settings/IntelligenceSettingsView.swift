import SwiftUI

/// Intelligence settings for Adaptive Awareness (context-aware automation)
struct IntelligenceSettingsView: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = false
    @AppStorage(PowerModeDefaults.autoRestoreKey) private var powerModeAutoRestoreEnabled = false
    @State private var showDisableAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Adaptive Awareness Section
                SettingsSection(
                    icon: "sparkles.square.fill.on.square",
                    title: "Adaptive Awareness",
                    subtitle: "Automatically apply custom configurations based on context"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Main toggle and description
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Enable Adaptive Awareness")
                                        .font(.headline)

                                    Text("Automatically apply custom configurations based on the app or website you are using.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                Toggle("Enable Adaptive Awareness", isOn: toggleBinding)
                                    .labelsHidden()
                                    .toggleStyle(.switch)
                            }

                            if powerModeUIFlag {
                                Divider()
                                    .padding(.vertical, 4)
                                    .transition(.opacity.combined(with: .move(edge: .top)))

                                HStack(spacing: 8) {
                                    Toggle(isOn: $powerModeAutoRestoreEnabled) {
                                        Text("Auto-Restore Preferences")
                                    }
                                    .toggleStyle(.switch)

                                    InfoTip(
                                        title: "Auto-Restore Preferences",
                                        message: "After each recording session, revert enhancement and transcription preferences to whatever was configured before Adaptive Awareness was activated."
                                    )
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: powerModeUIFlag)
                    }
                }

                // MARK: - Info Card
                if powerModeUIFlag {
                    infoCard
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // MARK: - Experimental Features Section
                ExperimentalFeaturesSection()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Adaptive Awareness Still Active", isPresented: $showDisableAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Adaptive Awareness can't be disabled while any configuration is still enabled. Disable or remove your configurations first.")
        }
    }

    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { powerModeUIFlag },
            set: { newValue in
                if newValue {
                    powerModeUIFlag = true
                } else if powerModeManager.configurations.noneEnabled {
                    powerModeUIFlag = false
                } else {
                    showDisableAlert = true
                }
            }
        )
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)

                Text("How Adaptive Awareness Works")
                    .font(.headline)
            }

            Text("Adaptive Awareness monitors your active application and browser URLs to automatically apply pre-configured settings. Create rules to customize transcription models, AI enhancement prompts, and other preferences based on your context.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Examples:")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 6) {
                    exampleRow(icon: "doc.text", text: "Use a formal writing prompt when in your word processor")
                    exampleRow(icon: "envelope", text: "Apply email formatting when composing in Mail")
                    exampleRow(icon: "safari", text: "Enable coding prompts when on GitHub or Stack Overflow")
                    exampleRow(icon: "message", text: "Use casual tone when in messaging apps")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(CardBackground(isSelected: false))
    }

    private func exampleRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(text)
        }
    }
}

private extension Array where Element == PowerModeConfig {
    var noneEnabled: Bool {
        allSatisfy { !$0.isEnabled }
    }
}
