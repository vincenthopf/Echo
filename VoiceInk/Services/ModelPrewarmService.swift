import Foundation
import SwiftData
import os
import AppKit

/// Service that prewarms transcription models on app launch and system wake.
/// Prewarming loads the model and runs a short transcription to compile the
/// Neural Engine operators, making the first real transcription faster.
@MainActor
final class ModelPrewarmService: ObservableObject {
    private let whisperState: WhisperState
    private let logger = Logger(subsystem: "com.VincentHopf.embrvoice", category: "ModelPrewarm")
    private let prewarmAudioURL = Bundle.main.url(forResource: "esc", withExtension: "wav")
    private let prewarmEnabledKey = "PrewarmModelOnWake"

    init(whisperState: WhisperState) {
        self.whisperState = whisperState
        setupNotifications()
        schedulePrewarmOnAppLaunch()
    }

    // MARK: - Notification Setup

    private func setupNotifications() {
        let center = NSWorkspace.shared.notificationCenter

        // Trigger on wake from sleep
        center.addObserver(
            self,
            selector: #selector(schedulePrewarm),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )

        logger.notice("ModelPrewarmService initialized - listening for wake and app launch")
    }

    // MARK: - Trigger Handlers

    /// Trigger on app launch (cold start)
    private func schedulePrewarmOnAppLaunch() {
        logger.notice("App launched, scheduling prewarm")
        Task {
            try? await Task.sleep(for: .seconds(3))
            await performPrewarm()
        }
    }

    /// Trigger on wake from sleep or screen unlock
    @objc private func schedulePrewarm() {
        logger.notice("Mac activity detected (wake/unlock), scheduling prewarm")
        Task {
            try? await Task.sleep(for: .seconds(3))
            await performPrewarm()
        }
    }

    // MARK: - Core Prewarming Logic

    private func performPrewarm() async {
        guard shouldPrewarm() else { return }

        guard let audioURL = prewarmAudioURL else {
            logger.error("Prewarm audio file (esc.wav) not found")
            return
        }

        guard let currentModel = whisperState.currentTranscriptionModel else {
            logger.notice("No model selected, skipping prewarm")
            return
        }

        logger.notice("Prewarming \(currentModel.displayName)")
        let startTime = Date()

        do {
            let _ = try await transcribe(audioURL: audioURL, model: currentModel)
            let duration = Date().timeIntervalSince(startTime)

            logger.notice("Prewarm completed in \(String(format: "%.2f", duration))s")

        } catch {
            logger.error("Prewarm failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Transcription Helper

    /// Transcribe audio using the service registry.
    /// Uses WhisperState's existing service registry for unified transcription access.
    private func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        // Use the service registry which provides access to all transcription services
        return try await whisperState.serviceRegistry.transcribe(audioURL: audioURL, model: model)
    }

    // MARK: - Validation

    private func shouldPrewarm() -> Bool {
        // Check if user has enabled prewarming
        let isEnabled = UserDefaults.standard.bool(forKey: prewarmEnabledKey)
        guard isEnabled else {
            logger.notice("Prewarm disabled by user")
            return false
        }

        // Only prewarm local models (Parakeet and Whisper need ANE compilation)
        guard let model = whisperState.currentTranscriptionModel else {
            return false
        }

        switch model.provider {
        case .local, .parakeet:
            return true
        default:
            logger.notice("Skipping prewarm - cloud models don't need it")
            return false
        }
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        logger.notice("ModelPrewarmService deinitialized")
    }
}

// MARK: - Errors

private enum PrewarmError: LocalizedError {
    case cloudModelNotSupported

    var errorDescription: String? {
        switch self {
        case .cloudModelNotSupported:
            return "Cloud models do not need prewarming"
        }
    }
}
