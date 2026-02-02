import SwiftUI

struct AnimatedCopyButton: View {
    let textToCopy: String
    @Environment(\.colorScheme) private var colorScheme
    @State private var isCopied: Bool = false

    var body: some View {
        Button {
            copyToClipboard()
        } label: {
            HStack(spacing: ParallelDesignTokens.Spacing.xs) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12, weight: isCopied ? .bold : .regular))
                    .foregroundColor(.white)
                Text(isCopied ? "Copied" : "Copy")
                    .font(ParallelDesignTokens.Typography.label)
                    .fontWeight(isCopied ? .medium : .regular)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, ParallelDesignTokens.Spacing.sm)
            .padding(.vertical, ParallelDesignTokens.Spacing.xs)
            .background(
                Capsule()
                    .fill(isCopied ? ParallelDesignTokens.Colors.success : ParallelDesignTokens.Colors.primaryOrange)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isCopied ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
    }

    private func copyToClipboard() {
        let _ = ClipboardManager.copyToClipboard(textToCopy)
        withAnimation {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isCopied = false
            }
        }
    }
}

struct AnimatedCopyButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnimatedCopyButton(textToCopy: "Sample text")
            Text("Before Copy")
                .padding()
        }
        .padding()
    }
} 