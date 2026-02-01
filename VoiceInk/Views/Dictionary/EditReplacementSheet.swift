import SwiftUI
// Edit existing word replacement entry
struct EditReplacementSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var manager: WordReplacementManager
    let originalKey: String

    @Environment(\.dismiss) private var dismiss

    @State private var originalWord: String
    @State private var replacementWord: String

    // MARK: - Initialiser
    init(manager: WordReplacementManager, originalKey: String) {
        self.manager = manager
        self.originalKey = originalKey
        _originalWord = State(initialValue: originalKey)
        _replacementWord = State(initialValue: manager.replacements[originalKey] ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Rectangle()
                .fill(Tokens.Colors.border(for: colorScheme))
                .frame(height: 1)
            formContent
        }
        .frame(width: 460, height: 560)
    }

    // MARK: - Subviews
    private var header: some View {
        HStack {
            Button("Cancel", role: .cancel) { dismiss() }
                .buttonStyle(.borderless)
                .keyboardShortcut(.escape, modifiers: [])

            Spacer()

            Text("Edit Word Replacement")
                .font(Tokens.Typography.heading3)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            Spacer()

            Button("Save") { saveChanges() }
                .buttonStyle(.borderedProminent)
                .tint(Tokens.Colors.orange)
                .controlSize(.small)
                .disabled(originalWord.isEmpty || replacementWord.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.md)
        .background(Tokens.Colors.elevated(for: colorScheme))
    }

    private var formContent: some View {
        ScrollView {
            VStack(spacing: Tokens.Spacing.lg) {
                descriptionSection
                inputSection
            }
            .padding(.vertical, Tokens.Spacing.lg)
        }
        .background(Tokens.Colors.background(for: colorScheme))
    }

    private var descriptionSection: some View {
        Text("Update the word or phrase that should be automatically replaced.")
            .font(Tokens.Typography.bodySmall)
            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.top, Tokens.Spacing.sm)
    }

    private var inputSection: some View {
        VStack(spacing: Tokens.Spacing.lg) {
            // Original Text Field
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                HStack {
                    Text("Original Text")
                        .font(Tokens.Typography.bodyMedium)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    Text("Required")
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                }
                TextField("Enter word or phrase to replace (use commas for multiple)", text: $originalWord)
                    .textFieldStyle(.plain)
                    .font(Tokens.Typography.body)
                    .padding(Tokens.Spacing.sm)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .padding(.horizontal, Tokens.Spacing.lg)

            // Replacement Text Field
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                HStack {
                    Text("Replacement Text")
                        .font(Tokens.Typography.bodyMedium)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    Text("Required")
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                }
                TextEditor(text: $replacementWord)
                    .font(Tokens.Typography.body)
                    .frame(height: 100)
                    .padding(Tokens.Spacing.sm)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .padding(.horizontal, Tokens.Spacing.lg)
        }
    }

    // MARK: - Actions
    private func saveChanges() {
        let newOriginal = originalWord.trimmingCharacters(in: .whitespacesAndNewlines)
        let newReplacement = replacementWord
        // Ensure at least one non-empty token
        let tokens = newOriginal
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty, !newReplacement.isEmpty else { return }

        manager.updateReplacement(oldOriginal: originalKey, newOriginal: newOriginal, newReplacement: newReplacement)
        dismiss()
    }
}

// MARK: – Preview
#if DEBUG
struct EditReplacementSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditReplacementSheet(manager: WordReplacementManager(), originalKey: "hello")
    }
}
#endif