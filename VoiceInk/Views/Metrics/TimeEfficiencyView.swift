import SwiftUI

struct TimeEfficiencyView: View {
    // MARK: - Properties

    private let totalRecordedTime: TimeInterval
    private let estimatedTypingTime: TimeInterval

    @Environment(\.colorScheme) private var colorScheme

    // Computed properties for efficiency metrics
    private var timeSaved: TimeInterval {
        estimatedTypingTime - totalRecordedTime
    }

    private var efficiencyMultiplier: Double {
        guard totalRecordedTime > 0 else { return 0 }
        let multiplier = estimatedTypingTime / totalRecordedTime
        return round(multiplier * 10) / 10  // Round to 1 decimal place
    }

    // MARK: - Initializer

    init(totalRecordedTime: TimeInterval, estimatedTypingTime: TimeInterval) {
        self.totalRecordedTime = totalRecordedTime
        self.estimatedTypingTime = estimatedTypingTime
    }

    // MARK: - Body

    var body: some View {
        // 2-column hero grid with 1px border between cells
        HStack(spacing: 0) {
            // Left cell: Efficiency multiplier with orange gradient
            efficiencyCell

            // Vertical divider
            Rectangle()
                .fill(VoiceInkTokens.Colors.border(for: colorScheme))
                .frame(width: 1)

            // Right cell: Time saved
            timeSavedCell
        }
        .clipShape(RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.xl)
                .stroke(VoiceInkTokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }

    // MARK: - Hero Cells

    private var efficiencyCell: some View {
        VStack(alignment: .leading, spacing: VoiceInkTokens.Spacing.sm) {
            // Label
            Text("EFFICIENCY MULTIPLIER")
                .font(.system(size: 10, weight: .medium))
                .tracking(1)
                .foregroundColor(VoiceInkTokens.Colors.textTertiary(for: colorScheme))

            // Value
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", efficiencyMultiplier))
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(VoiceInkTokens.Colors.orange)

                Text("x faster")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
            }

            // Meta info
            Text("compared to typing at 35 WPM")
                .font(.system(size: 13))
                .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
                .padding(.top, VoiceInkTokens.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VoiceInkTokens.Spacing.xxl)
        .background(
            // Soft orange gradient highlight
            LinearGradient(
                colors: [
                    VoiceInkTokens.Colors.orangeSoft(for: colorScheme),
                    VoiceInkTokens.Colors.elevated(for: colorScheme)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var timeSavedCell: some View {
        VStack(alignment: .leading, spacing: VoiceInkTokens.Spacing.sm) {
            // Label
            Text("TIME SAVED")
                .font(.system(size: 10, weight: .medium))
                .tracking(1)
                .foregroundColor(VoiceInkTokens.Colors.textTertiary(for: colorScheme))

            // Value - formatted as hours and minutes
            timeSavedValue

            // Meta info
            Text("this month")
                .font(.system(size: 13))
                .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
                .padding(.top, VoiceInkTokens.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VoiceInkTokens.Spacing.xxl)
        .background(VoiceInkTokens.Colors.elevated(for: colorScheme))
    }

    @ViewBuilder
    private var timeSavedValue: some View {
        let (hours, minutes) = formatTimeSaved(timeSaved)

        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if hours > 0 {
                Text("\(hours)")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(VoiceInkTokens.Colors.textPrimary(for: colorScheme))
                Text("h")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
            }

            Text("\(minutes)")
                .font(.system(size: 48, weight: .regular))
                .foregroundColor(VoiceInkTokens.Colors.textPrimary(for: colorScheme))
            Text("m")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
        }
    }

    // MARK: - Utility Methods

    private func formatTimeSaved(_ duration: TimeInterval) -> (hours: Int, minutes: Int) {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return (hours, minutes)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}
