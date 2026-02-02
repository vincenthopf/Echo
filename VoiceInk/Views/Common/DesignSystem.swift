//
//  DesignSystem.swift
//  VoiceInk
//
//  Design tokens for grid-based UI inspired by parallel.ai
//  Uses native macOS system fonts and original VoiceInk orange
//

import SwiftUI

/// Design tokens for VoiceInk UI - grid-based, minimal, native feel
/// Usage: VoiceInkTokens.Colors.orange
struct VoiceInkTokens {

    // MARK: - Colors

    struct Colors {
        // MARK: Brand
        /// Original VoiceInk orange - #CC785C
        static let orange = Color(red: 0.800, green: 0.471, blue: 0.361)

        // MARK: Light Mode
        /// Warm off-white background - #FAFAF8
        static let bgLight = Color(red: 0.980, green: 0.980, blue: 0.973)
        /// Elevated surface (white)
        static let elevatedLight = Color.white
        /// Standard border - #E8E6E1
        static let borderLight = Color(red: 0.910, green: 0.902, blue: 0.882)
        /// Strong border - #D4D2CD
        static let borderStrongLight = Color(red: 0.831, green: 0.824, blue: 0.804)
        /// Primary text - #1A1A18
        static let textPrimaryLight = Color(red: 0.102, green: 0.102, blue: 0.094)
        /// Secondary text - #7A7A72
        static let textSecondaryLight = Color(red: 0.478, green: 0.478, blue: 0.447)
        /// Tertiary text - #A8A8A0
        static let textTertiaryLight = Color(red: 0.659, green: 0.659, blue: 0.627)

        // MARK: Dark Mode
        /// Dark background - #141413
        static let bgDark = Color(red: 0.078, green: 0.078, blue: 0.075)
        /// Dark elevated surface - #1E1E1C
        static let elevatedDark = Color(red: 0.118, green: 0.118, blue: 0.110)
        /// Dark border - #2A2A28
        static let borderDark = Color(red: 0.165, green: 0.165, blue: 0.157)
        /// Dark strong border - #3A3A38
        static let borderStrongDark = Color(red: 0.227, green: 0.227, blue: 0.220)
        /// Dark primary text - #F5F5F3
        static let textPrimaryDark = Color(red: 0.961, green: 0.961, blue: 0.953)
        /// Dark secondary text - #9A9A92
        static let textSecondaryDark = Color(red: 0.604, green: 0.604, blue: 0.573)
        /// Dark tertiary text - #6A6A62
        static let textTertiaryDark = Color(red: 0.416, green: 0.416, blue: 0.384)

        // MARK: Semantic
        /// Success green - #4A9D5B
        static let success = Color(red: 0.290, green: 0.616, blue: 0.357)
        /// Error red - #D64545
        static let error = Color(red: 0.839, green: 0.271, blue: 0.271)

        // MARK: Legacy Aliases (for backward compatibility)
        static let primaryOrange = orange
        static let lightOrange = orange.opacity(0.15)
        static let offWhite = bgLight
        static let grey100 = bgLight
        static let grey200 = borderLight
        static let grey600 = textSecondaryLight
        static let grey800 = textPrimaryLight
        static let accentBlue = Color(red: 0.561, green: 0.714, blue: 0.8)
        static let darkBg = bgDark
        static let darkCard = elevatedDark
        static let darkBorder = borderDark
        static let darkSecondaryText = textSecondaryDark

        // MARK: Adaptive Colors

        static func background(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? bgDark : bgLight
        }

        static func elevated(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? elevatedDark : elevatedLight
        }

        static func border(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? borderDark : borderLight
        }

        static func borderStrong(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? borderStrongDark : borderStrongLight
        }

        static func textPrimary(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? textPrimaryDark : textPrimaryLight
        }

        static func textSecondary(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? textSecondaryDark : textSecondaryLight
        }

        static func textTertiary(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? textTertiaryDark : textTertiaryLight
        }

