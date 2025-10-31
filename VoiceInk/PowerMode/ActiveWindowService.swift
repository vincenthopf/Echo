import Foundation
import AppKit
import os

class ActiveWindowService: ObservableObject {
    static let shared = ActiveWindowService()
    @Published var currentApplication: NSRunningApplication?
    private var enhancementService: AIEnhancementService?
    private let browserURLService = BrowserURLService.shared
    private var whisperState: WhisperState?
    private let promptDetectionService = PromptDetectionService()

    private let logger = Logger(
        subsystem: "com.VincentHopf.embrvoice",
        category: "browser.detection"
    )

    private init() {}
    
    func configure(with enhancementService: AIEnhancementService) {
        self.enhancementService = enhancementService
    }
    
    func configureWhisperState(_ whisperState: WhisperState) {
        self.whisperState = whisperState
    }
    
    func applyConfigurationForCurrentApp() async {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let bundleIdentifier = frontmostApp.bundleIdentifier else {
            return
        }

        await MainActor.run {
            currentApplication = frontmostApp
        }

        var configToApply: PowerModeConfig?
        var activationSource: ActivationSource?

        // Get current URL if in a browser
        var currentURL: String?
        if let browserType = BrowserType.allCases.first(where: { $0.bundleIdentifier == bundleIdentifier }) {
            do {
                currentURL = try await browserURLService.getCurrentURL(from: browserType)
            } catch {
                logger.error("❌ Failed to get URL from \(browserType.displayName): \(error.localizedDescription)")
            }
        }

        // Find matching configuration based on logic mode
        if let config = PowerModeManager.shared.findMatchingConfiguration(
            bundleId: bundleIdentifier,
            url: currentURL,
            voiceTrigger: nil  // Voice triggers are handled separately during transcription
        ) {
            configToApply = config

            // Determine activation source based on what matched
            if let url = currentURL, config.urlConfigs?.contains(where: {
                let cleanURL = PowerModeManager.shared.cleanURL($0.url)
                return PowerModeManager.shared.cleanURL(url).contains(cleanURL)
            }) == true {
                activationSource = .url(pattern: url)
            } else {
                activationSource = .app(bundleID: bundleIdentifier)
            }
        }

        // Use default configuration as fallback
        if configToApply == nil {
            if let config = PowerModeManager.shared.getDefaultConfiguration() {
                configToApply = config
                activationSource = .defaultProfile
            }
        }

        if let config = configToApply {
            await MainActor.run {
                PowerModeManager.shared.setActiveConfiguration(config)
            }
            await PowerModeSessionManager.shared.beginSession(with: config, activationSource: activationSource)
        } else {
            // If no config found, keep the current active configuration (don't clear it)
        }
    }

    // MARK: - Voice Trigger Detection

    /// Detects voice trigger words in transcribed text and returns matching config with stripped text
    /// - Parameter text: The transcribed text to analyze for trigger words
    /// - Returns: A tuple containing the matched PowerModeConfig (if any), the detected keyword, and the text with trigger word removed
    func detectVoiceTrigger(in text: String) -> (config: PowerModeConfig?, detectedKeyword: String?, strippedText: String) {
        // Get all trigger words from PowerModeManager
        let triggerWordMap = PowerModeManager.shared.allTriggerWords()

        // Convert to array of trigger words for detection service
        let allTriggerWords = Array(triggerWordMap.keys)

        // Use PromptDetectionService logic to detect and strip trigger words
        if let (detectedWord, processedText) = promptDetectionService.detectAndStripTriggerWord(
            from: text,
            triggerWords: allTriggerWords
        ) {
            // Find the matching config for the detected trigger word
            if let matchedConfig = triggerWordMap[detectedWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] {
                logger.notice("✅ Voice trigger detected: '\(detectedWord)' -> Config: '\(matchedConfig.name)'")
                return (matchedConfig, detectedWord, processedText)
            }
        }

        logger.debug("No voice trigger detected in text")
        return (nil, nil, text)
    }
} 
