import SwiftUI

/// A reusable info tip component that displays helpful information in a popover
struct InfoTip: View {
    // Content configuration
    var title: String
    var message: String
    var learnMoreLink: URL?
    var learnMoreText: String = "Learn More"

    // Appearance customization
    var iconName: String = "info.circle.fill"
    var iconSize: Image.Scale = .medium
    var iconColor: Color? = nil
    var width: CGFloat = 300

    // Environment
    @Environment(\.colorScheme) private var colorScheme

    // State
    @State private var isShowingTip: Bool = false

    private var resolvedIconColor: Color {
        iconColor ?? ParallelDesignTokens.Colors.secondaryText(for: colorScheme)
    }

    var body: some View {
        Image(systemName: iconName)
            .imageScale(iconSize)
            .foregroundColor(resolvedIconColor)
            .fontWeight(.semibold)
            .padding(5)
            .contentShape(Rectangle())
            .popover(isPresented: $isShowingTip) {
                VStack(alignment: .leading, spacing: ParallelDesignTokens.Spacing.md) {
                    Text(title)
                        .font(ParallelDesignTokens.Typography.heading3)
                        .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))

                    Text(message)
                        .font(ParallelDesignTokens.Typography.body)
                        .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: width, alignment: .leading)

                    if let url = learnMoreLink {
                        Link(destination: url) {
                            HStack(spacing: ParallelDesignTokens.Spacing.xs) {
                                Text(learnMoreText)
                                    .font(ParallelDesignTokens.Typography.caption)
                                    .fontWeight(.medium)
                                Image(systemName: "arrow.up.forward")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                                    .fill(ParallelDesignTokens.Colors.primaryOrange)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, ParallelDesignTokens.Spacing.sm)
                    }
                }
                .padding(ParallelDesignTokens.Spacing.lg)
                .background(ParallelDesignTokens.Colors.cardBackground(for: colorScheme))
            }
            .onTapGesture {
                isShowingTip.toggle()
            }
    }
}

// MARK: - Convenience initializers

extension InfoTip {
    /// Creates an InfoTip with just title and message
    init(title: String, message: String) {
        self.title = title
        self.message = message
        self.learnMoreLink = nil
    }
    
    /// Creates an InfoTip with a learn more link
    init(title: String, message: String, learnMoreURL: String) {
        self.title = title
        self.message = message
        self.learnMoreLink = URL(string: learnMoreURL)
    }
}
