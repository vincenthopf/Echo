import SwiftUI
import AVFoundation
import AppKit
import KeyboardShortcuts

struct MetricsSetupView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var menuBarManager: MenuBarManager

    @State private var setupReadiness = SetupReadiness(
        microphone: .incomplete,
        hotkey: .incomplete,
        defaultModel: .incomplete,
        accessibility: .incomplete,
        screenRecording: .incomplete
    )
    @State private var pollingAccessibility = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Finish Setup")
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    Text("Required items unlock transcription. Recommended items improve the experience.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                VStack(spacing: 0) {
                    readinessRow(title: "Microphone Access", description: "Required", completed: setupReadiness.microphone == .complete)
                    Divider().padding(.leading, 70)
                    readinessRow(title: "Keyboard Shortcut", description: "Required", completed: setupReadiness.hotkey == .complete)
                    Divider().padding(.leading, 70)
                    readinessRow(title: "Installed Default Model", description: "Required", completed: setupReadiness.defaultModel == .complete)
                    Divider().padding(.leading, 70)
                    readinessRow(title: "Accessibility", description: "Recommended", completed: setupReadiness.accessibility == .complete)
                    Divider().padding(.leading, 70)
                    readinessRow(title: "Screen Recording", description: "Recommended", completed: setupReadiness.screenRecording == .complete)
                }
                .background(Color(NSColor.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)

                Button(action: handleActionButton) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 420)

                Text("You can enable recommended permissions later from Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 600)
        .background(Color(NSColor.controlBackgroundColor))
        .task(priority: .userInitiated) {
            refreshReadiness()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshReadiness()
        }
        .onReceive(NotificationCenter.default.publisher(for: .didChangeModel)) { _ in
            refreshReadiness()
        }
        .task(id: pollingAccessibility) {
            guard pollingAccessibility else { return }
            while !Task.isCancelled {
                if AXIsProcessTrusted() {
                    pollingAccessibility = false
                    refreshReadiness()
                    return
                }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }

    private func readinessRow(title: String, description: String, completed: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(completed ? .green : .secondary)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    private var actionTitle: String {
        if setupReadiness.microphone != .complete {
            return "Enable Microphone"
        }
        if setupReadiness.hotkey != .complete {
            return "Configure Shortcut"
        }
        if setupReadiness.defaultModel != .complete {
            return "Download or Select Model"
        }
        if setupReadiness.accessibility != .complete {
            return "Enable Accessibility (Recommended)"
        }
        if setupReadiness.screenRecording != .complete {
            return "Enable Screen Recording (Recommended)"
        }
        return "Setup Complete"
    }

    private func handleActionButton() {
        if setupReadiness.microphone != .complete {
            AVCaptureDevice.requestAccess(for: .audio) { _ in
                DispatchQueue.main.async { refreshReadiness() }
            }
            return
        }

        if setupReadiness.hotkey != .complete {
            openSettingsWindow()
            return
        }

        if setupReadiness.defaultModel != .complete {
            openModelManagement()
            return
        }

        if setupReadiness.accessibility != .complete {
            // Open System Settings directly — avoid AXIsProcessTrustedWithOptions(prompt: true)
            // which can reset/toggle the permission if the app is already in the TCC list
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
            pollingAccessibility = true
            return
        }

        if setupReadiness.screenRecording != .complete {
            CGRequestScreenCaptureAccess()
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func refreshReadiness() {
        setupReadiness = SetupReadinessEvaluator.current(
            whisperState: whisperState,
            hotkeyManager: hotkeyManager
        )
    }

    private func openSettingsWindow() {
        menuBarManager.navigateTo(.settings)
    }

    private func openModelManagement() {
        UserDefaults.standard.set(SettingsTab.transcription.rawValue, forKey: "selectedSettingsTab")
        menuBarManager.navigateTo(.settings)
    }
}
