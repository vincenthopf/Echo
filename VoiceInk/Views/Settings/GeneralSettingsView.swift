import SwiftUI
import Cocoa
import KeyboardShortcuts
import LaunchAtLogin
import AVFoundation

/// General application settings including shortcuts, feedback, and preferences
struct GeneralSettingsView: View {
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var menuBarManager: MenuBarManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @StateObject private var deviceManager = AudioDeviceManager.shared
    @ObservedObject private var mediaController = MediaController.shared
    @ObservedObject private var playbackController = PlaybackController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("autoUpdateCheck") private var autoUpdateCheck = true
    @AppStorage("enableAnnouncements") private var enableAnnouncements = true
    @State private var showResetOnboardingAlert = false
    @State private var currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
    @State private var isCustomCancelEnabled = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsSection(
                    icon: "command.circle",
                    title: "Embr Voice Shortcuts",
                    subtitle: "Choose how you want to trigger Embr Voice"
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

                SettingsSection(
                    icon: "keyboard.badge.ellipsis",
                    title: "Other App Shortcuts",
                    subtitle: "Additional shortcuts for Embr Voice"
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

                        // Paste Last Transcript (Enhanced)
                        HStack(spacing: 12) {
                            Text("Paste Last Transcript(Enhanced)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            KeyboardShortcuts.Recorder(for: .pasteLastEnhancement)
                                .controlSize(.small)

                            InfoTip(
                                title: "Paste Last Transcript(Enhanced)",
                                message: "Pastes the enhanced transcript if available, otherwise falls back to the original."
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

                        // Middle-Click Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Toggle("Enable Middle-Click Toggle", isOn: $hotkeyManager.isMiddleClickToggleEnabled.animation())
                                    .toggleStyle(.switch)

                                InfoTip(
                                    title: "Middle-Click Toggle",
                                    message: "Use middle mouse button to toggle Embr Voice recording."
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

                SettingsSection(
                    icon: "speaker.wave.2.bubble.left.fill",
                    title: "Recording Feedback",
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

                PowerModeSettingsSection()

                ExperimentalFeaturesSection()

                SettingsSection(
                    icon: "rectangle.on.rectangle",
                    title: "Recorder Style",
                    subtitle: "Choose your preferred recorder interface"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select how you want the recorder to appear on your screen.")
                            .settingsDescription()

                        Picker("Recorder Style", selection: $whisperState.recorderType) {
                            Text("Notch Recorder").tag("notch")
                            Text("Mini Recorder").tag("mini")
                        }
                        .pickerStyle(.radioGroup)
                        .padding(.vertical, 4)
                    }
                }

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

                SettingsSection(
                    icon: "gear",
                    title: "General",
                    subtitle: "Appearance, startup, and updates"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Hide Dock Icon (Menu Bar Only)", isOn: $menuBarManager.isMenuBarOnly)
                            .toggleStyle(.switch)

                        LaunchAtLogin.Toggle()
                            .toggleStyle(.switch)

                        Toggle("Enable automatic update checks", isOn: $autoUpdateCheck)
                            .toggleStyle(.switch)
                            .onChange(of: autoUpdateCheck) { _, newValue in
                                updaterViewModel.toggleAutoUpdates(newValue)
                            }

                        Toggle("Show app announcements", isOn: $enableAnnouncements)
                            .toggleStyle(.switch)
                            .onChange(of: enableAnnouncements) { _, newValue in
                                if newValue {
                                    AnnouncementsService.shared.start()
                                } else {
                                    AnnouncementsService.shared.stop()
                                }
                            }

                        Button("Check for Updates Now") {
                            updaterViewModel.checkForUpdates()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(!updaterViewModel.canCheckForUpdates)

                        Divider()

                        Button("Reset Onboarding") {
                            showResetOnboardingAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }

                SettingsSection(
                    icon: "lock.shield",
                    title: "Data & Privacy",
                    subtitle: "Control transcript history and storage"
                ) {
                    AudioCleanupSettingsView()
                }

                SettingsSection(
                    icon: "arrow.up.arrow.down.circle",
                    title: "Data Management",
                    subtitle: "Import or export your settings"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export your custom prompts, power modes, word replacements, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export.")
                            .settingsDescription()

                        HStack(spacing: 12) {
                            Button {
                                ImportExportService.shared.importSettings(
                                    enhancementService: enhancementService,
                                    whisperPrompt: whisperState.whisperPrompt,
                                    hotkeyManager: hotkeyManager,
                                    menuBarManager: menuBarManager,
                                    mediaController: MediaController.shared,
                                    playbackController: PlaybackController.shared,
                                    soundManager: SoundManager.shared,
                                    whisperState: whisperState
                                )
                            } label: {
                                Label("Import Settings...", systemImage: "arrow.down.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)

                            Button {
                                ImportExportService.shared.exportSettings(
                                    enhancementService: enhancementService,
                                    whisperPrompt: whisperState.whisperPrompt,
                                    hotkeyManager: hotkeyManager,
                                    menuBarManager: menuBarManager,
                                    mediaController: MediaController.shared,
                                    playbackController: PlaybackController.shared,
                                    soundManager: SoundManager.shared,
                                    whisperState: whisperState
                                )
                            } label: {
                                Label("Export Settings...", systemImage: "arrow.up.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)
                        }
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
        .alert("Reset Onboarding", isPresented: $showResetOnboardingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                // Defer state change to avoid layout issues while alert dismisses
                DispatchQueue.main.async {
                    hasCompletedOnboarding = false
                }
            }
        } message: {
            Text("Are you sure you want to reset the onboarding? You'll see the introduction screens again the next time you launch the app.")
        }
    }

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
