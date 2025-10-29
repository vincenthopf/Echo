import SwiftUI
import Cocoa
import KeyboardShortcuts
import AVFoundation

/// Recording settings including shortcuts, audio input, and audio management
struct RecordingSettingsView: View {
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @StateObject private var deviceManager = AudioDeviceManager.shared
    @ObservedObject private var mediaController = MediaController.shared
    @State private var isCustomCancelEnabled = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Embr Echo Shortcuts Section
                SettingsSection(
                    icon: "command.circle",
                    title: "Embr Echo Shortcuts",
                    subtitle: "Choose how you want to trigger Embr Echo"
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        hotkeyView(
                            title: "Hotkey 1",
                            binding: $hotkeyManager.selectedHotkey1,
                            shortcutName: .toggleMiniRecorder
                        )

                        if hotkeyManager.selectedHotkey2 != .none {
                            Divider()
                            hotkeyView(
                                title: "Hotkey 2",
                                binding: $hotkeyManager.selectedHotkey2,
                                shortcutName: .toggleMiniRecorder2,
                                isRemovable: true,
                                onRemove: {
                                    withAnimation { hotkeyManager.selectedHotkey2 = .none }
                                }
                            )
                        }

                        if hotkeyManager.selectedHotkey1 != .none && hotkeyManager.selectedHotkey2 == .none {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation { hotkeyManager.selectedHotkey2 = .rightOption }
                                }) {
                                    Label("Add another hotkey", systemImage: "plus.circle.fill")
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.accentColor)
                            }
                        }

                        Text("Quick tap to start hands-free recording (tap again to stop). Press and hold for push-to-talk (release to stop recording).")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // MARK: - Other App Shortcuts Section
                SettingsSection(
                    icon: "keyboard.badge.ellipsis",
                    title: "Other App Shortcuts",
                    subtitle: "Additional shortcuts for Embr Echo"
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Paste Last Transcript (Original)
                        HStack(spacing: 12) {
                            Text("Paste Last Transcript(Original)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            KeyboardShortcuts.Recorder(for: .pasteLastTranscription)
                                .controlSize(.small)

                            InfoTip(
                                title: "Paste Last Transcript(Original)",
                                message: "Shortcut for pasting the most recent transcription."
                            )

                            Spacer()
                        }

                        // Paste Last Transcript (Transformed)
                        HStack(spacing: 12) {
                            Text("Paste Last Transcript(Transformed)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            KeyboardShortcuts.Recorder(for: .pasteLastEnhancement)
                                .controlSize(.small)

                            InfoTip(
                                title: "Paste Last Transcript(Transformed)",
                                message: "Pastes the transformed transcript if available, otherwise falls back to the original."
                            )

                            Spacer()
                        }

                        // Retry Last Transcription
                        HStack(spacing: 12) {
                            Text("Retry Last Transcription")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            KeyboardShortcuts.Recorder(for: .retryLastTranscription)
                                .controlSize(.small)

                            InfoTip(
                                title: "Retry Last Transcription",
                                message: "Re-transcribe the last recorded audio using the current model and copy the result."
                            )

                            Spacer()
                        }

                        Divider()

                        // Custom Cancel Shortcut
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Toggle(isOn: $isCustomCancelEnabled.animation()) {
                                    Text("Custom Cancel Shortcut")
                                }
                                .toggleStyle(.switch)
                                .onChange(of: isCustomCancelEnabled) { _, newValue in
                                    if !newValue {
                                        KeyboardShortcuts.setShortcut(nil, for: .cancelRecorder)
                                    }
                                }

                                InfoTip(
                                    title: "Dismiss Recording",
                                    message: "Shortcut for cancelling the current recording session. Default: double-tap Escape."
                                )
                            }

                            if isCustomCancelEnabled {
                                HStack(spacing: 12) {
                                    Text("Cancel Shortcut")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)

                                    KeyboardShortcuts.Recorder(for: .cancelRecorder)
                                        .controlSize(.small)

                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        Divider()

                        // Mouse Activation
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Toggle("Enable Mouse Activation", isOn: $hotkeyManager.isMiddleClickToggleEnabled.animation())
                                    .toggleStyle(.switch)

                                InfoTip(
                                    title: "Mouse Activation",
                                    message: "Use middle mouse button to toggle Embr Echo recording."
                                )
                            }

                            if hotkeyManager.isMiddleClickToggleEnabled {
                                HStack(spacing: 8) {
                                    Text("Activation Delay")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)

                                    TextField("", value: $hotkeyManager.middleClickActivationDelay, formatter: {
                                        let formatter = NumberFormatter()
                                        formatter.numberStyle = .none
                                        formatter.minimum = 0
                                        return formatter
                                    }())
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                                    .background(Color(NSColor.textBackgroundColor))
                                    .cornerRadius(5)
                                    .frame(width: 70)

                                    Text("ms")
                                        .foregroundColor(.secondary)

                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                }

                // MARK: - Audio Input Section
                SettingsSection(
                    icon: "mic.fill",
                    title: "Audio Input",
                    subtitle: "Select your microphone"
                ) {
                    audioInputContent
                }

                // MARK: - Audio Management Section
                SettingsSection(
                    icon: "speaker.wave.2.bubble.left.fill",
                    title: "Audio Management",
                    subtitle: "Customize app & system feedback"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: .init(
                            get: { SoundManager.shared.isEnabled },
                            set: { SoundManager.shared.isEnabled = $0 }
                        )) {
                            Text("Sound feedback")
                        }
                        .toggleStyle(.switch)

                        Toggle(isOn: $mediaController.isSystemMuteEnabled) {
                            Text("Mute system audio during recording")
                        }
                        .toggleStyle(.switch)
                        .help("Automatically mute system audio when recording starts and restore when recording stops")

                        Toggle(isOn: Binding(
                            get: { UserDefaults.standard.bool(forKey: "preserveTranscriptInClipboard") },
                            set: { UserDefaults.standard.set($0, forKey: "preserveTranscriptInClipboard") }
                        )) {
                            Text("Preserve transcript in clipboard")
                        }
                        .toggleStyle(.switch)
                        .help("Keep the transcribed text in clipboard instead of restoring the original clipboard content")
                    }
                }

                // MARK: - Paste Method Section
                SettingsSection(
                    icon: "doc.on.clipboard",
                    title: "Paste Method",
                    subtitle: "Choose how text is pasted"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select the method used to paste text. Use AppleScript if you have a non-standard keyboard layout.")
                            .settingsDescription()

                        Toggle("Use AppleScript Paste Method", isOn: Binding(
                            get: { UserDefaults.standard.bool(forKey: "UseAppleScriptPaste") },
                            set: { UserDefaults.standard.set($0, forKey: "UseAppleScriptPaste") }
                        ))
                        .toggleStyle(.switch)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            isCustomCancelEnabled = KeyboardShortcuts.getShortcut(for: .cancelRecorder) != nil
        }
    }

    // MARK: - Audio Input Content
    private var audioInputContent: some View {
        VStack(spacing: 20) {
            inputModeSection

            if deviceManager.inputMode == .custom {
                customDeviceSection
            } else if deviceManager.inputMode == .prioritized {
                prioritizedDevicesSection
            }
        }
    }

    private var inputModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                ForEach(AudioInputMode.allCases, id: \.self) { mode in
                    InputModeCard(
                        mode: mode,
                        isSelected: deviceManager.inputMode == mode,
                        action: { deviceManager.selectInputMode(mode) }
                    )
                }
            }
        }
    }

    private var customDeviceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Available Devices")
                    .font(.headline)

                Spacer()

                Button(action: { deviceManager.loadAvailableDevices() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
            }

            Text("Note: Selecting a device here will override your Mac's system-wide default microphone.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)

            VStack(spacing: 12) {
                ForEach(deviceManager.availableDevices, id: \.id) { device in
                    DeviceSelectionCard(
                        name: device.name,
                        isSelected: deviceManager.selectedDeviceID == device.id,
                        isActive: deviceManager.getCurrentDevice() == device.id
                    ) {
                        deviceManager.selectDevice(id: device.id)
                    }
                }
            }
        }
    }

    private var prioritizedDevicesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if deviceManager.availableDevices.isEmpty {
                emptyDevicesState
            } else {
                prioritizedDevicesContent
                Divider().padding(.vertical, 8)
                availableDevicesContent
            }
        }
    }

    private var prioritizedDevicesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Prioritized Devices")
                    .font(.headline)
                Text("Devices will be used in order of priority. If a device is unavailable, the next one will be tried. If no prioritized device is available, the system default microphone will be used.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Warning: Using a prioritized device will override your Mac's system-wide default microphone if it becomes active.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            if deviceManager.prioritizedDevices.isEmpty {
                Text("No prioritized devices")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                prioritizedDevicesList
            }
        }
    }

    private var availableDevicesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Devices")
                .font(.headline)

            availableDevicesList
        }
    }

    private var emptyDevicesState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash.circle.fill")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Audio Devices")
                    .font(.headline)
                Text("Connect an audio input device to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(CardBackground(isSelected: false))
    }

    private var prioritizedDevicesList: some View {
        VStack(spacing: 12) {
            ForEach(deviceManager.prioritizedDevices.sorted(by: { $0.priority < $1.priority })) { device in
                devicePriorityCard(for: device)
            }
        }
    }

    private func devicePriorityCard(for prioritizedDevice: PrioritizedDevice) -> some View {
        let device = deviceManager.availableDevices.first(where: { $0.uid == prioritizedDevice.id })
        return DevicePriorityCard(
            name: prioritizedDevice.name,
            priority: prioritizedDevice.priority,
            isActive: device.map { deviceManager.getCurrentDevice() == $0.id } ?? false,
            isPrioritized: true,
            isAvailable: device != nil,
            canMoveUp: prioritizedDevice.priority > 0,
            canMoveDown: prioritizedDevice.priority < deviceManager.prioritizedDevices.count - 1,
            onTogglePriority: { deviceManager.removePrioritizedDevice(id: prioritizedDevice.id) },
            onMoveUp: { moveDeviceUp(prioritizedDevice) },
            onMoveDown: { moveDeviceDown(prioritizedDevice) }
        )
    }

    private var availableDevicesList: some View {
        let unprioritizedDevices = deviceManager.availableDevices.filter { device in
            !deviceManager.prioritizedDevices.contains { $0.id == device.uid }
        }

        return Group {
            if unprioritizedDevices.isEmpty {
                Text("No additional devices available")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(unprioritizedDevices, id: \.id) { device in
                    DevicePriorityCard(
                        name: device.name,
                        priority: nil,
                        isActive: deviceManager.getCurrentDevice() == device.id,
                        isPrioritized: false,
                        isAvailable: true,
                        canMoveUp: false,
                        canMoveDown: false,
                        onTogglePriority: { deviceManager.addPrioritizedDevice(uid: device.uid, name: device.name) },
                        onMoveUp: {},
                        onMoveDown: {}
                    )
                }
            }
        }
    }

    private func moveDeviceUp(_ device: PrioritizedDevice) {
        guard device.priority > 0,
              let currentIndex = deviceManager.prioritizedDevices.firstIndex(where: { $0.id == device.id })
        else { return }

        var devices = deviceManager.prioritizedDevices
        devices.swapAt(currentIndex, currentIndex - 1)
        updatePriorities(devices)
    }

    private func moveDeviceDown(_ device: PrioritizedDevice) {
        guard device.priority < deviceManager.prioritizedDevices.count - 1,
              let currentIndex = deviceManager.prioritizedDevices.firstIndex(where: { $0.id == device.id })
        else { return }

        var devices = deviceManager.prioritizedDevices
        devices.swapAt(currentIndex, currentIndex + 1)
        updatePriorities(devices)
    }

    private func updatePriorities(_ devices: [PrioritizedDevice]) {
        let updatedDevices = devices.enumerated().map { index, device in
            PrioritizedDevice(id: device.id, name: device.name, priority: index)
        }
        deviceManager.updatePriorities(devices: updatedDevices)
    }

    // MARK: - Hotkey View Builder
    @ViewBuilder
    private func hotkeyView(
        title: String,
        binding: Binding<HotkeyManager.HotkeyOption>,
        shortcutName: KeyboardShortcuts.Name,
        isRemovable: Bool = false,
        onRemove: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            Menu {
                ForEach(HotkeyManager.HotkeyOption.allCases, id: \.self) { option in
                    Button(action: {
                        binding.wrappedValue = option
                    }) {
                        HStack {
                            Text(option.displayName)
                            if binding.wrappedValue == option {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(binding.wrappedValue.displayName)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)

            if binding.wrappedValue == .custom {
                KeyboardShortcuts.Recorder(for: shortcutName)
                    .controlSize(.small)
            }

            Spacer()

            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
