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
                // Type-Out Mode row
                FormRow(label: "Type-Out") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.useTypeOutPaste },
                            set: { newValue in
                                config.useTypeOutPaste = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Type-Out Mode")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Type-Out Mode",
                            message: "Types text character-by-character instead of using clipboard paste. This bypasses clipboard detection in apps like Claude Code that show \"pasted text\" overlays."
                        )

                        Spacer()
                    }
                }

                // Shift+Enter for newlines (only shown when type-out mode is enabled)
                if config.useTypeOutPaste {
                    FormDivider()

                    FormRow(label: "Newlines") {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Toggle("", isOn: Binding(
                                get: { config.useShiftEnterForNewlines },
                                set: { newValue in
                                    config.useShiftEnterForNewlines = newValue
                                    onSave()
                                }
                            ))
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()

                            Text("Use Shift+Enter for newlines")
                                .font(Tokens.Typography.bodySmall)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                            InfoTip(
                                title: "Shift+Enter for Newlines",
                                message: "When enabled, newlines are typed using Shift+Enter instead of Enter. Use this for apps like Claude Code where Enter sends the message."
                            )

                            Spacer()
                        }
                    }
                }

                FormDivider()

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
                            message: "Automatically press Enter after the transcription is pasted, sending the message immediately."
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
