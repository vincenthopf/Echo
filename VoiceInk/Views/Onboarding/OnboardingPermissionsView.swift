import SwiftUI
import AVFoundation
import AppKit
import KeyboardShortcuts

struct OnboardingPermissionsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @ObservedObject private var audioDeviceManager = AudioDeviceManager.shared

    @State private var microphoneGranted = false
    @State private var audioDeviceConfigured = false
    @State private var shortcutConfigured = false
    @State private var accessibilityGranted = false
    @State private var screenRecordingGranted = false
    @State private var pollingPermission: PollingPermission?
    @State private var showModelSelection = false
    @State private var showIntelGuidance = false
    private let launchArguments = ProcessInfo.processInfo.arguments

    private enum PollingPermission: Hashable {
        case accessibility
        case screenRecording
    }

    private var requiredComplete: Bool {
        microphoneGranted && audioDeviceConfigured && shortcutConfigured
    }

    var body: some View {
        ZStack {
            OnboardingBackgroundView()

            VStack(spacing: 24) {
                Text("Start Quick Setup")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Text("Complete required items now. Recommended items can be done later in Settings.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    microphoneRow
                    audioDeviceRow
                    shortcutRow
                    accessibilityRow
                    screenRecordingRow
                }
                .frame(maxWidth: 720)

                HStack(spacing: 14) {
                    Button(action: continueToModelSelection) {
                        Text(requiredComplete ? "Continue" : "Complete Required Items")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 280, height: 48)
                            .background(Color.accentColor)
                            .cornerRadius(24)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(!requiredComplete)
                    .accessibilityIdentifier("onboarding.quickSetup.continue")

                    SkipButton(text: "Skip onboarding", colorScheme: colorScheme) {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .padding(32)

            if showModelSelection {
                OnboardingModelSelectionView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            if showIntelGuidance {
                OnboardingIntelMacGuidanceView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .task(priority: .userInitiated) {
            audioDeviceManager.loadAvailableDevices()
            refreshPermissionStates()
            applyUITestOverridesIfNeeded()
        }
        .task(id: pollingPermission, priority: .userInitiated) {
            await pollIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            // Re-check permissions when user switches back from System Settings
            refreshPermissionStates()
        }
        .onChange(of: hotkeyManager.selectedHotkey1) { _, newValue in
            shortcutConfigured = newValue != .none
        }
    }

    private var microphoneRow: some View {
        checklistRow(
            icon: "mic.fill",
            title: "Microphone Access",
            subtitle: "Required",
            description: "Required to record your voice.",
            isComplete: microphoneGranted,
            content: {
                Button(action: requestMicrophone) {
                    Text(microphoneGranted ? "Enabled" : "Enable")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        )
        .accessibilityIdentifier("onboarding.checklist.microphone")
    }

    private var audioDeviceRow: some View {
        checklistRow(
            icon: "headphones",
            title: "Microphone Selection",
            subtitle: "Required",
            description: "Choose the input Echo should use.",
            isComplete: audioDeviceConfigured,
            content: {
                Picker("", selection: selectedAudioBinding) {
                    Text("System Default").tag(AudioDeviceID(0))
                    ForEach(audioDeviceManager.availableDevices, id: \.id) { device in
                        Text(device.name).tag(device.id)
                    }
                }
                .labelsHidden()
                .frame(width: 220)
            }
        )
        .accessibilityIdentifier("onboarding.checklist.audioDevice")
    }

    private var shortcutRow: some View {
        checklistRow(
            icon: "keyboard",
            title: "Keyboard Shortcut",
            subtitle: "Required",
            description: "Required to trigger recording quickly.",
            isComplete: shortcutConfigured,
            content: {
                KeyboardShortcuts.Recorder(for: .toggleMiniRecorder)
                    .frame(width: 220)
            }
        )
        .accessibilityIdentifier("onboarding.checklist.keyboardShortcut")
    }

    private var accessibilityRow: some View {
        checklistRow(
            icon: "accessibility",
            title: "Accessibility Access",
            subtitle: "Recommended",
            description: "Recommended for auto-paste. Without it, Echo copies transcripts to clipboard.",
            isComplete: accessibilityGranted,
            content: {
                Button(action: requestAccessibility) {
                    Text(accessibilityGranted ? "Enabled" : "Enable")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        )
        .accessibilityIdentifier("onboarding.checklist.accessibility")
    }

    private var screenRecordingRow: some View {
        checklistRow(
            icon: "rectangle.inset.filled.and.person.filled",
            title: "Screen Recording",
            subtitle: "Recommended",
            description: "Recommended for better context awareness.",
            isComplete: screenRecordingGranted,
            content: {
                Button(action: requestScreenRecording) {
                    Text(screenRecordingGranted ? "Enabled" : "Enable")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        )
        .accessibilityIdentifier("onboarding.checklist.screenRecording")
    }

    private var selectedAudioBinding: Binding<AudioDeviceID> {
        Binding(
            get: { audioDeviceManager.selectedDeviceID ?? AudioDeviceID(0) },
            set: { newValue in
                if newValue == AudioDeviceID(0) {
                    audioDeviceManager.selectInputMode(.systemDefault)
                } else {
                    audioDeviceManager.selectDevice(id: newValue)
                    audioDeviceManager.selectInputMode(.custom)
                }
                audioDeviceConfigured = true
            }
        )
    }

    private func checklistRow<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        description: String,
        isComplete: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36)
                .foregroundColor(.orange)
                .background(Tokens.Colors.orangeSoft(for: colorScheme))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                Text(subtitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }

            Spacer()
            content()

            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : Tokens.Colors.textTertiary(for: colorScheme))
                .font(.system(size: 18, weight: .semibold))
        }
        .padding(14)
        .background(Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func refreshPermissionStates() {
        microphoneGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        audioDeviceConfigured = audioDeviceManager.inputMode == .systemDefault || audioDeviceManager.selectedDeviceID != nil
        shortcutConfigured = hotkeyManager.selectedHotkey1 != .none
        accessibilityGranted = AXIsProcessTrusted()
        screenRecordingGranted = CGPreflightScreenCaptureAccess()
    }

    private func applyUITestOverridesIfNeeded() {
        guard launchArguments.contains("-uiTestMode") else { return }

        if launchArguments.contains("-uiTestChecklistRequiredComplete") {
            microphoneGranted = true
            audioDeviceConfigured = true
            shortcutConfigured = true
        }

        if launchArguments.contains("-uiTestChecklistOptionalIncomplete") {
            accessibilityGranted = false
            screenRecordingGranted = false
            pollingPermission = nil
        }
    }

    private func requestMicrophone() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                microphoneGranted = granted
            }
        }
    }

    private func requestAccessibility() {
        // Always check current state first to avoid re-prompting when already granted
        if AXIsProcessTrusted() {
            accessibilityGranted = true
            pollingPermission = nil
            return
        }
        // Open System Settings directly — avoid AXIsProcessTrustedWithOptions(prompt: true)
        // which can reset/toggle the permission if the app is already in the TCC list
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
        pollingPermission = .accessibility
    }

    private func requestScreenRecording() {
        // Always check current state first
        if CGPreflightScreenCaptureAccess() {
            screenRecordingGranted = true
            pollingPermission = nil
            return
        }
        // Open System Settings directly for screen recording
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
        pollingPermission = .screenRecording
    }

    private func pollIfNeeded() async {
        guard let pollingPermission else { return }

        while !Task.isCancelled {
            switch pollingPermission {
            case .accessibility:
                if AXIsProcessTrusted() {
                    accessibilityGranted = true
                    self.pollingPermission = nil
                    return
                }
            case .screenRecording:
                if CGPreflightScreenCaptureAccess() {
                    screenRecordingGranted = true
                    self.pollingPermission = nil
                    return
                }
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }

    private func continueToModelSelection() {
        guard requiredComplete else { return }
        withAnimation {
            if launchArguments.contains("-uiTestForceModelSelection") {
                showModelSelection = true
                return
            }
            if SystemInfoService.isIntelMac() {
                showIntelGuidance = true
            } else {
                showModelSelection = true
            }
        }
    }
}
