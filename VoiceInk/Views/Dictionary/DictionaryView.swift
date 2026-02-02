import SwiftUI

struct DictionaryItem: Identifiable, Hashable, Codable {
    let id: UUID
    var word: String
    var dateAdded: Date

    init(id: UUID = UUID(), word: String, dateAdded: Date = Date()) {
        self.id = id
        self.word = word
        self.dateAdded = dateAdded
    }

    // Legacy support for decoding old data with isEnabled property
    private enum CodingKeys: String, CodingKey {
        case id, word, dateAdded, isEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        // Ignore isEnabled during decoding - all items are enabled by default now
        _ = try? container.decodeIfPresent(Bool.self, forKey: .isEnabled)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(word, forKey: .word)
        try container.encode(dateAdded, forKey: .dateAdded)
        // Don't encode isEnabled anymore
    }
}

class DictionaryManager: ObservableObject {
    @Published var items: [DictionaryItem] = []
    private let saveKey = "CustomDictionaryItems"
    private let whisperPrompt: WhisperPrompt

    init(whisperPrompt: WhisperPrompt) {
        self.whisperPrompt = whisperPrompt
        loadItems()
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }

        if let savedItems = try? JSONDecoder().decode([DictionaryItem].self, from: data) {
            items = savedItems.sorted(by: { $0.dateAdded > $1.dateAdded })
        }
    }

    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func addWord(_ word: String) {
        let normalizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !items.contains(where: { $0.word.lowercased() == normalizedWord.lowercased() }) else {
            return
        }

        let newItem = DictionaryItem(word: normalizedWord)
        items.insert(newItem, at: 0)
        saveItems()
    }

    func removeWord(_ word: String) {
        items.removeAll(where: { $0.word == word })
        saveItems()
    }

    var allWords: [String] {
        items.map { $0.word }
    }
}

struct DictionaryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var dictionaryManager: DictionaryManager
    @ObservedObject var whisperPrompt: WhisperPrompt
    @State private var newWord = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(whisperPrompt: WhisperPrompt) {
        self.whisperPrompt = whisperPrompt
        _dictionaryManager = StateObject(wrappedValue: DictionaryManager(whisperPrompt: whisperPrompt))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            // Information Section
            HStack(spacing: Tokens.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Tokens.Colors.orange)
                Text("Add words to help Echo recognize them properly. (Requires Intelligent Transformation)")
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Tokens.Spacing.md)
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )

            // Input Section
            HStack(spacing: Tokens.Spacing.sm) {
                TextField("Add word to vocabulary", text: $newWord)
                    .textFieldStyle(.plain)
                    .font(Tokens.Typography.bodySmall)
                    .padding(Tokens.Spacing.sm)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
                    .onSubmit { addWords() }

                Button(action: addWords) {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Tokens.Colors.orange)
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .disabled(newWord.isEmpty)
                .help("Add word")
            }

            // Words List
            if !dictionaryManager.items.isEmpty {
                VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                    Text("Vocabulary Items (\(dictionaryManager.items.count))")
                        .font(Tokens.Typography.label)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                    ScrollView {
                        let columns = [
                            GridItem(.adaptive(minimum: 240, maximum: .infinity), spacing: Tokens.Spacing.md)
                        ]

                        LazyVGrid(columns: columns, alignment: .leading, spacing: Tokens.Spacing.md) {
                            ForEach(dictionaryManager.items) { item in
                                DictionaryItemView(item: item, colorScheme: colorScheme) {
                                    dictionaryManager.removeWord(item.word)
                                }
                            }
                        }
                        .padding(.vertical, Tokens.Spacing.xs)
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.top, Tokens.Spacing.xs)
            }
        }
        .padding(Tokens.Spacing.lg)
        .alert("Personal Vocabulary", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addWords() {
        let input = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        
        let parts = input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !parts.isEmpty else { return }
        
        if parts.count == 1, let word = parts.first {
            if dictionaryManager.items.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                alertMessage = "'\(word)' is already in the vocabulary"
                showAlert = true
                return
            }
            dictionaryManager.addWord(word)
            newWord = ""
            return
        }
        
        for word in parts {
            let lower = word.lowercased()
            if !dictionaryManager.items.contains(where: { $0.word.lowercased() == lower }) {
                dictionaryManager.addWord(word)
            }
        }
        newWord = ""
    }
}

struct DictionaryItemView: View {
    let item: DictionaryItem
    let colorScheme: ColorScheme
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            Text(item.word)
                .font(Tokens.Typography.bodySmall)
                .lineLimit(1)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            Spacer(minLength: Tokens.Spacing.sm)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isHovered ? Tokens.Colors.error : Tokens.Colors.textSecondary(for: colorScheme))
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .help("Remove word")
            .onHover { hover in
                withAnimation(Tokens.Animation.easing) {
                    isHovered = hover
                }
            }
        }
        .padding(.horizontal, Tokens.Spacing.sm)
        .padding(.vertical, Tokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                .fill(isHovered
                      ? Tokens.Colors.orangeSoft(for: colorScheme)
                      : Tokens.Colors.elevated(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }
} 
