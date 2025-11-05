import Foundation
import AppKit

/// Curated SF Symbols for Adaptive Awareness profile icons
enum ProfileSymbol: String, CaseIterable, Identifiable {
    // Core transcription symbols
    case sparkles = "sparkles"
    case mic = "mic.fill"
    case waveform = "waveform"
    case quote = "quote.bubble.fill"

    // Intelligence & processing
    case brain = "brain"
    case lightbulb = "lightbulb.fill"
    case bolt = "bolt.fill"
    case cpu = "cpu.fill"

    // Communication & text
    case message = "message.fill"
    case doc = "doc.text.fill"
    case pencil = "pencil"
    case keyboard = "keyboard.fill"
    case textFormat = "textformat"

    // Organization & context
    case star = "star.fill"
    case flag = "flag.fill"
    case bookmark = "bookmark.fill"
    case folder = "folder.fill"

    // Productivity & work
    case briefcase = "briefcase.fill"
    case app = "app.fill"
    case globe = "globe"
    case book = "book.fill"

    // Development & technical
    case code = "chevron.left.forwardslash.chevron.right"
    case terminal = "terminal.fill"
    case gearshape = "gearshape.fill"

    // Status & markers
    case checkmark = "checkmark.circle.fill"
    case exclamationmark = "exclamationmark.circle.fill"
    case questionmark = "questionmark.circle.fill"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        // Core transcription symbols
        case .sparkles: return "Sparkles"
        case .mic: return "Microphone"
        case .waveform: return "Waveform"
        case .quote: return "Quote"

        // Intelligence & processing
        case .brain: return "Brain"
        case .lightbulb: return "Lightbulb"
        case .bolt: return "Bolt"
        case .cpu: return "Processor"

        // Communication & text
        case .message: return "Message"
        case .doc: return "Document"
        case .pencil: return "Pencil"
        case .keyboard: return "Keyboard"
        case .textFormat: return "Text Format"

        // Organization & context
        case .star: return "Star"
        case .flag: return "Flag"
        case .bookmark: return "Bookmark"
        case .folder: return "Folder"

        // Productivity & work
        case .briefcase: return "Briefcase"
        case .app: return "App"
        case .globe: return "Globe"
        case .book: return "Book"

        // Development & technical
        case .code: return "Code"
        case .terminal: return "Terminal"
        case .gearshape: return "Settings"

        // Status & markers
        case .checkmark: return "Checkmark"
        case .exclamationmark: return "Exclamation"
        case .questionmark: return "Question"
        }
    }
}

/// Helper extension to detect if a string is an SF Symbol or emoji
extension String {
    /// Checks if the string is a valid SF Symbol name
    var isSFSymbol: Bool {
        #if os(macOS)
        return NSImage(systemSymbolName: self, accessibilityDescription: nil) != nil
        #else
        return UIImage(systemName: self) != nil
        #endif
    }

    /// Checks if the string contains actual emoji characters (not just emoji-capable characters)
    var containsEmoji: Bool {
        return unicodeScalars.contains { scalar in
            // Check for actual emoji presentation or emoji modifiers
            // This avoids false positives for regular text that can technically render as emoji
            scalar.properties.isEmojiPresentation ||
            (scalar.properties.isEmoji && scalar.properties.isEmojiModifier)
        }
    }

    /// Determines if this string should be rendered as an SF Symbol or text/emoji
    var shouldRenderAsSFSymbol: Bool {
        // If it's a valid SF Symbol, use it as a symbol regardless of emoji detection
        // This ensures SF Symbol names like "sparkles" render correctly as icons
        return isSFSymbol
    }
}
