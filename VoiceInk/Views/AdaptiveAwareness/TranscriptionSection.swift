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
            VStack(alignment: .leading, spacing: 2) {
                Text("Transcription")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Language and model settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Model Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Model")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Picker("Model", selection: Binding(
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

                    Picker("Language", selection: Binding(
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
                }
            } else {
                Text("Language selection not available for this model")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
