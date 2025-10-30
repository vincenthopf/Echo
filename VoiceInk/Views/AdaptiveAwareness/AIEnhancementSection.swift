import SwiftUI

/// AI Enhancement section for AI settings and prompt selection
struct AIEnhancementSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @Environment(\.openSettings) private var openSettings

    private var availableProviders: [AIProvider] {
        aiService.connectedProviders
    }

    private var hasConfiguredProviders: Bool {
        !availableProviders.isEmpty
    }

    private var providerDisplayName: String {
        guard let providerString = config.selectedAIProvider,
              let provider = AIProvider.allCases.first(where: { $0.rawValue == providerString }) else {
            return "Use Global Setting"
        }
        return provider.rawValue
    }

    private var availableModels: [String] {
        guard let providerString = config.selectedAIProvider,
              let provider = AIProvider.allCases.first(where: { $0.rawValue == providerString }) else {
            return []
        }
        return provider.availableModels
    }

    private var modelDisplayName: String {
        guard let model = config.selectedAIModel else { return "Use Global Setting" }
        return model
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Enhancement")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Improve accuracy with AI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Enable Toggle
            Toggle("Enable AI enhancement", isOn: Binding(
                get: { config.isAIEnhancementEnabled },
                set: { newValue in
                    config.isAIEnhancementEnabled = newValue
                    onSave()
                }
            ))
            .toggleStyle(.switch)

            if config.isAIEnhancementEnabled {
                // Empty state warning when no providers configured
                if !hasConfiguredProviders {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("No AI Provider Configured")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text("Add an OpenAI or Anthropic API key to enable enhancement.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Button("Add Key") {
                            // Set the Intelligence tab before opening Settings
                            UserDefaults.standard.set(SettingsTab.intelligence.rawValue, forKey: "selectedSettingsTab")
                            openSettings()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }

                // AI Provider Picker
                if hasConfiguredProviders {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Provider")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker("AI Provider", selection: Binding(
                        get: { config.selectedAIProvider },
                        set: { newValue in
                            config.selectedAIProvider = newValue
                            if newValue != nil {
                                config.selectedAIModel = nil // Reset model when provider changes
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

                // AI Model Picker
                if config.selectedAIProvider != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Model")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Picker("AI Model", selection: Binding(
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

                    Divider()
                        .padding(.vertical, 4)

                    // Prompt Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enhancement Prompt")
                            .font(.subheadline)
                            .fontWeight(.medium)

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

                    Divider()
                        .padding(.vertical, 4)

                    // Screen Capture Toggle
                    HStack(spacing: 8) {
                        Toggle("Capture screen for AI context", isOn: Binding(
                            get: { config.useScreenCapture },
                            set: { newValue in
                                config.useScreenCapture = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)

                        InfoTip(
                            title: "Visual Context",
                            message: "Captures the screen to provide visual context to the AI for better enhancement results. Requires screen recording permission."
                        )
                    }
                } // End of hasConfiguredProviders check
            }
        }
    }
}
