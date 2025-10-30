import SwiftUI

/// Transcription section for model and language selection
struct TranscriptionSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @EnvironmentObject private var whisperState: WhisperState

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
        // Disable for Parakeet and Gemini models
        return model.provider == .parakeet || model.provider == .gemini
    }

    private var availableLanguages: [String: String] {
        guard let model = selectedModel else {
            return PredefinedModels.getLanguageDictionary(isMultilingual: true)
        }
        return model.supportedLanguages
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transcription")
                .font(.headline)
                .foregroundColor(.secondary)

            // Model Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Model")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Menu {
                    Button("Use Global Setting") {
                        config.selectedTranscriptionModelName = nil
                        onSave()
                    }

                    Divider()

                    ForEach(availableModels, id: \.name) { model in
                        Button(action: {
                            config.selectedTranscriptionModelName = model.name
                            onSave()
                        }) {
                            HStack {
                                Text(model.displayName)
                                if config.selectedTranscriptionModelName == model.name {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedModel?.displayName ?? "Use Global Setting")
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

                if let model = selectedModel {
                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Language Picker
            if !isLanguageSelectionDisabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Language")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Menu {
                        Button("Use Global Setting") {
                            config.selectedLanguage = nil
                            onSave()
                        }

                        Divider()

                        ForEach(Array(availableLanguages.keys.sorted()), id: \.self) { langCode in
                            if let langName = availableLanguages[langCode] {
                                Button(action: {
                                    config.selectedLanguage = langCode
                                    onSave()
                                }) {
                                    HStack {
                                        Text(langName)
                                        if config.selectedLanguage == langCode {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            let displayLanguage: String = {
                                if let langCode = config.selectedLanguage,
                                   let langName = availableLanguages[langCode] {
                                    return langName
                                }
                                return "Use Global Setting"
                            }()

                            Text(displayLanguage)
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
            } else {
                Text("Language selection not available for this model")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
