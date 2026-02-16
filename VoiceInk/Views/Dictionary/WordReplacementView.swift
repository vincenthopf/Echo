import SwiftUI
import SwiftData

extension String: @retroactive Identifiable {
    public var id: String { self }
}

enum SortMode: String {
    case originalAsc = "originalAsc"
    case originalDesc = "originalDesc"
    case replacementAsc = "replacementAsc"
    case replacementDesc = "replacementDesc"
}

enum SortColumn {
    case original
    case replacement
}

// Legacy WordReplacementManager kept for EditReplacementSheet compatibility
// This will be deprecated once SwiftData migration is complete
class WordReplacementManager: ObservableObject {
    @Published var replacements: [String: String] {
        didSet {
            UserDefaults.standard.set(replacements, forKey: "wordReplacements")
        }
    }

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "IsWordReplacementEnabled")
        }
    }

    init() {
        self.replacements = UserDefaults.standard.dictionary(forKey: "wordReplacements") as? [String: String] ?? [:]
        // Default to true if not previously set
        if UserDefaults.standard.object(forKey: "IsWordReplacementEnabled") == nil {
            self.isEnabled = true
        } else {
            self.isEnabled = UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled")
        }
    }

    func addReplacement(original: String, replacement: String) {
        // Preserve comma-separated originals as a single entry
        let trimmed = original.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        replacements[trimmed] = replacement
    }

    func removeReplacement(original: String) {
        replacements.removeValue(forKey: original)
    }

    func updateReplacement(oldOriginal: String, newOriginal: String, newReplacement: String) {
        // Replace old key with the new comma-preserved key
        replacements.removeValue(forKey: oldOriginal)
        let trimmed = newOriginal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        replacements[trimmed] = newReplacement
    }
}

