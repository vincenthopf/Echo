import SwiftUI

/// A simple grid cell for displaying a metric with label and value.
/// Designed to sit inside a grid row with borders - no card styling.
struct MetricCell: View {
    let label: String
    let value: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: VoiceInkTokens.Spacing.sm) {
            // Uppercase label with letter-spacing
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
                .foregroundColor(VoiceInkTokens.Colors.textTertiary(for: colorScheme))

            // Large display value
            Text(value)
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(VoiceInkTokens.Colors.textPrimary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, VoiceInkTokens.Spacing.xl)
        .padding(.vertical, 20)
        .background(VoiceInkTokens.Colors.elevated(for: colorScheme))
    }
}

/// Legacy MetricCard - redirects to MetricCell for backward compatibility
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String // Ignored in new design

    var body: some View {
        MetricCell(label: title, value: value)
    }
}
