import Foundation
import KeyboardShortcuts
import Carbon
import AppKit

extension KeyboardShortcuts.Name {
    static let pasteLastTranscription = Self("pasteLastTranscription")
    static let pasteLastEnhancement = Self("pasteLastEnhancement")
    static let retryLastTranscription = Self("retryLastTranscription")
}

@MainActor
class HotkeyManager: ObservableObject {
    @Published var hotkey1: SingleKeyShortcut? {
        didSet {
            // Clear hotkey2 if it conflicts
            if let h1 = hotkey1, let h2 = hotkey2, h1 == h2 {
                hotkey2 = nil
            }
            persistHotkey(hotkey1, forKey: "echoHotkey1")
            setupHotkeyMonitoring()
        }
    }
    @Published var hotkey2: SingleKeyShortcut? {
        didSet {
            // Reject if same as hotkey1
            if let h1 = hotkey1, let h2 = hotkey2, h1 == h2 {
                hotkey2 = nil
                return
            }
            persistHotkey(hotkey2, forKey: "echoHotkey2")
            setupHotkeyMonitoring()
        }
    }
    @Published var isMiddleClickToggleEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMiddleClickToggleEnabled, forKey: "isMiddleClickToggleEnabled")
            setupHotkeyMonitoring()
        }
    }
    @Published var middleClickActivationDelay: Int {
        didSet {
            UserDefaults.standard.set(middleClickActivationDelay, forKey: "middleClickActivationDelay")
        }
    }

    private var whisperState: WhisperState
    private var miniRecorderShortcutManager: MiniRecorderShortcutManager

    // MARK: - Helper Properties
    private var canProcessHotkeyAction: Bool {
        whisperState.recordingState != .transcribing && whisperState.recordingState != .enhancing && whisperState.recordingState != .busy
    }

    // NSEvent monitoring
    private var globalFlagsMonitor: Any?
    private var localFlagsMonitor: Any?
    private var globalKeyDownMonitor: Any?
    private var globalKeyUpMonitor: Any?
    private var localKeyDownMonitor: Any?

    // Middle-click event monitoring
    private var middleClickMonitors: [Any?] = []
    private var middleClickTask: Task<Void, Never>?

    // Key state tracking
    private var currentKeyState = false
    private var keyPressStartTime: Date?
    private let briefPressThreshold = 1.7
    private var isHandsFreeMode = false

    // Debounce for Fn key
    private var fnDebounceTask: Task<Void, Never>?
    private var pendingFnKeyState: Bool? = nil

    init(whisperState: WhisperState) {
        self.whisperState = whisperState

        // Load hotkeys (with migration from legacy format)
        self.hotkey1 = Self.loadHotkey(forKey: "echoHotkey1", legacyKey: "selectedHotkey1", legacyDefault: "rightCommand")
        self.hotkey2 = Self.loadHotkey(forKey: "echoHotkey2", legacyKey: "selectedHotkey2", legacyDefault: "none")

        self.isMiddleClickToggleEnabled = UserDefaults.standard.bool(forKey: "isMiddleClickToggleEnabled")
        let storedDelay = UserDefaults.standard.integer(forKey: "middleClickActivationDelay")
        self.middleClickActivationDelay = storedDelay > 0 ? storedDelay : 200

        self.miniRecorderShortcutManager = MiniRecorderShortcutManager(whisperState: whisperState)

        KeyboardShortcuts.onKeyUp(for: .pasteLastTranscription) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                LastTranscriptionService.pasteLastTranscription(from: self.whisperState.modelContext)
            }
        }

        KeyboardShortcuts.onKeyUp(for: .pasteLastEnhancement) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                LastTranscriptionService.pasteLastEnhancement(from: self.whisperState.modelContext)
            }
        }

        KeyboardShortcuts.onKeyUp(for: .retryLastTranscription) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                LastTranscriptionService.retryLastTranscription(from: self.whisperState.modelContext, whisperState: self.whisperState)
            }
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            self.setupHotkeyMonitoring()
        }
    }

    // MARK: - Persistence

    private func persistHotkey(_ shortcut: SingleKeyShortcut?, forKey key: String) {
        if let shortcut = shortcut, let data = try? JSONEncoder().encode(shortcut) {
            UserDefaults.standard.set(data, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static func loadHotkey(forKey key: String, legacyKey: String, legacyDefault: String) -> SingleKeyShortcut? {
        // Try new format first
        if let data = UserDefaults.standard.data(forKey: key),
           let shortcut = try? JSONDecoder().decode(SingleKeyShortcut.self, from: data) {
            return shortcut
        }

        // Migrate from legacy format
        let legacyRaw = UserDefaults.standard.string(forKey: legacyKey) ?? legacyDefault
        let migrated = SingleKeyShortcut.fromLegacyRawValue(legacyRaw)

        // Persist in new format and clean up legacy key
        if let migrated = migrated, let data = try? JSONEncoder().encode(migrated) {
            UserDefaults.standard.set(data, forKey: key)
        }
        UserDefaults.standard.removeObject(forKey: legacyKey)

        return migrated
    }

    // MARK: - Monitoring Setup

    private func setupHotkeyMonitoring() {
        removeAllMonitoring()

        setupKeyMonitoring()
        setupMiddleClickMonitoring()
    }

    private func setupKeyMonitoring() {
        let hasModifier = (hotkey1?.isModifier == true) || (hotkey2?.isModifier == true)
        let hasNonModifier = (hotkey1 != nil && hotkey1?.isModifier == false) || (hotkey2 != nil && hotkey2?.isModifier == false)

        guard hasModifier || hasNonModifier else { return }

        if hasModifier {
            globalFlagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                guard let self = self else { return }
                Task { @MainActor in
                    self.handleFlagsChangedEvent(event)
                }
            }
            localFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                guard let self = self else { return event }
                Task { @MainActor in
                    self.handleFlagsChangedEvent(event)
                }
                return event
            }
        }

        if hasNonModifier {
            globalKeyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self = self else { return }
                Task { @MainActor in
                    self.handleKeyDownEvent(event)
                }
            }
            globalKeyUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) { [weak self] event in
                guard let self = self else { return }
                Task { @MainActor in
                    self.handleKeyUpEvent(event)
                }
            }
            localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
                guard let self = self else { return event }
                Task { @MainActor in
                    if event.type == .keyDown {
                        self.handleKeyDownEvent(event)
                    } else {
                        self.handleKeyUpEvent(event)
                    }
                }
                return event
            }
        }
    }

    private func setupMiddleClickMonitoring() {
        guard isMiddleClickToggleEnabled else { return }

        let downMonitor = NSEvent.addGlobalMonitorForEvents(matching: .otherMouseDown) { [weak self] event in
            guard let self = self, event.buttonNumber == 2 else { return }

            self.middleClickTask?.cancel()
            self.middleClickTask = Task {
                do {
                    let delay = UInt64(self.middleClickActivationDelay) * 1_000_000
                    try await Task.sleep(nanoseconds: delay)

                    guard self.isMiddleClickToggleEnabled, !Task.isCancelled else { return }

                    Task { @MainActor in
                        guard self.canProcessHotkeyAction else { return }
                        await self.whisperState.handleToggleMiniRecorder()
                    }
                } catch {
                    // Cancelled
                }
            }
        }

        let upMonitor = NSEvent.addGlobalMonitorForEvents(matching: .otherMouseUp) { [weak self] event in
            guard let self = self, event.buttonNumber == 2 else { return }
            self.middleClickTask?.cancel()
        }

        middleClickMonitors = [downMonitor, upMonitor]
    }

    // MARK: - Event Handling

    private func handleFlagsChangedEvent(_ event: NSEvent) {
        let keyCode = event.keyCode
        let flags = event.modifierFlags

        // Find matching hotkey (checks all keyCodes including combo members)
        guard let hotkey = matchingModifierHotkey(for: keyCode) else { return }

        // For combos, check if ALL required flags are present
        let requiredFlags = hotkey.requiredModifierFlags
        let isKeyPressed = flags.contains(requiredFlags)

        // Fn key gets debounced (only for single Fn, not combos)
        if hotkey.isFnKey {
            pendingFnKeyState = isKeyPressed
            fnDebounceTask?.cancel()
            fnDebounceTask = Task { [pendingState = isKeyPressed] in
                try? await Task.sleep(nanoseconds: 75_000_000) // 75ms
                if self.pendingFnKeyState == pendingState {
                    await MainActor.run {
                        self.processKeyPress(isKeyPressed: pendingState)
                    }
                }
            }
            return
        }

        processKeyPress(isKeyPressed: isKeyPressed)
    }

    private func handleKeyDownEvent(_ event: NSEvent) {
        guard !event.isARepeat else { return }
        guard matchingNonModifierHotkey(for: event.keyCode) != nil else { return }
        processKeyPress(isKeyPressed: true)
    }

    private func handleKeyUpEvent(_ event: NSEvent) {
        guard matchingNonModifierHotkey(for: event.keyCode) != nil else { return }
        processKeyPress(isKeyPressed: false)
    }

    private func matchingModifierHotkey(for keyCode: UInt16) -> SingleKeyShortcut? {
        if let h1 = hotkey1, h1.isModifier, h1.allKeyCodes.contains(keyCode) { return h1 }
        if let h2 = hotkey2, h2.isModifier, h2.allKeyCodes.contains(keyCode) { return h2 }
        return nil
    }

    private func matchingNonModifierHotkey(for keyCode: UInt16) -> SingleKeyShortcut? {
        if let h1 = hotkey1, !h1.isModifier, h1.keyCode == keyCode { return h1 }
        if let h2 = hotkey2, !h2.isModifier, h2.keyCode == keyCode { return h2 }
        return nil
    }

    // MARK: - Press Processing (unchanged logic)

    private func processKeyPress(isKeyPressed: Bool) {
        guard isKeyPressed != currentKeyState else { return }
        currentKeyState = isKeyPressed

        if isKeyPressed {
            keyPressStartTime = Date()

            if isHandsFreeMode {
                isHandsFreeMode = false
                Task { @MainActor in
                    guard canProcessHotkeyAction else { return }
                    await whisperState.handleToggleMiniRecorder()
                }
                return
            }

            if !whisperState.isMiniRecorderVisible {
                Task { @MainActor in
                    guard canProcessHotkeyAction else { return }
                    await whisperState.handleToggleMiniRecorder()
                }
            }
        } else {
            let now = Date()

            if let startTime = keyPressStartTime {
                let pressDuration = now.timeIntervalSince(startTime)

                if pressDuration < briefPressThreshold {
                    isHandsFreeMode = true
                } else {
                    Task { @MainActor in
                        guard canProcessHotkeyAction else { return }
                        await whisperState.handleToggleMiniRecorder()
                    }
                }
            }

            keyPressStartTime = nil
        }
    }

    // MARK: - Cleanup

    private func removeAllMonitoring() {
        for monitor in [globalFlagsMonitor, localFlagsMonitor, globalKeyDownMonitor, globalKeyUpMonitor, localKeyDownMonitor].compactMap({ $0 }) {
            NSEvent.removeMonitor(monitor)
        }
        globalFlagsMonitor = nil
        localFlagsMonitor = nil
        globalKeyDownMonitor = nil
        globalKeyUpMonitor = nil
        localKeyDownMonitor = nil

        for monitor in middleClickMonitors.compactMap({ $0 }) {
            NSEvent.removeMonitor(monitor)
        }
        middleClickMonitors = []
        middleClickTask?.cancel()

        resetKeyStates()
    }

    private func resetKeyStates() {
        currentKeyState = false
        keyPressStartTime = nil
        isHandsFreeMode = false
    }

    deinit {
        Task { @MainActor in
            removeAllMonitoring()
        }
    }
}
