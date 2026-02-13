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

                // Type-out sub-settings (only shown when type-out mode is enabled)
                if config.useTypeOutPaste {
                    FormDivider()

                    FormRow(label: "Speed") {
                        VStack(spacing: Tokens.Spacing.xs) {
                            HStack(spacing: Tokens.Spacing.md) {
                                Text("Slow")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                                Slider(
                                    value: Binding(
                                        get: { config.typeOutSpeed },
                                        set: { newValue in
                                            config.typeOutSpeed = newValue
                                            onSave()
                                        }
                                    ),
                                    in: 0.33...3.0
                                )
                                .tint(Tokens.Colors.orange)

                                Text("Fast")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            }
                        }
                    }

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

                FormDivider()

                // Pause media row
                FormRow(label: "Media") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.isPauseMediaEnabled },
                            set: { newValue in
                                config.isPauseMediaEnabled = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Pause media during recording")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Pause Media",
                            message: "Automatically pause active media playback during recordings and resume afterward."
                        )

                        Spacer()
                    }
                }

                FormDivider()

                // Mute system audio row
                FormRow(label: "Mute") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.isSystemMuteEnabled },
                            set: { newValue in
                                config.isSystemMuteEnabled = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Mute system audio during recording")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Mute System Audio",
                            message: "Automatically mute system audio when recording starts and restore when recording stops."
                        )

                        Spacer()
                    }
                }

                FormDivider()

                // Preserve transcript in clipboard row
                FormRow(label: "Clipboard") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.isPreserveTranscriptInClipboard },
                            set: { newValue in
                                config.isPreserveTranscriptInClipboard = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Preserve transcript in clipboard")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Preserve Clipboard",
                            message: "Keep the transcribed text in clipboard instead of restoring the original clipboard content."
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
