import SwiftUI
import AppKit

struct SingleKeyRecorderView: View {
    @Binding var shortcut: SingleKeyShortcut?
    var onChanged: (() -> Void)? = nil

    @State private var isRecording = false
    @State private var showCharacterWarning = false
    @State private var localMonitor: Any?
    @State private var peakModifiers: [UInt16] = []
    @State private var livePreview: String = ""
    @Environment(\.colorScheme) private var colorScheme

    private static let modifierKeyCodes: Set<UInt16> = [0x3A, 0x3D, 0x3B, 0x3E, 0x3F, 0x36, 0x37, 0x38, 0x3C]

    var body: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            Button(action: { toggleRecording() }) {
                HStack(spacing: Tokens.Spacing.sm) {
                    if isRecording {
                        Circle()
                            .fill(Tokens.Colors.orange)
                            .frame(width: 6, height: 6)
                        Text(livePreview.isEmpty ? "Press any key…" : livePreview)
                            .foregroundColor(Tokens.Colors.orange)
                    } else if let shortcut = shortcut {
                        Text(shortcut.displayName)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    } else {
                        Text("Click to set")
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }
                }
                .font(Tokens.Typography.body)
                .padding(.horizontal, Tokens.Spacing.md)
                .padding(.vertical, Tokens.Spacing.sm)
                .background(isRecording
                    ? Tokens.Colors.orangeSoft(for: colorScheme)
                    : Tokens.Colors.background(for: colorScheme))
                .cornerRadius(Tokens.Radius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                        .stroke(isRecording
                            ? Tokens.Colors.orange
                            : Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if shortcut != nil && !isRecording {
                Button(action: {
                    shortcut = nil
                    onChanged?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .popover(isPresented: $showCharacterWarning) {
            Text("Letter and number keys can't be used as shortcuts because they'd type into other apps. Use a modifier key (Option, Command, etc.) or a function key (F1–F12).")
                .font(Tokens.Typography.bodySmall)
                .padding(Tokens.Spacing.md)
                .frame(width: 260)
        }
        .onDisappear {
            stopRecording()
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        peakModifiers = []
        livePreview = ""

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [self] event in
            if event.type == .keyDown && event.keyCode == 0x35 {
                // Escape cancels recording
                stopRecording()
                return nil
            }
            handleRecordEvent(event)
            return nil // Consume the event
        }
    }

    private func handleRecordEvent(_ event: NSEvent) {
        if event.type == .flagsChanged {
            let keyCode = event.keyCode
            guard Self.modifierKeyCodes.contains(keyCode) else { return }

            if isModifierKeyDown(keyCode: keyCode, flags: event.modifierFlags) {
                // Key pressed — add to peak set
                if !peakModifiers.contains(keyCode) {
                    peakModifiers.append(keyCode)
                }
                // Update live preview
                livePreview = peakModifiers.compactMap { SingleKeyShortcut.displayName(for: $0) }.joined(separator: " + ")
            } else {
                // Key released — check if ALL modifiers are now released
                let relevantFlags: NSEvent.ModifierFlags = [.option, .control, .function, .command, .shift]
                let noModifiersDown = event.modifierFlags.intersection(relevantFlags).isEmpty

                if noModifiersDown && !peakModifiers.isEmpty {
                    // All released — capture
                    captureModifierShortcut()
                }
            }

        } else if event.type == .keyDown {
            let keyCode = event.keyCode
            if SingleKeyShortcut.isCharacterKey(keyCode) {
                showCharacterWarning = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showCharacterWarning = false
                }
                return
            }
            shortcut = SingleKeyShortcut(keyCode: keyCode, isModifier: false)
            onChanged?()
            stopRecording()
        }
    }

    private func captureModifierShortcut() {
        guard !peakModifiers.isEmpty else { return }

        if peakModifiers.count == 1 {
            shortcut = SingleKeyShortcut(keyCode: peakModifiers[0], isModifier: true)
        } else {
            shortcut = SingleKeyShortcut(
                keyCode: peakModifiers[0],
                isModifier: true,
                comboKeyCodes: peakModifiers
            )
        }
        onChanged?()
        stopRecording()
    }

    private func isModifierKeyDown(keyCode: UInt16, flags: NSEvent.ModifierFlags) -> Bool {
        switch keyCode {
        case 0x3A, 0x3D: return flags.contains(.option)
        case 0x3B, 0x3E: return flags.contains(.control)
        case 0x3F: return flags.contains(.function)
        case 0x36, 0x37: return flags.contains(.command)
        case 0x38, 0x3C: return flags.contains(.shift)
        default: return false
        }
    }

    private func stopRecording() {
        isRecording = false
        peakModifiers = []
        livePreview = ""
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
}
