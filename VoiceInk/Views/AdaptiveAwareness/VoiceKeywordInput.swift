import SwiftUI

/// Tag-style input for voice trigger keywords
struct VoiceKeywordInput: View {
    @Binding var triggerWords: [String]

    @State private var newKeyword = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !triggerWords.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120, maximum: 200))], spacing: 8) {
                    ForEach(triggerWords, id: \.self) { word in
                        KeywordTagView(word: word) {
                            triggerWords.removeAll { $0 == word }
                        }
                    }
                }
                .padding(.bottom, 4)
            } else {
                Text("No voice keywords added")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Input field
            HStack {
                TextField("Add keyword", text: $newKeyword)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addKeyword()
                    }

                Button("Add") {
                    addKeyword()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(newKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Text("Tip: Say the keyword during recording to activate this profile")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Check for duplicates (case insensitive)
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

    var body: some View {
        HStack(spacing: 6) {
            Text(word)
                .font(.system(size: 13))
                .lineLimit(1)
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isHovered ? .red : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .help("Remove keyword")
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        }
    }
}
