import SwiftUI

/// AI Enhancement section for AI settings and prompt selection
struct AIEnhancementSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var menuBarManager: MenuBarManager
    @Environment(\.colorScheme) private var colorScheme

    private var availableProviders: [AIProvider] {
        aiService.connectedProviders
    }

    private var hasConfiguredProviders: Bool {
        !availableProviders.isEmpty
    }

    private var availableModels: [String] {
        guard let providerString = config.selectedAIProvider,
              let provider = AIProvider.allCases.first(where: { $0.rawValue == providerString }) else {
            return []
        }
        return provider.availableModels
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Intelligent Transformation",
                subtitle: "Improve accuracy with AI"
            )

            // Form container
            VStack(spacing: 0) {
                // Enable toggle row
                FormRow(label: "Enabled") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.isAIEnhancementEnabled },
                            set: { newValue in
                                config.isAIEnhancementEnabled = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Enable Intelligent Transformation")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        Spacer()
                    }
                }

                if config.isAIEnhancementEnabled {
                    // Warning if no providers configured
                    if !hasConfiguredProviders {
                        FormDivider()

                        HStack(spacing: Tokens.Spacing.md) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Tokens.Colors.orange)
                                .font(.system(size: 16))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("No AI Provider Configured")
                                    .font(Tokens.Typography.bodyMedium)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                                Text("Add an OpenAI or Anthropic API key to enable enhancement.")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            }

                            Spacer()

                            Button("Add Key") {
                                UserDefaults.standard.set(SettingsTab.intelligence.rawValue, forKey: "selectedSettingsTab")
                                menuBarManager.navigateTo(.settings)
                            }
                            .buttonStyle(.bordered)
                            .tint(Tokens.Colors.orange)
                            .controlSize(.small)
                        }
                        .padding(Tokens.Spacing.lg)
                        .background(Tokens.Colors.orangeSoft(for: colorScheme))
                    }

                    if hasConfiguredProviders {
                        FormDivider()

                        // Provider row
                        FormRow(label: "Provider") {
                            Picker("", selection: Binding(
                                get: { config.selectedAIProvider },
                                set: { newValue in
                                    config.selectedAIProvider = newValue
                                    if newValue != nil {
                                        config.selectedAIModel = nil
                                    }
                                    onSave()
                                }
                            )) {
                                Text("Use Global Setting").tag(nil as String?)

                                Divider()

                                ForEach(availableProviders, id: \.self) { provider in
                                    Text(provider.rawValue).tag(provider.rawValue as String?)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }

                        // Model row (only if provider selected)
                        if config.selectedAIProvider != nil {
                            FormDivider()

                            FormRow(label: "Model") {
                                Picker("", selection: Binding(
                                    get: { config.selectedAIModel },
                                    set: { newValue in
                                        config.selectedAIModel = newValue
                                        onSave()
                                    }
                                )) {
                                    Text("Use Global Setting").tag(nil as String?)

                                    Divider()

                                    ForEach(availableModels, id: \.self) { model in
                                        Text(model).tag(model as String?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }

                        FormDivider()

                        // Prompt row
                        FormRow(label: "Prompt") {
                            EnhancedPromptSelector(
                                selectedPromptId: Binding(
                                    get: { config.selectedPrompt },
                                    set: { newValue in
                                        config.selectedPrompt = newValue
                                        onSave()
                                    }
                                ),
                                onSave: onSave
                            )
                        }

                        FormDivider()

                        // Screen capture row
                        FormRow(label: "Context") {
                            HStack(spacing: Tokens.Spacing.sm) {
                                Toggle("", isOn: Binding(
                                    get: { config.useScreenCapture },
                                    set: { newValue in
                                        config.useScreenCapture = newValue
                                        onSave()
                                    }
                                ))
                                .toggleStyle(.switch)
                                .labelsHidden()

                                Text("Capture screen for AI context")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                                InfoTip(
                                    title: "Visual Context",
                                    message: "Captures the screen to provide visual context to the AI for better enhancement results. Requires screen recording permission."
                                )

                                Spacer()
                            }
                        }
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
