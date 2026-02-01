import SwiftUI
import Charts

struct MetricsContent: View {
    let transcriptions: [Transcription]

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if transcriptions.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                VStack(spacing: VoiceInkTokens.Spacing.xxxl) {
                    TimeEfficiencyView(totalRecordedTime: totalRecordedTime, estimatedTypingTime: estimatedTypingTime)

                    // Statistics Section
                    VStack(alignment: .leading, spacing: VoiceInkTokens.Spacing.lg) {
                        SectionHeader(title: "Statistics")
                        metricsGrid
                    }

                    // Trend Chart Section
                    VStack(alignment: .leading, spacing: VoiceInkTokens.Spacing.lg) {
                        SectionHeader(title: "30-Day Echo Trend")
                        voiceInkTrendChart
                    }
                }
                .padding(VoiceInkTokens.Spacing.xl)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: VoiceInkTokens.Spacing.xl) {
            Image(systemName: "waveform")
                .font(.system(size: 50))
                .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
            Text("No Transcriptions Yet")
                .font(VoiceInkTokens.Typography.sectionTitle)
                .foregroundColor(VoiceInkTokens.Colors.textPrimary(for: colorScheme))
            Text("Start recording to see your metrics")
                .font(VoiceInkTokens.Typography.body)
                .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VoiceInkTokens.Colors.background(for: colorScheme))
    }

    // MARK: - Metrics Grid with Borders

    private var metricsGrid: some View {
        // 4-column grid with 1px borders
        HStack(spacing: 0) {
            MetricCell(label: "Words Dictated", value: "\(totalWordsTranscribed)")

            Divider()
                .frame(width: 1)
                .background(VoiceInkTokens.Colors.border(for: colorScheme))

            MetricCell(label: "Echo Sessions", value: "\(transcriptions.count)")

            Divider()
                .frame(width: 1)
                .background(VoiceInkTokens.Colors.border(for: colorScheme))

            MetricCell(label: "Avg WPM", value: String(format: "%.0f", averageWordsPerMinute))

            Divider()
                .frame(width: 1)
                .background(VoiceInkTokens.Colors.border(for: colorScheme))

            MetricCell(label: "Words/Session", value: String(format: "%.1f", averageWordsPerSession))
        }
        .clipShape(RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg)
                .stroke(VoiceInkTokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }

    // MARK: - Trend Chart

    private var voiceInkTrendChart: some View {
        VStack(alignment: .leading, spacing: VoiceInkTokens.Spacing.lg) {
            // Chart header
            HStack {
                Text("DAILY SESSIONS")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(VoiceInkTokens.Colors.textTertiary(for: colorScheme))

                Spacer()

                // Legend
                HStack(spacing: VoiceInkTokens.Spacing.sm) {
                    Circle()
                        .fill(VoiceInkTokens.Colors.orange)
                        .frame(width: 8, height: 8)
                    Text("Sessions")
                        .font(.system(size: 11))
                        .foregroundColor(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
                }
            }

            Chart {
                ForEach(dailyTranscriptionCounts, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Sessions", item.count)
                    )
                    .foregroundStyle(VoiceInkTokens.Colors.orange)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Sessions", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                VoiceInkTokens.Colors.orange.opacity(0.3),
                                VoiceInkTokens.Colors.orange.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(VoiceInkTokens.Colors.border(for: colorScheme))
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                        .foregroundStyle(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(VoiceInkTokens.Colors.border(for: colorScheme))
                    AxisTick()
                    AxisValueLabel()
                        .foregroundStyle(VoiceInkTokens.Colors.textSecondary(for: colorScheme))
                }
            }
            .frame(height: 200)
        }
        .padding(VoiceInkTokens.Spacing.xl)
        .background(VoiceInkTokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: VoiceInkTokens.Radius.lg)
                .stroke(VoiceInkTokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }

    // MARK: - Computed Properties

    private var totalWordsTranscribed: Int {
        transcriptions.reduce(0) { $0 + $1.text.split(separator: " ").count }
    }

    private var totalRecordedTime: TimeInterval {
        transcriptions.reduce(0) { $0 + $1.duration }
    }

    private var estimatedTypingTime: TimeInterval {
        let averageTypingSpeed: Double = 35 // words per minute
        let totalWords = Double(totalWordsTranscribed)
        let estimatedTypingTimeInMinutes = totalWords / averageTypingSpeed
        return estimatedTypingTimeInMinutes * 60
    }

    private var dailyTranscriptionCounts: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()

        let dailyData = (0..<30).compactMap { dayOffset -> (date: Date, count: Int)? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { return nil }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let count = transcriptions.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.count
            return (date: startOfDay, count: count)
        }

        return dailyData.reversed()
    }

    private var averageWordsPerMinute: Double {
        guard totalRecordedTime > 0 else { return 0 }
        return Double(totalWordsTranscribed) / (totalRecordedTime / 60.0)
    }

    private var averageWordsPerSession: Double {
        guard !transcriptions.isEmpty else { return 0 }
        return Double(totalWordsTranscribed) / Double(transcriptions.count)
    }
}
