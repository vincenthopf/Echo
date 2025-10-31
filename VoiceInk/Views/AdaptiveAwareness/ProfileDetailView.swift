import SwiftUI

/// Right panel detail view for editing a profile
struct ProfileDetailView: View {
    let config: PowerModeConfig

    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var whisperState: WhisperState

    // Local state for editing (changes save automatically on blur)
    @State private var editedConfig: PowerModeConfig

    init(config: PowerModeConfig) {
        self.config = config
        _editedConfig = State(initialValue: config)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // General Section
                GeneralSection(config: $editedConfig, onSave: saveChanges)

                Divider()

                // Activation Triggers Section
                ActivationTriggersSection(config: $editedConfig, onSave: saveChanges)

                Divider()

                // Transcription Section
                TranscriptionSection(config: $editedConfig, onSave: saveChanges)

                Divider()

                // AI Enhancement Section
                AIEnhancementSection(config: $editedConfig, onSave: saveChanges)

                Divider()

                // Advanced Section
                AdvancedSection(config: $editedConfig, onSave: saveChanges)
            }
            .padding(24)
        }
        .safeAreaPadding(.top, 0)
        .background(Color(NSColor.controlBackgroundColor))
        .onChange(of: config) { _, newConfig in
            // Reload from manager if config changes externally
            if let latestConfig = powerModeManager.getConfiguration(with: newConfig.id) {
                editedConfig = latestConfig
            }
        }
    }

    private func saveChanges() {
        powerModeManager.updateConfiguration(editedConfig)
    }
}
