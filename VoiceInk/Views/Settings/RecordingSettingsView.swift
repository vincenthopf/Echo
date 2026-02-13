import SwiftUI
import Cocoa
import KeyboardShortcuts
import AVFoundation

/// Recording settings including shortcuts, audio input, and audio management
struct RecordingSettingsView: View {
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @StateObject private var deviceManager = AudioDeviceManager.shared

    @State private var isCustomCancelEnabled = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: Tokens.Spacing.xl) {
                // MARK: - Echo Shortcuts Section
                echoShortcutsSection

                // MARK: - Other App Shortcuts Section
                otherShortcutsSection

                // MARK: - Audio Input Section
                audioInputSection

                // MARK: - Audio Management Section
                audioManagementSection
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.vertical, Tokens.Spacing.sm)
        }
        .background(Tokens.Colors.background(for: colorScheme))
        .onAppear {
            isCustomCancelEnabled = KeyboardShortcuts.getShortcut(for: .cancelRecorder) != nil
        }
    }

    // MARK: - Echo Shortcuts Section

    private var echoShortcutsSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Echo Shortcuts",
                subtitle: "Choose how you want to trigger Echo"
            )

            VStack(spacing: 0) {
                // Hotkey 1
                FormRow(label: "Hotkey 1") {
                    hotkeyContent(
                        binding: $hotkeyManager.selectedHotkey1,
                        shortcutName: .toggleMiniRecorder
                    )
                }

                if hotkeyManager.selectedHotkey2 != .none {
                    FormDivider()

                    FormRow(label: "Hotkey 2") {
                        HStack(spacing: Tokens.Spacing.md) {
                            hotkeyContent(
                                binding: $hotkeyManager.selectedHotkey2,
                                shortcutName: .toggleMiniRecorder2
                            )

                            Button(action: {
                                withAnimation { hotkeyManager.selectedHotkey2 = .none }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(Tokens.Colors.error)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if hotkeyManager.selectedHotkey1 != .none && hotkeyManager.selectedHotkey2 == .none {
                    FormDivider()

                    FormRow(label: "") {
                        Button(action: {
                            withAnimation { hotkeyManager.selectedHotkey2 = .rightOption }
                        }) {
                            Label("Add another hotkey", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(Tokens.Colors.orange)
                    }
                }

                FormDivider()

                // Help text row
                VStack(alignment: .leading, spacing: 0) {
                    Text("Quick tap to start hands-free recording (tap again to stop). Press and hold for push-to-talk (release to stop recording).")
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, Tokens.Spacing.lg)
                        .padding(.vertical, 14)
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Other Shortcuts Section

    private var otherShortcutsSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Other App Shortcuts",
                subtitle: "Additional shortcuts for Echo"
            )

            VStack(spacing: 0) {
                // Paste Last Transcript (Original)
                FormRow(label: "Paste Original") {
                    shortcutContent(
                        shortcutName: .pasteLastTranscription,
                        tipTitle: "Paste Last Transcript(Original)",
                        tipMessage: "Shortcut for pasting the most recent transcription."
                    )
                }

                FormDivider()

                // Paste Last Transcript (Transformed)
                FormRow(label: "Paste Transformed") {
                    shortcutContent(
                        shortcutName: .pasteLastEnhancement,
                        tipTitle: "Paste Last Transcript(Transformed)",
                        tipMessage: "Pastes the transformed transcript if available, otherwise falls back to the original."
                    )
                }

                FormDivider()

                // Retry Last Transcription
                FormRow(label: "Retry") {
                    shortcutContent(
                        shortcutName: .retryLastTranscription,
                        tipTitle: "Retry Last Transcription",
                        tipMessage: "Re-transcribe the last recorded audio using the current model and copy the result."
                    )
                }

                FormDivider()

                // Custom Cancel Shortcut
                FormRow(label: "Cancel") {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Toggle("", isOn: $isCustomCancelEnabled.animation())
                                .toggleStyle(.switch)
                                .tint(Tokens.Colors.orange)
                                .labelsHidden()
                                .onChange(of: isCustomCancelEnabled) { _, newValue in
                                    if !newValue {
                                        KeyboardShortcuts.setShortcut(nil, for: .cancelRecorder)
                                    }
                                }

                            Text("Custom Cancel Shortcut")
                                .font(Tokens.Typography.body)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            InfoTip(
                                title: "Dismiss Recording",
                                message: "Shortcut for cancelling the current recording session. Default: double-tap Escape."
                            )

                            Spacer()
                        }

                        if isCustomCancelEnabled {
                            HStack(spacing: Tokens.Spacing.md) {
                                Text("Cancel Shortcut")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                                KeyboardShortcuts.Recorder(for: .cancelRecorder)
                                    .controlSize(.small)

                                Spacer()
                            }
                            .padding(.leading, Tokens.Spacing.lg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }

                FormDivider()

                // Mouse Activation
                FormRow(label: "Mouse") {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Toggle("", isOn: $hotkeyManager.isMiddleClickToggleEnabled.animation())
                                .toggleStyle(.switch)
                                .tint(Tokens.Colors.orange)
                                .labelsHidden()

                            Text("Enable Mouse Activation")
                                .font(Tokens.Typography.body)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            InfoTip(
                                title: "Mouse Activation",
                                message: "Use middle mouse button to toggle Echo recording."
                            )

                            Spacer()
                        }

                        if hotkeyManager.isMiddleClickToggleEnabled {
                            HStack(spacing: Tokens.Spacing.sm) {
                                Text("Activation Delay")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                                TextField("", value: $hotkeyManager.middleClickActivationDelay, formatter: {
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .none
                                    formatter.minimum = 0
                                    return formatter
                                }())
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                                .background(Tokens.Colors.background(for: colorScheme))
                                .cornerRadius(Tokens.Radius.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                                        .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                                )
                                .frame(width: 70)

                                Text("ms")
                                    .font(Tokens.Typography.bodySmall)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                                Spacer()
                            }
                            .padding(.leading, Tokens.Spacing.lg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Audio Input Section

    private var audioInputSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Audio Input",
                subtitle: "Select your microphone"
            )

            VStack(spacing: Tokens.Spacing.lg) {
                inputModeSection

                if deviceManager.inputMode == .custom {
                    customDeviceSection
                } else if deviceManager.inputMode == .prioritized {
                    prioritizedDevicesSection
                }
            }
            .padding(Tokens.Spacing.lg)
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Audio Management Section

    private var audioManagementSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Audio Management",
                subtitle: "Customize app & system feedback"
            )

            VStack(spacing: 0) {
                // Sound feedback
                FormRow(label: "Sound") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: .init(
                            get: { SoundManager.shared.isEnabled },
                            set: { SoundManager.shared.isEnabled = $0 }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Sound feedback")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Spacer()
                    }
                }

                FormDivider()

                // Microphone Sensitivity Slider
                FormRow(label: "Sensitivity") {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Text("Microphone Sensitivity")
                                .font(Tokens.Typography.body)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            InfoTip(
                                title: "Microphone Sensitivity",
                                message: "Adjust how sensitive the voice detection is. Higher values make it easier to trigger recording with quieter sounds, while lower values require louder input."
                            )

                            Spacer()
                        }

                        HStack(spacing: Tokens.Spacing.md) {
                            Text("Low")
                                .font(Tokens.Typography.caption)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                            Slider(
                                value: Binding(
                                    get: { UserDefaults.standard.double(forKey: "microphoneSensitivity") == 0 ? 0.5 : UserDefaults.standard.double(forKey: "microphoneSensitivity") },
                                    set: { UserDefaults.standard.set($0, forKey: "microphoneSensitivity") }
                                ),
                                in: 0.1...1.0,
                                step: 0.1
                            )
                            .tint(Tokens.Colors.orange)

                            Text("High")
                                .font(Tokens.Typography.caption)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                        }
                    }
                }

                FormDivider()

                // Universal Paste Compatibility
                FormRow(label: "Paste") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { UserDefaults.standard.bool(forKey: "UseAppleScriptPaste") },
                            set: { UserDefaults.standard.set($0, forKey: "UseAppleScriptPaste") }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Universal Paste Compatibility")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        InfoTip(
                            title: "Universal Paste Compatibility",
                            message: "Turn this on if you're using non-standard keyboard layouts (like AZERTY, Dvorak, or Colemak) or notice pasted text appearing incorrectly in certain apps.\n\nWhen to use:\n- You have a non-standard keyboard layout\n- Pasted text shows as \"pasted text\" instead of your actual transcription in tools like Claude AI\n- Text doesn't paste correctly in specific applications\n\nThis uses a different pasting method that works across more keyboard layouts and apps, though it may be slightly slower."
                        )

                        Spacer()
                    }
                }

            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Audio Input Content

    private var inputModeSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            HStack(spacing: Tokens.Spacing.lg) {
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
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            HStack {
                Text("Available Devices")
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Spacer()

                Button(action: { deviceManager.loadAvailableDevices() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .foregroundColor(Tokens.Colors.orange)
            }

            Text("Note: Selecting a device here will override your Mac's system-wide default microphone.")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .padding(.bottom, Tokens.Spacing.sm)

            VStack(spacing: Tokens.Spacing.md) {
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
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            if deviceManager.availableDevices.isEmpty {
                emptyDevicesState
            } else {
                prioritizedDevicesContent

                Rectangle()
                    .fill(Tokens.Colors.border(for: colorScheme))
                    .frame(height: 1)
                    .padding(.vertical, Tokens.Spacing.sm)

                availableDevicesContent
            }
        }
    }

    private var prioritizedDevicesContent: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                Text("Prioritized Devices")
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                Text("Devices will be used in order of priority. If a device is unavailable, the next one will be tried. If no prioritized device is available, the system default microphone will be used.")
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
                Text("Warning: Using a prioritized device will override your Mac's system-wide default microphone if it becomes active.")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .padding(.top, Tokens.Spacing.xs)
            }

            if deviceManager.prioritizedDevices.isEmpty {
                Text("No prioritized devices")
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .padding(.vertical, Tokens.Spacing.sm)
            } else {
                prioritizedDevicesList
            }
        }
    }

    private var availableDevicesContent: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text("Available Devices")
                .font(Tokens.Typography.heading3)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            availableDevicesList
        }
    }

    private var emptyDevicesState: some View {
        VStack(spacing: Tokens.Spacing.lg) {
            Image(systemName: "mic.slash.circle.fill")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Tokens.Colors.textSecondary(for: colorScheme))

            VStack(spacing: Tokens.Spacing.sm) {
                Text("No Audio Devices")
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                Text("Connect an audio input device to get started")
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Tokens.Colors.background(for: colorScheme))
        .cornerRadius(Tokens.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }

    private var prioritizedDevicesList: some View {
        VStack(spacing: Tokens.Spacing.md) {
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
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .padding(.vertical, Tokens.Spacing.sm)
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

    // MARK: - Helper Views

    @ViewBuilder
    private func shortcutContent(
        shortcutName: KeyboardShortcuts.Name,
        tipTitle: String,
        tipMessage: String
    ) -> some View {
        HStack(spacing: Tokens.Spacing.md) {
            KeyboardShortcuts.Recorder(for: shortcutName)
                .controlSize(.small)

            InfoTip(
                title: tipTitle,
                message: tipMessage
            )

            Spacer()
        }
    }

    @ViewBuilder
    private func hotkeyContent(
        binding: Binding<HotkeyManager.HotkeyOption>,
        shortcutName: KeyboardShortcuts.Name
    ) -> some View {
        HStack(spacing: Tokens.Spacing.md) {
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
                HStack(spacing: Tokens.Spacing.sm) {
                    Text(binding.wrappedValue.displayName)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                }
                .padding(.horizontal, Tokens.Spacing.md)
                .padding(.vertical, Tokens.Spacing.sm)
                .background(Tokens.Colors.background(for: colorScheme))
                .cornerRadius(Tokens.Radius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                        .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)

            if binding.wrappedValue == .custom {
                KeyboardShortcuts.Recorder(for: shortcutName)
                    .controlSize(.small)
            }

            Spacer()
        }
    }
}