struct WordReplacementView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var wordReplacements: [WordReplacementModel]
    @AppStorage("IsWordReplacementEnabled") private var isEnabled = true
    @State private var showAddReplacementModal = false
    @State private var showAlert = false
    @State private var editingReplacement: WordReplacementModel? = nil

    @State private var alertMessage = ""
    @State private var sortMode: SortMode = .originalAsc

    init() {
        if let savedSort = UserDefaults.standard.string(forKey: "wordReplacementSortMode"),
           let mode = SortMode(rawValue: savedSort) {
            _sortMode = State(initialValue: mode)
        }
    }

    private var sortedReplacements: [WordReplacementModel] {
        switch sortMode {
        case .originalAsc:
            return wordReplacements.sorted { $0.originalText.localizedCaseInsensitiveCompare($1.originalText) == .orderedAscending }
        case .originalDesc:
            return wordReplacements.sorted { $0.originalText.localizedCaseInsensitiveCompare($1.originalText) == .orderedDescending }
        case .replacementAsc:
            return wordReplacements.sorted { $0.replacementText.localizedCaseInsensitiveCompare($1.replacementText) == .orderedAscending }
        case .replacementDesc:
            return wordReplacements.sorted { $0.replacementText.localizedCaseInsensitiveCompare($1.replacementText) == .orderedDescending }
        }
    }

    private func toggleSort(for column: SortColumn) {
        switch column {
        case .original:
            sortMode = (sortMode == .originalAsc) ? .originalDesc : .originalAsc
        case .replacement:
            sortMode = (sortMode == .replacementAsc) ? .replacementDesc : .replacementAsc
        }
        UserDefaults.standard.set(sortMode.rawValue, forKey: "wordReplacementSortMode")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            // Info Section with Toggle
            HStack(spacing: Tokens.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Tokens.Colors.orange)
                Text("Define smart corrections to automatically replace specific words or phrases")
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Toggle("Enable", isOn: $isEnabled)
                    .toggleStyle(.switch)
                    .tint(Tokens.Colors.orange)
                    .labelsHidden()
                    .help("Enable automatic word replacement after transcription")
            }
            .padding(Tokens.Spacing.md)
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )

            VStack(spacing: 0) {
                HStack(spacing: Tokens.Spacing.lg) {
                    Button(action: { toggleSort(for: .original) }) {
                        HStack(spacing: Tokens.Spacing.xs) {
                            Text("Original")
                                .font(Tokens.Typography.bodyMedium)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            if sortMode == .originalAsc || sortMode == .originalDesc {
                                Image(systemName: sortMode == .originalAsc ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(Tokens.Colors.orange)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Image(systemName: "arrow.right")
                        .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                        .font(.system(size: 12))
                        .frame(width: 20)

                    Button(action: { toggleSort(for: .replacement) }) {
                        HStack(spacing: Tokens.Spacing.xs) {
                            Text("Replacement")
                                .font(Tokens.Typography.bodyMedium)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            if sortMode == .replacementAsc || sortMode == .replacementDesc {
                                Image(systemName: sortMode == .replacementAsc ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(Tokens.Colors.orange)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: Tokens.Spacing.sm) {
                        Button(action: { showAddReplacementModal = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(Tokens.Colors.orange)
                        }
                        .buttonStyle(.borderless)
                    }
                    .frame(width: 60)
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.vertical, Tokens.Spacing.md)
                .background(Tokens.Colors.elevated(for: colorScheme))

                Rectangle()
                    .fill(Tokens.Colors.border(for: colorScheme))
                    .frame(height: 1)

                // Content
                if wordReplacements.isEmpty {
                    WordReplacementEmptyStateView(showAddModal: $showAddReplacementModal)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(sortedReplacements.enumerated()), id: \.element.id) { index, replacement in
                                SwiftDataReplacementRow(
                                    replacement: replacement,
                                    onDelete: { deleteReplacement(replacement) },
                                    onEdit: { editingReplacement = replacement }
                                )

                                if index != sortedReplacements.count - 1 {
                                    Rectangle()
                                        .fill(Tokens.Colors.border(for: colorScheme))
                                        .frame(height: 1)
                                        .padding(.leading, Tokens.Spacing.xxl)
                                }
                            }
                        }
                        .background(Tokens.Colors.elevated(for: colorScheme))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
        .padding(Tokens.Spacing.lg)
        .sheet(isPresented: $showAddReplacementModal) {
            SwiftDataAddReplacementSheet(modelContext: modelContext)
        }
        // Edit existing replacement
        .sheet(item: $editingReplacement) { replacement in
            SwiftDataEditReplacementSheet(replacement: replacement, modelContext: modelContext)
        }
    }

    private func deleteReplacement(_ replacement: WordReplacementModel) {
        modelContext.delete(replacement)
        try? modelContext.save()
    }
}

struct WordReplacementEmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showAddModal: Bool

    var body: some View {
        VStack(spacing: Tokens.Spacing.md) {
            Image(systemName: "text.word.spacing")
                .font(.system(size: 32))
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))

            Text("No Replacements")
                .font(Tokens.Typography.heading3)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            Text("Add smart corrections to automatically replace text.")
                .font(Tokens.Typography.bodySmall)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)

            Button("Add Replacement") {
                showAddModal = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Tokens.Colors.orange)
            .controlSize(.regular)
            .padding(.top, Tokens.Spacing.sm)
        }
        .padding(Tokens.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Tokens.Colors.elevated(for: colorScheme))
    }
}

struct SwiftDataAddReplacementSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    @State private var originalWord = ""
    @State private var replacementWord = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Text("Add Word Replacement")
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Spacer()

                Button("Add") {
                    addReplacement()
                }
                .buttonStyle(.borderedProminent)
                .tint(Tokens.Colors.orange)
                .controlSize(.small)
                .disabled(originalWord.isEmpty || replacementWord.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.vertical, Tokens.Spacing.md)
            .background(Tokens.Colors.elevated(for: colorScheme))

            Rectangle()
                .fill(Tokens.Colors.border(for: colorScheme))
                .frame(height: 1)

            ScrollView {
                VStack(spacing: Tokens.Spacing.lg) {
                    // Description
                    Text("Define a word or phrase to be automatically replaced.")
                        .font(Tokens.Typography.bodySmall)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tokens.Spacing.lg)
                        .padding(.top, Tokens.Spacing.sm)

                    // Form Content
                    VStack(spacing: Tokens.Spacing.lg) {
                        // Original Text Section
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
                            Text("Separate multiple originals with commas, e.g. Voicing, Voice ink, Voiceing")
                                .font(Tokens.Typography.caption)
                                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                        }
                        .padding(.horizontal, Tokens.Spacing.lg)

                        // Replacement Text Section
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

                    // Example Section
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        Text("Examples")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        // Single original -> replacement
                        HStack(spacing: Tokens.Spacing.md) {
                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                Text("Original:")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                                Text("my website link")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                            }

                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))

                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                Text("Replacement:")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                                Text("https://echo.vjh.io")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Tokens.Spacing.md)
                        .background(Tokens.Colors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )

                        // Comma-separated originals -> single replacement
                        HStack(spacing: Tokens.Spacing.md) {
                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                Text("Original:")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                                Text("Voicing, Voice ink, Voiceing")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                            }

                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))

                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                Text("Replacement:")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                                Text("Echo")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Tokens.Spacing.md)
                        .background(Tokens.Colors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, Tokens.Spacing.lg)
                    .padding(.top, Tokens.Spacing.sm)
                }
                .padding(.vertical, Tokens.Spacing.lg)
            }
            .background(Tokens.Colors.background(for: colorScheme))
        }
        .frame(width: 460, height: 520)
    }

    private func addReplacement() {
        let original = originalWord.trimmingCharacters(in: .whitespacesAndNewlines)
        let replacement = replacementWord

        // Validate that at least one non-empty token exists
        let tokens = original
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty && !replacement.isEmpty else { return }

        let newReplacement = WordReplacementModel(originalText: original, replacementText: replacement)
        modelContext.insert(newReplacement)
        try? modelContext.save()
        dismiss()
    }
}

struct SwiftDataEditReplacementSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Bindable var replacement: WordReplacementModel
    let modelContext: ModelContext

    @State private var originalWord: String
    @State private var replacementWord: String

    init(replacement: WordReplacementModel, modelContext: ModelContext) {
        self.replacement = replacement
        self.modelContext = modelContext
        _originalWord = State(initialValue: replacement.originalText)
        _replacementWord = State(initialValue: replacement.replacementText)
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

    private func saveChanges() {
        let newOriginal = originalWord.trimmingCharacters(in: .whitespacesAndNewlines)
        let newReplacement = replacementWord
        // Ensure at least one non-empty token
        let tokens = newOriginal
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty, !newReplacement.isEmpty else { return }

        replacement.originalText = newOriginal
        replacement.replacementText = newReplacement
        try? modelContext.save()
        dismiss()
    }
}

struct SwiftDataReplacementRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let replacement: WordReplacementModel
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: Tokens.Spacing.lg) {
            // Original Text Container
            HStack {
                Text(replacement.originalText)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(Tokens.Colors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity)

            // Arrow
            Image(systemName: "arrow.right")
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                .font(.system(size: 12))

            // Replacement Text Container
            HStack {
                Text(replacement.replacementText)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(Tokens.Colors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity)

            // Edit Button
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(Tokens.Colors.orange)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .help("Edit replacement")

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Tokens.Colors.error)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .help("Remove replacement")
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.sm)
        .contentShape(Rectangle())
        .background(Tokens.Colors.elevated(for: colorScheme))
    }
}

// Keep legacy views for backward compatibility
struct AddReplacementSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var manager: WordReplacementManager
    @Environment(\.dismiss) private var dismiss
    @State private var originalWord = ""
    @State private var replacementWord = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Text("Add Word Replacement")
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Spacer()

                Button("Add") {
                    addReplacement()
                }
                .buttonStyle(.borderedProminent)
                .tint(Tokens.Colors.orange)
                .controlSize(.small)
                .disabled(originalWord.isEmpty || replacementWord.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.vertical, Tokens.Spacing.md)
            .background(Tokens.Colors.elevated(for: colorScheme))

            Rectangle()
                .fill(Tokens.Colors.border(for: colorScheme))
                .frame(height: 1)

            ScrollView {
                VStack(spacing: Tokens.Spacing.lg) {
                    // Description
                    Text("Define a word or phrase to be automatically replaced.")
                        .font(Tokens.Typography.bodySmall)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tokens.Spacing.lg)
                        .padding(.top, Tokens.Spacing.sm)

                    // Form Content
                    VStack(spacing: Tokens.Spacing.lg) {
                        // Original Text Section
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
                            Text("Separate multiple originals with commas, e.g. Voicing, Voice ink, Voiceing")
                                .font(Tokens.Typography.caption)
                                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                        }
                        .padding(.horizontal, Tokens.Spacing.lg)

                        // Replacement Text Section
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
                .padding(.vertical, Tokens.Spacing.lg)
            }
            .background(Tokens.Colors.background(for: colorScheme))
        }
        .frame(width: 460, height: 520)
    }

    private func addReplacement() {
        let original = originalWord
        let replacement = replacementWord

        // Validate that at least one non-empty token exists
        let tokens = original
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty && !replacement.isEmpty else { return }

        manager.addReplacement(original: original, replacement: replacement)
        dismiss()
    }
}

struct ReplacementRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let original: String
    let replacement: String
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: Tokens.Spacing.lg) {
            // Original Text Container
            HStack {
                Text(original)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(Tokens.Colors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity)

            // Arrow
            Image(systemName: "arrow.right")
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                .font(.system(size: 12))

            // Replacement Text Container
            HStack {
                Text(replacement)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(Tokens.Colors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity)

            // Edit Button
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(Tokens.Colors.orange)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .help("Edit replacement")

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Tokens.Colors.error)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .help("Remove replacement")
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.sm)
        .contentShape(Rectangle())
        .background(Tokens.Colors.elevated(for: colorScheme))
    }
}
