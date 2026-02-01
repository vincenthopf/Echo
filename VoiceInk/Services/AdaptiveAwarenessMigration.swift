import Foundation
import os

/// Migration utility for transitioning from standalone prompts with trigger words
/// to unified PowerModeConfig-based Adaptive Awareness system.
///
/// This migration runs once on first launch after the Adaptive Awareness update and:
/// 1. Preserves all existing PowerModeConfig objects (they auto-gain empty triggerWords array)
/// 2. Finds CustomPrompt objects with non-empty triggerWords
/// 3. Creates new PowerModeConfig instances for voice-activated prompts
/// 4. Marks migration complete to prevent re-execution
class AdaptiveAwarenessMigration {
    private static let logger = Logger(subsystem: "com.VincentHopf.embrvoice", category: "AdaptiveAwarenessMigration")
    private static let migrationKey = "didMigrateToAdaptiveAwareness"

    /// Performs one-time migration from standalone prompts with trigger words
    /// to PowerModeConfig-based Adaptive Awareness system
    ///
    /// This method is safe to call multiple times - it will only execute once
    static func performMigration() {
        // Check if migration has already been completed
        if UserDefaults.standard.bool(forKey: migrationKey) {
            logger.info("Adaptive Awareness migration already completed, skipping")
            return
        }

        logger.info("Starting Adaptive Awareness migration...")

        do {
            // Load existing PowerModeConfigs (they will auto-decode with empty triggerWords)
            let powerModeManager = PowerModeManager.shared
            logger.info("Loaded \(powerModeManager.configurations.count) existing PowerModeConfigs")

            // Load CustomPrompts from UserDefaults
            guard let savedPromptsData = UserDefaults.standard.data(forKey: "customPrompts"),
                  let customPrompts = try? JSONDecoder().decode([CustomPrompt].self, from: savedPromptsData) else {
                logger.info("No custom prompts found, completing migration")
                markMigrationComplete()
                return
            }

            logger.info("Found \(customPrompts.count) custom prompts")

            // Find prompts with non-empty trigger words
            let promptsWithTriggers = customPrompts.filter { !$0.triggerWords.isEmpty }
            logger.info("Found \(promptsWithTriggers.count) prompts with trigger words")

            // Create PowerModeConfigs for each prompt with trigger words
            var migratedCount = 0
            for prompt in promptsWithTriggers {
                // Create new PowerModeConfig with voice triggers only
                let newConfig = PowerModeConfig(
                    name: "\(prompt.title) (Voice)",
                    emoji: prompt.icon.rawValue.isEmpty ? "🎤" : "🎤", // Use microphone emoji for voice-activated
                    appConfigs: nil, // No app triggers
                    urlConfigs: nil, // No URL triggers
                    isAIEnhancementEnabled: true, // Enable AI enhancement since this is from a prompt
                    selectedPrompt: prompt.id.uuidString, // Link to the original prompt
                    selectedTranscriptionModelName: nil, // Use default
                    selectedLanguage: nil, // Use default
                    useScreenCapture: false, // Default setting
                    selectedAIProvider: nil, // Use default
                    selectedAIModel: nil, // Use default
                    isAutoSendEnabled: false, // Default setting
                    isEnabled: prompt.isActive, // Match the active state of the original prompt
                    isDefault: false, // Don't set as default
                    triggerWords: prompt.triggerWords // Migrate trigger words
                )

                powerModeManager.addConfiguration(newConfig)
                migratedCount += 1

                logger.info("Migrated prompt '\(prompt.title)' with \(prompt.triggerWords.count) trigger words to PowerModeConfig")
            }

            logger.info("Successfully migrated \(migratedCount) prompts to PowerModeConfigs")

            // Mark migration as complete
            markMigrationComplete()

        } catch {
            logger.error("Error during Adaptive Awareness migration: \(error.localizedDescription)")
            // Don't mark as complete if there was an error - allow retry on next launch
        }
    }

    /// Marks the migration as complete in UserDefaults
    private static func markMigrationComplete() {
        UserDefaults.standard.set(true, forKey: migrationKey)
        logger.info("Adaptive Awareness migration marked as complete")
    }

    /// Resets the migration flag (useful for testing)
    static func resetMigration() {
        UserDefaults.standard.removeObject(forKey: migrationKey)
        logger.info("Adaptive Awareness migration flag reset")
    }
}
