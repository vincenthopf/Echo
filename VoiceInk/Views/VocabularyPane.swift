import SwiftUI
import SwiftData

/// Main vocabulary pane displaying Smart Corrections and Personal Vocabulary
struct VocabularyPane: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var whisperPrompt = WhisperPrompt()
    @State private var selectedSection: VocabularySection = .corrections

    enum VocabularySection: String, CaseIterable {
        case corrections = "Smart Corrections"
        case vocabulary = "Personal Vocabulary"

        var description: String {
            switch self {
            case .corrections:
                return "Automatically replace specific words or phrases with custom formatted text"
            case .vocabulary:
                return "Add words to help Echo recognize them properly during transcription"
            }
        }

        var icon: String {
            switch self {
            case .corrections:
                return "arrow.2.squarepath"
            case .vocabulary:
                return "character.book.closed.fill"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero section
                heroSection

                // Main content
                mainContent
            }
        }
        .background(Tokens.Colors.background(for: colorScheme))
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: Tokens.Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(Tokens.Colors.orangeSoft(for: colorScheme))
                    .frame(width: 100, height: 100)

                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(Tokens.Colors.orange)
            }

            VStack(spacing: Tokens.Spacing.sm) {
                Text("Vocabulary")
                    .font(Tokens.Typography.displayMedium)
                    .fontWeight(.bold)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Text("Customize how Echo understands and formats your words")
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Tokens.Spacing.xxxl)
        .background(Tokens.Colors.elevated(for: colorScheme))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Tokens.Colors.border(for: colorScheme)),
            alignment: .bottom
        )
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xxl) {
            // Section selector
            sectionSelector

            // Selected section content
            sectionContent
        }
        .padding(.horizontal, 60)
        .padding(.vertical, Tokens.Spacing.xxl)
    }

    // MARK: - Section Selector

    private var sectionSelector: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            Text("Choose Section")
                .font(Tokens.Typography.heading2)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            HStack(spacing: Tokens.Spacing.xl) {
                ForEach(VocabularySection.allCases, id: \.self) { section in
                    VocabularySectionCard(
                        section: section,
                        isSelected: selectedSection == section,
                        colorScheme: colorScheme,
                        action: {
                            withAnimation(Tokens.Animation.easing) {
                                selectedSection = section
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Section Content

    private var sectionContent: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            // Section header
            HStack(spacing: Tokens.Spacing.md) {
                Image(systemName: selectedSection.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Tokens.Colors.orange)

                VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                    Text(selectedSection.rawValue)
                        .font(Tokens.Typography.heading2)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                    Text(selectedSection.description)
                        .font(Tokens.Typography.body)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                }

                Spacer()
            }

            // Content card
            VStack(spacing: 0) {
                switch selectedSection {
                case .corrections:
                    WordReplacementView()
                case .vocabulary:
                    DictionaryView(whisperPrompt: whisperPrompt)
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }
}

// MARK: - Section Card

private struct VocabularySectionCard: View {
    let section: VocabularyPane.VocabularySection
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Tokens.Colors.orange : Tokens.Colors.textSecondary(for: colorScheme))

                VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                    Text(section.rawValue)
                        .font(Tokens.Typography.heading3)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                    Text(section.description)
                        .font(Tokens.Typography.bodySmall)
                        .foregroundStyle(Tokens.Colors.textSecondary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Tokens.Spacing.lg)
            .background(
                isSelected
                    ? Tokens.Colors.orangeSoft(for: colorScheme)
                    : Tokens.Colors.elevated(for: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(
                        isSelected
                            ? Tokens.Colors.orange.opacity(0.5)
                            : Tokens.Colors.border(for: colorScheme),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VocabularyPane()
        .frame(width: 900, height: 700)
}

#Preview("Dark Mode") {
    VocabularyPane()
        .frame(width: 900, height: 700)
        .preferredColorScheme(.dark)
}
