import Foundation
import SwiftUI
import os

/// Centralized registry for transcription services.
/// Provides lazy initialization and unified access to all transcription providers.
@MainActor
class TranscriptionServiceRegistry {
    private let whisperState: WhisperState
    private let modelsDirectory: URL
    private let logger = Logger(subsystem: "com.VincentHopf.embrvoice", category: "TranscriptionServiceRegistry")

    private(set) lazy var localTranscriptionService = LocalTranscriptionService(
        modelsDirectory: modelsDirectory,
        whisperState: whisperState
    )

    // Note: Local CloudTranscriptionService takes no parameters (differs from upstream)
    private(set) lazy var cloudTranscriptionService = CloudTranscriptionService()
    private(set) lazy var nativeAppleTranscriptionService = NativeAppleTranscriptionService()
    private(set) lazy var parakeetTranscriptionService = ParakeetTranscriptionService()

    init(whisperState: WhisperState, modelsDirectory: URL) {
        self.whisperState = whisperState
        self.modelsDirectory = modelsDirectory
    }

    func service(for provider: ModelProvider) -> TranscriptionService {
        switch provider {
        case .local:
            return localTranscriptionService
        case .parakeet:
            return parakeetTranscriptionService
        case .nativeApple:
            return nativeAppleTranscriptionService
        default:
            return cloudTranscriptionService
        }
    }

    func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        let service = service(for: model.provider)
        logger.debug("Transcribing with \(model.displayName) using \(String(describing: type(of: service)))")
        return try await service.transcribe(audioURL: audioURL, model: model)
    }

    func cleanup() {
        parakeetTranscriptionService.cleanup()
    }
}
