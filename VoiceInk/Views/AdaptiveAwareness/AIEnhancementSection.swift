import SwiftUI

/// AI Enhancement section for AI settings and prompt selection
struct AIEnhancementSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService

    private var availableProviders: [String] {
        ["openai", "anthropic"]
    }

    private var providerDisplayName: String {
        guard let provider = config.selectedAIProvider else { return "Use Global Setting" }
        switch provider.lowercased() {
        case "openai": return "OpenAI"
        case "anthropic": return "Anthropic"
        default: return provider.capitalized
        }
    }

    private var availableModels: [String] {
        guard let provider = config.selectedAIProvider else { return [] }
        switch provider.lowercased() {
        case "openai":
            return ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo"]
        case "anthropic":
            return ["claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-opus-20240229"]
        default:
            return []
        }
    }

    private var modelDisplayName: String {
        guard let model = config.selectedAIModel else { return "Use Global Setting" }
        return model
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Enhancement")
                .font(.headline)
                .foregroundColor(.secondary)

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
                // AI Provider Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Provider")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Menu {
                        Button("Use Global Setting") {
                            config.selectedAIProvider = nil
                            config.selectedAIModel = nil
                            onSave()
                        }

                        Divider()

                        ForEach(availableProviders, id: \.self) { provider in
                            Button(action: {
                                config.selectedAIProvider = provider
                                config.selectedAIModel = nil // Reset model when provider changes
                                onSave()
                            }) {
                                HStack {
                                    Text(provider == "openai" ? "OpenAI" : "Anthropic")
                                    if config.selectedAIProvider == provider {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(providerDisplayName)
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .menuStyle(.borderlessButton)
                }

                // AI Model Picker
                if config.selectedAIProvider != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Model")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Menu {
                            Button("Use Global Setting") {
                                config.selectedAIModel = nil
                                onSave()
                            }

                            Divider()

                            ForEach(availableModels, id: \.self) { model in
                                Button(action: {
                                    config.selectedAIModel = model
                                    onSave()
                                }) {
                                    HStack {
                                        Text(model)
                                        if config.selectedAIModel == model {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(modelDisplayName)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .menuStyle(.borderlessButton)
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
                    Toggle("Use screen capture for visual context", isOn: Binding(
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
            }
        }
    }
}
