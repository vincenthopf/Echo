import Foundation
import AppKit
import os

class ActiveWindowService: ObservableObject {
    static let shared = ActiveWindowService()
    @Published var currentApplication: NSRunningApplication?
    private var enhancementService: AIEnhancementService?
    private let browserURLService = BrowserURLService.shared
    private var whisperState: WhisperState?
    
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

        if let browserType = BrowserType.allCases.first(where: { $0.bundleIdentifier == bundleIdentifier }) {
            do {
                let currentURL = try await browserURLService.getCurrentURL(from: browserType)
                if let config = PowerModeManager.shared.getConfigurationForURL(currentURL) {
                    configToApply = config
                }
            } catch {
                logger.error("❌ Failed to get URL from \(browserType.displayName): \(error.localizedDescription)")
            }
        }

        if configToApply == nil {
            configToApply = PowerModeManager.shared.getConfigurationForApp(bundleIdentifier)
        }

        if configToApply == nil {
            configToApply = PowerModeManager.shared.getDefaultConfiguration()
        }

        if let config = configToApply {
            await MainActor.run {
                PowerModeManager.shared.setActiveConfiguration(config)
            }
            await PowerModeSessionManager.shared.beginSession(with: config)
        } else {
            // If no config found, keep the current active configuration (don't clear it)
        }
    }
} 
