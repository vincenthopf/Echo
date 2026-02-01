import SwiftUI

/// Right panel detail view for editing a profile
/// Uses VoiceInk design tokens for clean, grid-based styling
struct ProfileDetailView: View {
    let config: PowerModeConfig

    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var whisperState: WhisperState
    @Environment(\.colorScheme) private var colorScheme

    // Local state for editing (changes save automatically on blur)
    @State private var editedConfig: PowerModeConfig

    init(config: PowerModeConfig) {
        self.config = config
        _editedConfig = State(initialValue: config)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xxxl) {
                // General Section
                GeneralSection(config: $editedConfig, onSave: saveChanges)

                sectionDivider

                // Activation Triggers Section
                ActivationTriggersSection(config: $editedConfig, onSave: saveChanges)

                sectionDivider

                // Transcription Section
                TranscriptionSection(config: $editedConfig, onSave: saveChanges)

                sectionDivider

                // AI Enhancement Section
                AIEnhancementSection(config: $editedConfig, onSave: saveChanges)

                sectionDivider

                // Advanced Section
                AdvancedSection(config: $editedConfig, onSave: saveChanges)
            }
            .padding(Tokens.Spacing.xxl)
        }
        .safeAreaPadding(.top, 0)
        .background(Tokens.Colors.background(for: colorScheme))
        .onChange(of: config) { _, newConfig in
            // Reload from manager if config changes externally
            if let latestConfig = powerModeManager.getConfiguration(with: newConfig.id) {
                editedConfig = latestConfig
            }
        }
    }

    /// Simple divider between sections
    private var sectionDivider: some View {
        Rectangle()
            .fill(Tokens.Colors.border(for: colorScheme))
            .frame(height: 1)
    }

    private func saveChanges() {
        powerModeManager.updateConfiguration(editedConfig)
    }
}
