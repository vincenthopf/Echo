import SwiftUI
import SwiftData

enum ContentTab: String, CaseIterable {
    case original = "Original"
    case enhanced = "Enhanced"
    case aiRequest = "AI Request"
}

struct TranscriptionCard: View {
    let transcription: Transcription
    let isExpanded: Bool
    let isSelected: Bool
    let onDelete: () -> Void
    let onToggleSelection: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: ContentTab = .original

    private var availableTabs: [ContentTab] {
        var tabs = [ContentTab.original]
        if transcription.enhancedText != nil {
            tabs.append(.enhanced)
        }
        if transcription.aiRequestSystemMessage != nil || transcription.aiRequestUserMessage != nil {
            tabs.append(.aiRequest)
        }
        return tabs
    }

    private var hasAudioFile: Bool {
        if let urlString = transcription.audioFileURL,
           let url = URL(string: urlString),
           FileManager.default.fileExists(atPath: url.path) {
            return true
        }
        return false
    }

    private var copyTextForCurrentTab: String {
        switch selectedTab {
        case .original:
            return transcription.text
        case .enhanced:
            return transcription.enhancedText ?? transcription.text
        case .aiRequest:
            var result = ""
            if let systemMsg = transcription.aiRequestSystemMessage, !systemMsg.isEmpty {
                result += systemMsg
            }
            if let userMsg = transcription.aiRequestUserMessage, !userMsg.isEmpty {
                if !result.isEmpty {
                    result += "\n\n"
                }
                result += userMsg
            }
            return result.isEmpty ? transcription.text : result
        }
    }

    private var originalContentView: some View {
        Text(transcription.text)
            .font(Tokens.Typography.bodyLarge)
            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
            .lineSpacing(2)
            .textSelection(.enabled)
    }

    private func enhancedContentView(_ enhancedText: String) -> some View {
        Text(enhancedText)
            .font(Tokens.Typography.bodyLarge)
            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
            .lineSpacing(2)
            .textSelection(.enabled)
    }

    private var aiRequestContentView: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {

            if let systemMsg = transcription.aiRequestSystemMessage, !systemMsg.isEmpty {
                VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                    Text("System Prompt")
                        .font(Tokens.Typography.bodySmall.weight(.semibold))
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    Text(systemMsg)
                        .font(Tokens.Typography.labelMono)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .lineSpacing(2)
                        .textSelection(.enabled)
                }
            }

