import SwiftUI

// Style Constants for consistent styling across components
// Refactored to use parallel.ai design tokens - clean, minimal, no glassmorphism
struct StyleConstants {
    // Corner Radius - Using parallel.ai standard
    static let cornerRadius: CGFloat = ParallelDesignTokens.Radius.large // 12pt

    // Shadow - Subtle, minimal
    static let shadowColor = ParallelDesignTokens.Shadow.color
    static let shadowRadius = ParallelDesignTokens.Shadow.radius
    static let shadowY = ParallelDesignTokens.Shadow.y

    // Border
    static let borderWidth = ParallelDesignTokens.Border.width

    // Button Style (accent color based)
    static let buttonGradient = LinearGradient(
        colors: [ParallelDesignTokens.Colors.primaryOrange, ParallelDesignTokens.Colors.primaryOrange.opacity(0.9)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// Reusable background component - parallel.ai style
// Clean solid fills, subtle shadows, 1px borders
struct CardBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var isSelected: Bool
    var cornerRadius: CGFloat = StyleConstants.cornerRadius
    var useAccentGradientWhenSelected: Bool = false

    // MARK: - Computed Colors (adaptive for light/dark mode)

    private var backgroundColor: Color {
        if isSelected && useAccentGradientWhenSelected {
            return ParallelDesignTokens.Colors.selectedBackground(for: colorScheme)
        }
        return ParallelDesignTokens.Colors.cardBackground(for: colorScheme)
    }

    private var borderColor: Color {
        if isSelected {
            return ParallelDesignTokens.Colors.primaryOrange.opacity(0.5)
        }
        return ParallelDesignTokens.Colors.border(for: colorScheme)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: StyleConstants.borderWidth)
            )
            .shadow(
                color: StyleConstants.shadowColor,
                radius: StyleConstants.shadowRadius,
                x: 0,
                y: StyleConstants.shadowY
            )
    }
}

// MARK: - Preview

#if DEBUG
struct CardBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Light mode previews
            Group {
                Text("Default Card")
                    .padding()
                    .background(CardBackground(isSelected: false))

                Text("Selected Card")
                    .padding()
                    .background(CardBackground(isSelected: true))

                Text("Selected with Accent")
                    .padding()
                    .background(CardBackground(isSelected: true, useAccentGradientWhenSelected: true))
            }
            .preferredColorScheme(.light)

            Divider()

            // Dark mode previews
            Group {
                Text("Default Card (Dark)")
                    .padding()
                    .background(CardBackground(isSelected: false))

                Text("Selected Card (Dark)")
                    .padding()
                    .background(CardBackground(isSelected: true))

                Text("Selected with Accent (Dark)")
                    .padding()
                    .background(CardBackground(isSelected: true, useAccentGradientWhenSelected: true))
            }
            .preferredColorScheme(.dark)
        }
        .padding()
    }
}
#endif
