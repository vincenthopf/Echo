import Foundation
import SwiftUI
import SwiftData

class DictionaryContextService {
    static let shared = DictionaryContextService()

    private init() {}

    private let predefinedWords = "Echo, chatGPT, GPT-5, GPT-4.1, Claude, Claude Sonnet, Claude Opus, Gemini, OpenRouter, Ollama, deepseek, elevenlabs, Kyutai, Parakeet, whisper"

    /// Get dictionary context using SwiftData
    func getDictionaryContext(from context: ModelContext) -> String {
        var allWords: [String] = []

        allWords.append(predefinedWords)

        if let customWords = CustomVocabularyService.shared.getCustomVocabularyWords(from: context) {
            allWords.append(customWords.joined(separator: ", "))
        }

        let wordsText = allWords.joined(separator: ", ")
        return "Important Vocabulary: \(wordsText)"
    }

    /// Legacy method for backward compatibility - uses UserDefaults
    func getDictionaryContext() -> String {
        var allWords: [String] = []

        allWords.append(predefinedWords)

        if let customWords = getCustomDictionaryWords() {
            allWords.append(customWords.joined(separator: ", "))
        }

        let wordsText = allWords.joined(separator: ", ")
        return "Important Vocabulary: \(wordsText)"
    }

    private func getCustomDictionaryWords() -> [String]? {
        guard let data = UserDefaults.standard.data(forKey: "CustomDictionaryItems") else {
            return nil
        }

        do {
            let items = try JSONDecoder().decode([DictionaryItem].self, from: data)
            let words = items.map { $0.word }
            return words.isEmpty ? nil : words
        } catch {
            return nil
        }
    }
}
