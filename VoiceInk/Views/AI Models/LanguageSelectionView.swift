import SwiftUI

// Define a display mode for flexible usage
enum LanguageDisplayMode {
    case full // For settings page with descriptions
    case menuItem // For menu bar with compact layout
}

struct LanguageSelectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var whisperState: WhisperState
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    // Add display mode parameter with full as the default
    var displayMode: LanguageDisplayMode = .full
    @ObservedObject var whisperPrompt: WhisperPrompt

    private func updateLanguage(_ language: String) {
        // Update UI state - the UserDefaults updating is now automatic with @AppStorage
        selectedLanguage = language

        // Force the prompt to update for the new language
        whisperPrompt.updateTranscriptionPrompt()

        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
        NotificationCenter.default.post(name: .AppSettingsDidChange, object: nil)
    }
    
    // Function to check if current model is multilingual
    private func isMultilingualModel() -> Bool {
        guard let currentModel = whisperState.currentTranscriptionModel else {
            return false
        }
        return currentModel.isMultilingualModel
    }

    private func languageSelectionDisabled() -> Bool {
        guard let provider = whisperState.currentTranscriptionModel?.provider else {
            return false
        }
        return provider == .parakeet || provider == .gemini
    }

    // Function to get current model's supported languages
    private func getCurrentModelLanguages() -> [String: String] {
        guard let currentModel = whisperState.currentTranscriptionModel else {
            return ["en": "English"] // Default to English if no model found
        }
        return currentModel.supportedLanguages
    }

    // Get the display name of the current language
    private func currentLanguageDisplayName() -> String {
        return getCurrentModelLanguages()[selectedLanguage] ?? "Unknown"
    }

    var body: some View {
        switch displayMode {
        case .full:
            fullView
        case .menuItem:
            menuItemView
        }
    }

    // The original full view layout for settings page
    private var fullView: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            languageSelectionSection
        }
    }

    private var languageSelectionSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
            Text("Language")
                .font(Tokens.Typography.label)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

            if let currentModel = whisperState.currentTranscriptionModel
            {
                if languageSelectionDisabled() {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        Text("Language: Autodetected")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Text("The transcription language is automatically detected by the model.")
                            .font(Tokens.Typography.caption)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }
                    .disabled(true)
                } else if isMultilingualModel() {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        Picker("Select Language", selection: $selectedLanguage) {
                            ForEach(
                                currentModel.supportedLanguages.sorted(by: {
                                    if $0.key == "auto" { return true }
                                    if $1.key == "auto" { return false }
                                    return $0.value < $1.value
                                }), id: \.key
                            ) { key, value in
                                Text(value).tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(Tokens.Colors.orange)
                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            updateLanguage(newValue)
                        }

                        Text(
                            "This model supports multiple languages. Select a specific language or auto-detect (if available)."
                        )
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }
                } else {
                    // For English-only models, force set language to English
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        Text("Language: English")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Text(
                            "This is an English-optimized model and only supports English transcription."
                        )
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }
                    .onAppear {
                        // Ensure English is set when viewing English-only model
                        updateLanguage("en")
                    }
                }
            } else {
                Text("No model selected")
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // New compact view for menu bar
    private var menuItemView: some View {
        Group {
            if languageSelectionDisabled() {
                Button {
                    // Do nothing, just showing info
                } label: {
                    Text("Language: Autodetected")
                        .foregroundColor(.secondary)
                }
                .disabled(true)
            } else if isMultilingualModel() {
                Menu {
                    ForEach(
                        getCurrentModelLanguages().sorted(by: {
                            if $0.key == "auto" { return true }
                            if $1.key == "auto" { return false }
                            return $0.value < $1.value
                        }), id: \.key
                    ) { key, value in
                        Button {
                            updateLanguage(key)
                        } label: {
                            HStack {
                                Text(value)
                                if selectedLanguage == key {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Language: \(currentLanguageDisplayName())")
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10))
                    }
                }
            } else {
                // For English-only models
                Button {
                    // Do nothing, just showing info
                } label: {
                    Text("Language: English (only)")
                        .foregroundColor(.secondary)
                }
                .disabled(true)
                .onAppear {
                    // Ensure English is set for English-only models
                    updateLanguage("en")
                }
            }
        }
    }
}
