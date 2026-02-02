import SwiftUI

/// Transcription section for model and language selection
struct TranscriptionSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @EnvironmentObject private var whisperState: WhisperState
    @Environment(\.colorScheme) private var colorScheme

    private var availableModels: [any TranscriptionModel] {
        whisperState.allAvailableModels
    }

    private var selectedModel: (any TranscriptionModel)? {
        if let modelName = config.selectedTranscriptionModelName {
            return availableModels.first { $0.name == modelName }
        }
        return whisperState.currentTranscriptionModel
    }

    private var isLanguageSelectionDisabled: Bool {
        guard let model = selectedModel else { return false }
        return model.provider == .parakeet || model.provider == .gemini
    }

    private var availableLanguages: [String: String] {
        guard let model = selectedModel else {
            return PredefinedModels.getLanguageDictionary(isMultilingual: true)
        }
        return model.supportedLanguages
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Transcription",
                subtitle: "Language and model settings"
            )

            // Form container
            VStack(spacing: 0) {
                // Model row
                FormRow(label: "Model") {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                        Picker("", selection: Binding(
                            get: { config.selectedTranscriptionModelName },
                            set: { newValue in
                                config.selectedTranscriptionModelName = newValue
                                onSave()
                            }
                        )) {
                            Text("Use Global Setting").tag(nil as String?)

                            Divider()

                            ForEach(availableModels, id: \.name) { model in
                                Text(model.displayName).tag(model.name as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        if let model = selectedModel {
                            Text(model.description)
                                .font(Tokens.Typography.bodySmall)
                                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                        }
                    }
                }

                FormDivider()

                // Language row
                FormRow(label: "Language") {
                    if !isLanguageSelectionDisabled {
                        Picker("", selection: Binding(
                            get: { config.selectedLanguage },
                            set: { newValue in
                                config.selectedLanguage = newValue
                                onSave()
                            }
                        )) {
                            Text("Use Global Setting").tag(nil as String?)

                            Divider()

                            ForEach(Array(availableLanguages.keys.sorted()), id: \.self) { langCode in
                                if let langName = availableLanguages[langCode] {
                                    Text(langName).tag(langCode as String?)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    } else {
                        Text("Not available for this model")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
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
