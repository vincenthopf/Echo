import SwiftUI
import SwiftData
import Charts
import KeyboardShortcuts

struct MetricsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Transcription.timestamp) private var transcriptions: [Transcription]
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    let skipSetupCheck: Bool

    init(skipSetupCheck: Bool = false) {
        self.skipSetupCheck = skipSetupCheck
    }

    var body: some View {
        VStack {
            Group {
                if skipSetupCheck {
                    MetricsContent(transcriptions: Array(transcriptions))
                } else if setupReadiness.requiredComplete {
                    MetricsContent(transcriptions: Array(transcriptions))
                } else {
                    MetricsSetupView()
                }
            }
        }
        .background(ParallelDesignTokens.Colors.background(for: colorScheme))
    }

    private var setupReadiness: SetupReadiness {
        SetupReadinessEvaluator.current(
            whisperState: whisperState,
            hotkeyManager: hotkeyManager
        )
    }
}
