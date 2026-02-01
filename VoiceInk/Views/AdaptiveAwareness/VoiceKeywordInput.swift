import SwiftUI

/// Tag-style input for voice trigger keywords
/// Updated to fit within the trigger grid column design
struct VoiceKeywordInput: View {
    @Binding var triggerWords: [String]

    @State private var newKeyword = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
            // Existing keywords
            if !triggerWords.isEmpty {
                VStack(spacing: Tokens.Spacing.sm) {
                    ForEach(triggerWords, id: \.self) { word in
                        KeywordTagView(word: word) {
                            triggerWords.removeAll { $0 == word }
                        }
                    }
                }
            }

            // Input field
            HStack(spacing: Tokens.Spacing.sm) {
                TextField("Add keyword", text: $newKeyword)
                    .textFieldStyle(.plain)
                    .font(Tokens.Typography.bodySmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, Tokens.Spacing.xs)
                    .background(Tokens.Colors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addKeyword()
                    }

                Button(action: addKeyword) {
                    Text("Add")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(newKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            // Hint text
            Text("Say keyword during recording")
                .font(.system(size: 10))
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
        }
    }

    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let lowerCased = trimmed.lowercased()
        guard !triggerWords.contains(where: { $0.lowercased() == lowerCased }) else {
            newKeyword = ""
            return
        }

        triggerWords.append(trimmed)
        newKeyword = ""
    }
}

/// Individual keyword tag with delete button
struct KeywordTagView: View {
    let word: String
    let onDelete: () -> Void

    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 10))
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))

            Text("\"\(word)\"")
                .font(Tokens.Typography.bodySmall)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                .lineLimit(1)

            Spacer(minLength: 4)

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Tokens.Colors.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Tokens.Spacing.sm)
        .padding(.vertical, Tokens.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .fill(Tokens.Colors.background(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
