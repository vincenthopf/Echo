import Foundation
import AppKit

class CursorPaster {

    /// Paste text at cursor using the active PowerMode configuration settings
    static func pasteAtCursor(_ text: String) {
        // Check if active PowerMode config has type-out mode enabled
        let powerMode = PowerModeManager.shared
        if let activeConfig = powerMode.currentActiveConfiguration, activeConfig.useTypeOutPaste {
            let charDelayMs = 30.0 / max(activeConfig.typeOutSpeed, 0.1)
            typeAtCursor(text, useShiftEnterForNewlines: activeConfig.useShiftEnterForNewlines, charDelayMs: charDelayMs)
            return
        }

        // Fallback to global setting for backward compatibility
        if UserDefaults.standard.bool(forKey: "UseTypeOutPaste") {
            let globalSpeed = UserDefaults.standard.double(forKey: "TypeOutSpeed")
            let speed = globalSpeed > 0 ? globalSpeed : 1.0
            let charDelayMs = 30.0 / speed
            typeAtCursor(text, useShiftEnterForNewlines: false, charDelayMs: charDelayMs)
            return
        }

        // Original clipboard-based paste logic
        let pasteboard = NSPasteboard.general
        let shouldPreserveTranscript = UserDefaults.standard.bool(forKey: "preserveTranscriptInClipboard")
        let shouldRestoreClipboard = UserDefaults.standard.bool(forKey: "restoreClipboardAfterPaste") && !shouldPreserveTranscript

        var savedContents: [(NSPasteboard.PasteboardType, Data)] = []

        if shouldRestoreClipboard {
            let currentItems = pasteboard.pasteboardItems ?? []

            for item in currentItems {
                for type in item.types {
                    if let data = item.data(forType: type) {
                        savedContents.append((type, data))
                    }
                }
            }
        }

        ClipboardManager.setClipboard(text, transient: shouldRestoreClipboard)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if UserDefaults.standard.bool(forKey: "UseAppleScriptPaste") {
                _ = pasteUsingAppleScript()
            } else {
                pasteUsingCommandV()
            }
        }

        if shouldRestoreClipboard {
            let delay = UserDefaults.standard.double(forKey: "clipboardRestoreDelay")

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if !savedContents.isEmpty {
                    pasteboard.clearContents()
                    for (type, data) in savedContents {
                        pasteboard.setData(data, forType: type)
                    }
                }
            }
        }
    }

    /// Types text using keyboard simulation via AppleScript.
    /// This bypasses the clipboard entirely, avoiding "pasted text" overlays in apps like Claude Code.
    /// - Parameters:
    ///   - text: The text to type
    ///   - useShiftEnterForNewlines: If true, uses Shift+Enter for newlines instead of Enter
    ///   - charDelayMs: Delay between characters in milliseconds (default 30ms ≈ 400 WPM)
    private static func typeAtCursor(_ text: String, useShiftEnterForNewlines: Bool, charDelayMs: Double = 30.0) {
        guard AXIsProcessTrusted() else { return }

        let charDelayMicroseconds: useconds_t = useconds_t(charDelayMs * 1000)

        // Process text line by line to handle newlines properly
        let lines = text.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            // Type each character individually with delay for natural typing feel
            for char in line {
                // Escape special characters for AppleScript string
                var charStr = String(char)
                charStr = charStr
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")

                let script = """
                tell application "System Events"
                    keystroke "\(charStr)"
                end tell
                """

                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: script) {
                    scriptObject.executeAndReturnError(&error)
                }

                // Delay between characters to simulate 200 WPM typing
                usleep(charDelayMicroseconds)
            }

            // Add newline between lines (but not after the last line)
            if index < lines.count - 1 {
                if useShiftEnterForNewlines {
                    // Use Shift+Enter for newline (doesn't send message in Claude Code)
                    let returnScript = """
                    tell application "System Events"
                        keystroke return using shift down
                    end tell
                    """

                    var error: NSDictionary?
                    if let scriptObject = NSAppleScript(source: returnScript) {
                        scriptObject.executeAndReturnError(&error)
                    }
                } else {
                    // Use regular Enter
                    let returnScript = """
                    tell application "System Events"
                        keystroke return
                    end tell
                    """

                    var error: NSDictionary?
                    if let scriptObject = NSAppleScript(source: returnScript) {
                        scriptObject.executeAndReturnError(&error)
                    }
                }

                // Delay after newline (same as character delay)
                usleep(charDelayMicroseconds)
            }
        }
    }

    private static func pasteUsingAppleScript() -> Bool {
        guard AXIsProcessTrusted() else {
            return false
        }

        let script = """
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            _ = scriptObject.executeAndReturnError(&error)
            return error == nil
        }
        return false
    }

    private static func pasteUsingCommandV() {
        guard AXIsProcessTrusted() else {
            return
        }

        let source = CGEventSource(stateID: .hidSystemState)

        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        cmdDown?.flags = .maskCommand
        vDown?.flags = .maskCommand
        vUp?.flags = .maskCommand

        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }

    // Simulate pressing the Return / Enter key
    static func pressEnter() {
        guard AXIsProcessTrusted() else { return }
        let source = CGEventSource(stateID: .hidSystemState)
        let enterDown = CGEvent(keyboardEventSource: source, virtualKey: 0x24, keyDown: true)
        let enterUp = CGEvent(keyboardEventSource: source, virtualKey: 0x24, keyDown: false)
        enterDown?.post(tap: .cghidEventTap)
        enterUp?.post(tap: .cghidEventTap)
    }
}
