import Foundation
import AppKit

struct SingleKeyShortcut: Equatable, Codable {
    let keyCode: UInt16
    let isModifier: Bool
    let comboKeyCodes: [UInt16]?

    init(keyCode: UInt16, isModifier: Bool, comboKeyCodes: [UInt16]? = nil) {
        self.keyCode = keyCode
        self.isModifier = isModifier
        self.comboKeyCodes = comboKeyCodes
    }

    var isCombo: Bool {
        guard let combo = comboKeyCodes else { return false }
        return combo.count > 1
    }

    var allKeyCodes: Set<UInt16> {
        if let combo = comboKeyCodes {
            return Set(combo)
        }
        return [keyCode]
    }

    var displayName: String {
        if isCombo, let combo = comboKeyCodes {
            return combo.compactMap { Self.displayName(for: $0) }.joined(separator: " + ")
        }
        return Self.displayName(for: keyCode) ?? "Key \(keyCode)"
    }

    /// Returns the combined modifier flags required for this shortcut.
    /// For single keys, returns the single flag. For combos, returns all flags OR'd together.
    var requiredModifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        for code in allKeyCodes {
            if let flag = Self.modifierFlagForKeyCode(code) {
                flags.insert(flag)
            }
        }
        return flags
    }

    var modifierFlag: NSEvent.ModifierFlags? {
        Self.modifierFlagForKeyCode(keyCode)
    }

    var isFnKey: Bool {
        keyCode == 0x3F && !isCombo
    }

    static func modifierFlagForKeyCode(_ keyCode: UInt16) -> NSEvent.ModifierFlags? {
        switch keyCode {
        case 0x3A, 0x3D: return .option
        case 0x3B, 0x3E: return .control
        case 0x3F: return .function
        case 0x36, 0x37: return .command
        case 0x38, 0x3C: return .shift
        default: return nil
        }
    }

    /// Returns true for character keys (letters, numbers, punctuation) that would
    /// produce typed input in other apps. These are blocked from being set as Echo shortcuts.
    static func isCharacterKey(_ keyCode: UInt16) -> Bool {
        return !allowedKeyCodes.contains(keyCode)
    }

    static func displayName(for keyCode: UInt16) -> String? {
        keyDisplayNames[keyCode]
    }

    // MARK: - Key Code Constants

    private static let allowedKeyCodes: Set<UInt16> = [
        // Modifier keys
        0x3A, // Left Option
        0x3D, // Right Option
        0x3B, // Left Control
        0x3E, // Right Control
        0x3F, // Fn/Globe
        0x36, // Right Command
        0x37, // Left Command
        0x38, // Left Shift
        0x3C, // Right Shift
        // Function keys
        0x7A, // F1
        0x78, // F2
        0x63, // F3
        0x76, // F4
        0x60, // F5
        0x61, // F6
        0x62, // F7
        0x64, // F8
        0x65, // F9
        0x6D, // F10
        0x67, // F11
        0x6F, // F12
        0x69, // F13
        0x6B, // F14
        0x71, // F15
        0x6A, // F16
        0x40, // F17
        0x4F, // F18
        0x50, // F19
        0x5A, // F20
        // Navigation keys
        0x7E, // Up Arrow
        0x7D, // Down Arrow
        0x7B, // Left Arrow
        0x7C, // Right Arrow
        0x73, // Home
        0x77, // End
        0x74, // Page Up
        0x79, // Page Down
        // Other non-character keys
        0x33, // Delete/Backspace
        0x75, // Forward Delete
        0x47, // Clear/Num Lock
    ]

    private static let keyDisplayNames: [UInt16: String] = [
        // Modifiers
        0x3A: "Left Option (⌥)",
        0x3D: "Right Option (⌥)",
        0x3B: "Left Control (⌃)",
        0x3E: "Right Control (⌃)",
        0x3F: "Fn (Globe)",
        0x36: "Right Command (⌘)",
        0x37: "Left Command (⌘)",
        0x38: "Left Shift (⇧)",
        0x3C: "Right Shift (⇧)",
        // Function keys
        0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4",
        0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8",
        0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",
        0x69: "F13", 0x6B: "F14", 0x71: "F15", 0x6A: "F16",
        0x40: "F17", 0x4F: "F18", 0x50: "F19", 0x5A: "F20",
        // Navigation
        0x7E: "Up Arrow (↑)", 0x7D: "Down Arrow (↓)",
        0x7B: "Left Arrow (←)", 0x7C: "Right Arrow (→)",
        0x73: "Home", 0x77: "End", 0x74: "Page Up", 0x79: "Page Down",
        // Other
        0x33: "Delete (⌫)", 0x75: "Forward Delete (⌦)", 0x47: "Clear",
    ]

    // MARK: - Migration from old HotkeyOption

    static func fromLegacyRawValue(_ rawValue: String) -> SingleKeyShortcut? {
        switch rawValue {
        case "rightOption":   return SingleKeyShortcut(keyCode: 0x3D, isModifier: true)
        case "leftOption":    return SingleKeyShortcut(keyCode: 0x3A, isModifier: true)
        case "leftControl":   return SingleKeyShortcut(keyCode: 0x3B, isModifier: true)
        case "rightControl":  return SingleKeyShortcut(keyCode: 0x3E, isModifier: true)
        case "fn":            return SingleKeyShortcut(keyCode: 0x3F, isModifier: true)
        case "rightCommand":  return SingleKeyShortcut(keyCode: 0x36, isModifier: true)
        case "rightShift":    return SingleKeyShortcut(keyCode: 0x3C, isModifier: true)
        case "custom":        return SingleKeyShortcut(keyCode: 0x36, isModifier: true) // fallback to Right Command
        case "none":          return nil
        default:              return nil
        }
    }
}
