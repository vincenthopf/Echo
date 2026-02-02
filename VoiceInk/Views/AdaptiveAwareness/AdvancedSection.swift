import SwiftUI

/// Advanced section for additional settings
struct AdvancedSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Advanced",
                subtitle: "Additional options"
            )

            // Form container
            VStack(spacing: 0) {
                // Auto-send row
                FormRow(label: "Auto-send") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.isAutoSendEnabled },
                            set: { newValue in
                                config.isAutoSendEnabled = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Send after transcription")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Auto-Send",
                            message: "Automatically paste the transcription to the active text field after transcription completes, without requiring manual confirmation."
                        )

                        Spacer()
                    }
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }
}
