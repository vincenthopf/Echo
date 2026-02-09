import SwiftUI

// MARK: - Window Background Transparency Helper
private class WindowBackgroundHelper: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.isOpaque = false
        window?.backgroundColor = .clear
    }
}

private struct WindowBackgroundModifier: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        WindowBackgroundHelper()
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func transparentWindowBackground() -> some View {
        self.background(WindowBackgroundModifier())
    }
}

struct MiniRecorderView: View {
    @ObservedObject var whisperState: WhisperState
    @ObservedObject var recorder: Recorder
    @EnvironmentObject var windowManager: MiniWindowManager
    @EnvironmentObject private var enhancementService: AIEnhancementService

    @State private var activePopover: ActivePopoverState = .none

    // MARK: - Design Tokens (parallel.ai style)
    private enum Design {
        static let bgColor = ParallelDesignTokens.Colors.darkBg
        static let cardColor = ParallelDesignTokens.Colors.darkCard
        static let borderColor = ParallelDesignTokens.Colors.darkBorder
        static let radius = ParallelDesignTokens.Radius.large
    }

    private var backgroundView: some View {
        ZStack {
            Design.bgColor
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .opacity(0.05)
        }
        .clipShape(Capsule())
    }

    private var statusView: some View {
        RecorderStatusDisplay(
            currentState: whisperState.recordingState,
            audioMeter: recorder.audioMeter
        )
    }

    private var contentLayout: some View {
        HStack(spacing: 0) {
            // Profile badge (compact indicator)
            RecorderProfileBadge(size: .small)
                .padding(.leading, 8)

            Spacer(minLength: 12)

            // Fixed visualizer zone
            statusView

            Spacer(minLength: 12)
        }
        .padding(.vertical, 9)
    }

    private var recorderCapsule: some View {
        Capsule()
            .fill(.clear)
            .background(backgroundView)
            .overlay {
                Capsule()
                    .strokeBorder(Design.borderColor, lineWidth: 1)
            }
            .overlay {
                contentLayout
            }
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
    }

    var body: some View {
        Group {
            if windowManager.isVisible {
                recorderCapsule
            }
        }
    }
}
