//
//  SectionHeader.swift
//  VoiceInk
//
//  Section header component with left vertical accent bar
//  following parallel.ai design style
//

import SwiftUI

/// A section header view with a left vertical accent bar in orange,
/// following the parallel.ai design language.
///
/// Usage:
/// ```swift
/// ParallelSectionHeader(title: "Settings")
/// ParallelSectionHeader(title: "Audio", subtitle: "Configure input devices")
/// ParallelSectionHeader(title: "Recording", subtitle: "Active session", icon: "waveform")
/// ```
struct ParallelSectionHeader: View {
    // MARK: - Properties

    let title: String
    let subtitle: String?
    let icon: String?

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Initialization

    init(title: String, subtitle: String? = nil, icon: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: Tokens.Spacing.md) {
            // Left vertical accent bar
            accentBar

            // Title and subtitle stack
            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                titleRow

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Tokens.Typography.bodySmall)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                }
            }

            Spacer()
        }
    }

    // MARK: - Subviews

    /// The orange vertical accent bar on the left
    private var accentBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Tokens.Colors.orange)
            .frame(width: 4)
            .frame(height: accentBarHeight)
    }

    /// The title row with optional icon
    private var titleRow: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(Tokens.Typography.sectionTitle)
                    .foregroundColor(Tokens.Colors.orange)
            }

            Text(title)
                .font(Tokens.Typography.sectionTitle)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
        }
    }

    /// Calculates the accent bar height based on content
    private var accentBarHeight: CGFloat {
        // Base height for title only
        var height: CGFloat = 20

        // Add height if subtitle is present
        if subtitle != nil {
            height += 16
        }

        return height
    }
}

// MARK: - Typealias for backwards compatibility
/// Typealias to allow using SectionHeader as a shorthand
typealias SectionHeader = ParallelSectionHeader

// MARK: - Preview

#Preview("Parallel Section Header Variants") {
    VStack(alignment: .leading, spacing: 24) {
        ParallelSectionHeader(title: "Basic Header")

        ParallelSectionHeader(
            title: "With Subtitle",
            subtitle: "Additional context information"
        )

        ParallelSectionHeader(
            title: "With Icon",
            icon: "gearshape"
        )

        ParallelSectionHeader(
            title: "Full Example",
            subtitle: "All properties configured",
            icon: "waveform"
        )
    }
    .padding()
    .frame(width: 400)
}

#Preview("Parallel Section Header Dark Mode") {
    VStack(alignment: .leading, spacing: 24) {
        ParallelSectionHeader(
            title: "Dark Mode Header",
            subtitle: "Supports dark mode automatically",
            icon: "moon.fill"
        )
    }
    .padding()
    .frame(width: 400)
    .preferredColorScheme(.dark)
}
