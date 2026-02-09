import Foundation

class FillerWordManager: ObservableObject {
    static let shared = FillerWordManager()

    static let defaultFillerWords = [
        "uh", "um", "uhm", "umm", "uhh", "uhhh", "ah", "eh",
        "hmm", "hm", "mmm", "mm", "mh", "ha", "ehh"
    ]

    private let fillerWordsKey = "FillerWords"
    private let removeFillerWordsKey = "RemoveFillerWords"

    @Published var fillerWords: [String] {
        didSet {
            UserDefaults.standard.set(fillerWords, forKey: fillerWordsKey)
        }
    }

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: removeFillerWordsKey)
    }

    private init() {
        if let saved = UserDefaults.standard.stringArray(forKey: fillerWordsKey) {
            self.fillerWords = saved
        } else {
            self.fillerWords = Self.defaultFillerWords
        }
    }

    func addWord(_ word: String) -> Bool {
        let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return false }
        guard !fillerWords.contains(where: { $0.lowercased() == normalized }) else { return false }
        fillerWords.append(normalized)
        return true
    }

    func removeWord(_ word: String) {
        fillerWords.removeAll { $0.lowercased() == word.lowercased() }
    }

    /// Removes filler words from the given text
    func removeFillerWords(from text: String) -> String {
        guard isEnabled, !fillerWords.isEmpty else { return text }

        var result = text

        for word in fillerWords {
            // Match the filler word with word boundaries (case-insensitive)
            // Also handle common punctuation around filler words
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))\\b[,.]?\\s*"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(
                    in: result,
                    options: [],
                    range: range,
                    withTemplate: ""
                )
            }
        }

        // Clean up any double spaces created by removal
        while result.contains("  ") {
            result = result.replacingOccurrences(of: "  ", with: " ")
        }

        // Clean up leading/trailing whitespace
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }
}