        /// Soft orange tint for hover/selection
        static func orangeSoft(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? orange.opacity(0.12) : orange.opacity(0.08)
        }

        /// Medium orange for badges/highlights
        static func orangeMedium(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? orange.opacity(0.20) : orange.opacity(0.15)
        }

        /// Success soft background
        static func successSoft(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? success.opacity(0.15) : success.opacity(0.10)
        }

        // MARK: Legacy Function Aliases
        static func cardBackground(for colorScheme: ColorScheme) -> Color {
            elevated(for: colorScheme)
        }

        static func primaryText(for colorScheme: ColorScheme) -> Color {
            textPrimary(for: colorScheme)
        }

        static func secondaryText(for colorScheme: ColorScheme) -> Color {
            textSecondary(for: colorScheme)
        }

        static func selectedBackground(for colorScheme: ColorScheme) -> Color {
            orangeSoft(for: colorScheme)
        }

        static func hoverBackground(for colorScheme: ColorScheme) -> Color {
            orangeSoft(for: colorScheme)
        }
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Radius

    struct Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 6
        static let lg: CGFloat = 8
        static let xl: CGFloat = 12

        // Legacy aliases
        static let small: CGFloat = sm
        static let medium: CGFloat = md
        static let large: CGFloat = lg
    }

    // MARK: - Typography

    struct Typography {
        // Display sizes
        static let displayLarge = Font.system(size: 48, weight: .regular)
        static let displayMedium = Font.system(size: 28, weight: .regular)

        // Headings
        static let heading1 = Font.system(size: 24, weight: .semibold)
        static let heading2 = Font.system(size: 18, weight: .semibold)
        static let heading3 = Font.system(size: 16, weight: .semibold)

        // Body
        static let bodyLarge = Font.system(size: 15, weight: .regular)
        static let body = Font.system(size: 14, weight: .regular)
        static let bodyMedium = Font.system(size: 13, weight: .medium)
        static let bodySmall = Font.system(size: 13, weight: .regular)

        // Labels
        static let label = Font.system(size: 12, weight: .medium)
        static let labelMono = Font.system(size: 12, weight: .medium, design: .monospaced)
        static let labelSmall = Font.system(size: 10, weight: .medium)

        // Other
        static let caption = Font.system(size: 11, weight: .regular)
        static let sectionTitle = Font.system(size: 16, weight: .medium)
        static let pageTitle = Font.system(size: 28, weight: .semibold)

    }
}

// MARK: - Convenience Typealiases

/// Shorthand for VoiceInkTokens
typealias Tokens = VoiceInkTokens

// Keep backward compatibility with existing code during migration
typealias ParallelDesignTokens = VoiceInkTokens

// MARK: - Additional Types for Backward Compatibility

extension VoiceInkTokens {
    struct Border {
        static let width: CGFloat = 1
    }

    struct Shadow {
        static let color = Color.clear
        static let radius: CGFloat = 0
        static let y: CGFloat = 0
    }

    struct Animation {
        static let duration: Double = 0.15
        static let easing = SwiftUI.Animation.easeOut(duration: duration)
    }
}

// MARK: - Grid Container View Modifier

/// Applies grid container styling (border, rounded corners, no shadow)
struct GridContainerModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(VoiceInkTokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg)
                    .stroke(VoiceInkTokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
    }
}

extension View {
    /// Apply grid container styling (border, no shadow)
    func gridContainer() -> some View {
        self.modifier(GridContainerModifier())
    }

    /// Legacy card modifier - now just applies grid container
    func parallelCard(isSelected: Bool = false) -> some View {
        self.modifier(GridContainerModifier())
    }

    func parallelCard(isSelected: Bool = false, colorScheme: ColorScheme) -> some View {
        self
            .background(VoiceInkTokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg)
                    .stroke(VoiceInkTokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
    }
}

// Note: SectionHeader is defined in SectionHeader.swift
