import Foundation
import AVFoundation
import AppKit
import KeyboardShortcuts

enum SetupRequirementState: Equatable {
    case complete
    case incomplete
}

struct SetupReadiness: Equatable {
    let microphone: SetupRequirementState
    let hotkey: SetupRequirementState
    let defaultModel: SetupRequirementState
    let accessibility: SetupRequirementState
    let screenRecording: SetupRequirementState

    var requiredComplete: Bool {
        microphone == .complete &&
        hotkey == .complete &&
        defaultModel == .complete
    }
}

enum SetupReadinessEvaluator {
    @MainActor
    static func current(
        whisperState: WhisperState,
        hotkeyManager: HotkeyManager
    ) -> SetupReadiness {
        evaluate(
            microphoneAuthorized: AVCaptureDevice.authorizationStatus(for: .audio) == .authorized,
            hotkeyConfigured: hotkeyManager.selectedHotkey1 != .none,
            hasUsableDefaultModel: hasUsableDefaultModel(whisperState: whisperState),
            accessibilityEnabled: AXIsProcessTrusted(),
            screenRecordingEnabled: CGPreflightScreenCaptureAccess()
        )
    }

    static func evaluate(
        microphoneAuthorized: Bool,
        hotkeyConfigured: Bool,
        hasUsableDefaultModel: Bool,
        accessibilityEnabled: Bool,
        screenRecordingEnabled: Bool
    ) -> SetupReadiness {
        SetupReadiness(
            microphone: microphoneAuthorized ? .complete : .incomplete,
            hotkey: hotkeyConfigured ? .complete : .incomplete,
            defaultModel: hasUsableDefaultModel ? .complete : .incomplete,
            accessibility: accessibilityEnabled ? .complete : .incomplete,
            screenRecording: screenRecordingEnabled ? .complete : .incomplete
        )
    }

    @MainActor
    private static func hasUsableDefaultModel(whisperState: WhisperState) -> Bool {
        guard let current = whisperState.currentTranscriptionModel else {
            return false
        }
        return whisperState.usableModels.contains { $0.name == current.name }
    }
}
