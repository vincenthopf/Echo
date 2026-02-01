//
//  ButtonStyles.swift
//  VoiceInk
//
//  Button styles following parallel.ai design system
//

import SwiftUI

// MARK: - Primary Button Style

/// Filled orange button style matching parallel.ai design
/// Usage: Button("Action") { }.buttonStyle(PrimaryButtonStyle())
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ParallelDesignTokens.Typography.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                    .fill(ParallelDesignTokens.Colors.primaryOrange)
            )
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(ParallelDesignTokens.Animation.easing, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

/// Outlined button style matching parallel.ai design
/// Usage: Button("Cancel") { }.buttonStyle(SecondaryButtonStyle())
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ParallelDesignTokens.Typography.body)
            .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                    .fill(Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                    .stroke(
                        ParallelDesignTokens.Colors.border(for: colorScheme),
                        lineWidth: ParallelDesignTokens.Border.width
                    )
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(ParallelDesignTokens.Animation.easing, value: configuration.isPressed)
    }
}

// MARK: - Keyboard Shortcut Badge

/// View displaying keyboard shortcuts in "S then P" format
/// Usage: KeyboardShortcutBadge(keys: ["S", "P"])
struct KeyboardShortcutBadge: View {
    @Environment(\.colorScheme) private var colorScheme

    let keys: [String]

    var body: some View {
        HStack(spacing: ParallelDesignTokens.Spacing.xs) {
            ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                if index > 0 {
                    Text("then")
                        .font(ParallelDesignTokens.Typography.labelMono)
                        .foregroundColor(ParallelDesignTokens.Colors.grey600)
                }

                KeyBadge(key: key, colorScheme: colorScheme)
            }
        }
    }
}

// MARK: - Key Badge (Private Helper)

/// Individual key badge component
private struct KeyBadge: View {
    let key: String
    let colorScheme: ColorScheme

    var body: some View {
        Text(key)
            .font(ParallelDesignTokens.Typography.labelMono)
            .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))
            .padding(.horizontal, ParallelDesignTokens.Spacing.sm)
            .padding(.vertical, ParallelDesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                    .fill(colorScheme == .dark
                          ? ParallelDesignTokens.Colors.darkCard
                          : ParallelDesignTokens.Colors.grey100)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                    .stroke(
                        colorScheme == .dark
                        ? ParallelDesignTokens.Colors.darkBorder
                        : ParallelDesignTokens.Colors.grey200,
                        lineWidth: ParallelDesignTokens.Border.width
                    )
            )
    }
}

// MARK: - Preview

#Preview("Button Styles") {
    VStack(spacing: 20) {
        // Primary button
        Button("Primary Action") { }
            .buttonStyle(PrimaryButtonStyle())

        // Secondary button
        Button("Secondary Action") { }
            .buttonStyle(SecondaryButtonStyle())

        // Keyboard shortcuts
        KeyboardShortcutBadge(keys: ["S", "P"])
        KeyboardShortcutBadge(keys: ["Cmd", "Shift", "V"])
        KeyboardShortcutBadge(keys: ["R"])
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: 20) {
        Button("Primary Action") { }
            .buttonStyle(PrimaryButtonStyle())

        Button("Secondary Action") { }
            .buttonStyle(SecondaryButtonStyle())

        KeyboardShortcutBadge(keys: ["S", "P"])
    }
    .padding()
    .background(ParallelDesignTokens.Colors.darkBg)
    .preferredColorScheme(.dark)
}
