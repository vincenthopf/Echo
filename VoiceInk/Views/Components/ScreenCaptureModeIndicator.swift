import SwiftUI

/// Shows whether Vision mode (sending image) or OCR mode (sending text) will be used
/// for screen capture context based on the current AI provider and model capabilities
struct ScreenCaptureModeIndicator: View {
    @ObservedObject var aiService: AIService
    let colorScheme: ColorScheme

    private var isVisionMode: Bool {
        aiService.selectedProvider == .openRouter && aiService.currentModelSupportsVision()
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isVisionMode ? "eye.fill" : "doc.text.fill")
                .font(.system(size: 10))
            Text(isVisionMode ? "Vision" : "OCR")
                .font(Tokens.Typography.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            isVisionMode
                ? Color.purple.opacity(0.15)
                : Tokens.Colors.orangeSoft(for: colorScheme)
        )
        .foregroundColor(
            isVisionMode
                ? .purple
                : Tokens.Colors.orange
        )
        .clipShape(Capsule())
        .help(isVisionMode
            ? "Vision Mode: Screenshot image will be sent directly to the AI model"
            : "OCR Mode: Text will be extracted from screenshot and sent to the AI model")
    }
}
