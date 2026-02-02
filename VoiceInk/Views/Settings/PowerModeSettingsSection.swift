import SwiftUI

struct PowerModeSettingsSection: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = true
    @AppStorage(PowerModeDefaults.autoRestoreKey) private var powerModeAutoRestoreEnabled = true
    @State private var showDisableAlert = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Adaptive Awareness",
                subtitle: "Automatically apply custom configurations based on the app or website you are using"
            )

            VStack(spacing: 0) {
                // Enable adaptive awareness row
                FormRow(label: "Enable") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: toggleBinding)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()

                        Text("Enable Adaptive Awareness")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        Spacer()

                        Image(systemName: "sparkles.square.fill.on.square")
                            .font(.system(size: 16))
                            .foregroundColor(Tokens.Colors.orange)
                    }
                }

                if powerModeUIFlag {
                    FormDivider()
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    // Auto-restore row
                    FormRow(label: "Restore") {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Toggle("", isOn: $powerModeAutoRestoreEnabled)
                                .toggleStyle(.switch)
                                .tint(Tokens.Colors.orange)
                                .labelsHidden()

                            Text("Auto-restore preferences")
                                .font(Tokens.Typography.bodySmall)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                            InfoTip(
                                title: "Auto-Restore Preferences",
                                message: "After each recording session, revert enhancement and transcription preferences to whatever was configured before Adaptive Awareness was activated."
                            )

                            Spacer()
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.25), value: powerModeUIFlag)
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

}

private extension Array where Element == PowerModeConfig {
    var noneEnabled: Bool {
        allSatisfy { !$0.isEnabled }
    }
}

enum PowerModeDefaults {
    static let autoRestoreKey = "powerModeAutoRestoreEnabled"
}