            if let userMsg = transcription.aiRequestUserMessage, !userMsg.isEmpty {
                VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                    Text("User Message")
                        .font(Tokens.Typography.bodySmall.weight(.semibold))
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    Text(userMsg)
                        .font(Tokens.Typography.labelMono)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .lineSpacing(2)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(Tokens.Typography.bodySmall.weight(isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : Tokens.Colors.textSecondary(for: colorScheme))
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                            .fill(isSelected ? Tokens.Colors.orange : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                            .stroke(
                                isSelected ? Color.clear : Tokens.Colors.border(for: colorScheme),
                                lineWidth: 1
                            )
                    )
                    .contentShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
            }
            .buttonStyle(.plain)
            .animation(Tokens.Animation.easing, value: isSelected)
        }
    }

    var body: some View {
        HStack(spacing: Tokens.Spacing.md) {
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggleSelection() }
            ))
            .toggleStyle(CircularCheckboxStyle())
            .labelsHidden()

            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                HStack {
                    Text(transcription.timestamp, format: .dateTime.month(.abbreviated).day().year().hour().minute())
                        .font(Tokens.Typography.body.weight(.medium))
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    Spacer()

                    Text(formatTiming(transcription.duration))
                        .font(Tokens.Typography.body.weight(.medium))
                        .padding(.horizontal, Tokens.Spacing.sm)
                        .padding(.vertical, Tokens.Spacing.xs)
                        .background(Tokens.Colors.orangeMedium(for: colorScheme))
                        .foregroundColor(Tokens.Colors.orange)
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
                }

                if isExpanded {
                    HStack(spacing: Tokens.Spacing.xs) {
                        ForEach(availableTabs, id: \.self) { tab in
                            TabButton(
                                title: tab.rawValue,
                                isSelected: selectedTab == tab,
                                action: { selectedTab = tab }
                            )
                        }

                        Spacer()

                        AnimatedCopyButton(textToCopy: copyTextForCurrentTab)
                    }
                    .padding(.vertical, Tokens.Spacing.sm)
                    .padding(.horizontal, Tokens.Spacing.xs)

                    ScrollView {
                        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                            switch selectedTab {
                            case .original:
                                originalContentView
                            case .enhanced:
                                if let enhancedText = transcription.enhancedText {
                                    enhancedContentView(enhancedText)
                                }
                            case .aiRequest:
                                aiRequestContentView
                            }
                        }
                        .padding(.vertical, Tokens.Spacing.sm)
                    }
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))

                    if hasAudioFile, let urlString = transcription.audioFileURL,
                       let url = URL(string: urlString) {
                        Rectangle()
                            .fill(Tokens.Colors.border(for: colorScheme))
                            .frame(height: 1)
                            .padding(.vertical, Tokens.Spacing.sm)
                        AudioPlayerView(url: url)
                    }

                    if hasMetadata {
                        Rectangle()
                            .fill(Tokens.Colors.border(for: colorScheme))
                            .frame(height: 1)
                            .padding(.vertical, Tokens.Spacing.sm)

                        VStack(alignment: .leading, spacing: Tokens.Spacing.sm + 2) {
                            if let powerModeValue = powerModeDisplay(
                                name: transcription.powerModeName,
                                emoji: transcription.powerModeEmoji
                            ) {
                                metadataRow(
                                    icon: "bolt.fill",
                                    label: "Configuration",
                                    value: powerModeValue
                                )
                            }
                            metadataRow(icon: "hourglass", label: "Audio Duration", value: formatTiming(transcription.duration))
                            if let modelName = transcription.transcriptionModelName {
                                metadataRow(icon: "cpu.fill", label: "Transcription Model", value: modelName)
                            }
                            if let aiModel = transcription.aiEnhancementModelName {
                                metadataRow(icon: "sparkles", label: "Enhancement Model", value: aiModel)
                            }
                            if let promptName = transcription.promptName {
                                metadataRow(icon: "text.bubble.fill", label: "Prompt Used", value: promptName)
                            }
                            if let duration = transcription.transcriptionDuration {
                                metadataRow(icon: "clock.fill", label: "Transcription Time", value: formatTiming(duration))
                            }
                            if let duration = transcription.enhancementDuration {
                                metadataRow(icon: "clock.fill", label: "Enhancement Time", value: formatTiming(duration))
                            }
                        }
                    }
                } else {
                    Text(transcription.text)
                        .font(Tokens.Typography.bodyLarge)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .lineLimit(2)
                        .lineSpacing(2)
                }
            }
        }
        .padding(Tokens.Spacing.lg)
        .background(Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
        .contextMenu {
            if let enhancedText = transcription.enhancedText {
                Button {
                    let _ = ClipboardManager.copyToClipboard(enhancedText)
                } label: {
                    Label("Copy Enhanced", systemImage: "doc.on.doc")
                }
            }

            Button {
                let _ = ClipboardManager.copyToClipboard(transcription.text)
            } label: {
                Label("Copy Original", systemImage: "doc.on.doc")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .onChange(of: isExpanded) { oldValue, newValue in
            if newValue {
                selectedTab = .original
            }
        }
    }

    private var hasMetadata: Bool {
        transcription.powerModeName != nil ||
        transcription.powerModeEmoji != nil ||
        transcription.transcriptionModelName != nil ||
        transcription.aiEnhancementModelName != nil ||
        transcription.promptName != nil ||
        transcription.transcriptionDuration != nil ||
        transcription.enhancementDuration != nil
    }
    
    private func formatTiming(_ duration: TimeInterval) -> String {
        if duration < 1 {
            return String(format: "%.0fms", duration * 1000)
        }
        if duration < 60 {
            return String(format: "%.1fs", duration)
        }
        let minutes = Int(duration) / 60
        let seconds = duration.truncatingRemainder(dividingBy: 60)
        return String(format: "%dm %.0fs", minutes, seconds)
    }
    
    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Tokens.Spacing.md) {
            Image(systemName: icon)
                .font(Tokens.Typography.bodySmall.weight(.medium))
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .frame(width: 20, alignment: .center)

            Text(label)
                .font(Tokens.Typography.bodySmall.weight(.medium))
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
            Spacer()
            Text(value)
                .font(Tokens.Typography.bodySmall.weight(.semibold))
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
        }
    }

    private func powerModeDisplay(name: String?, emoji: String?) -> String? {
        guard name != nil || emoji != nil else { return nil }

        switch (emoji?.trimmingCharacters(in: .whitespacesAndNewlines), name?.trimmingCharacters(in: .whitespacesAndNewlines)) {
        case let (.some(emojiValue), .some(nameValue)) where !emojiValue.isEmpty && !nameValue.isEmpty:
            return "\(emojiValue) \(nameValue)"
        case let (.some(emojiValue), _) where !emojiValue.isEmpty:
            return emojiValue
        case let (_, .some(nameValue)) where !nameValue.isEmpty:
            return nameValue
        default:
            return nil
        }
    }
}
