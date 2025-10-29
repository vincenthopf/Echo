import SwiftUI
import Cocoa
import LaunchAtLogin

/// General application settings including appearance, startup, and updates
struct GeneralSettingsView: View {
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var menuBarManager: MenuBarManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @ObservedObject private var mediaController = MediaController.shared
    @ObservedObject private var playbackController = PlaybackController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("autoUpdateCheck") private var autoUpdateCheck = true
    @AppStorage("enableAnnouncements") private var enableAnnouncements = true
    @State private var showResetOnboardingAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsSection(
                    icon: "gear",
                    title: "Appearance",
                    subtitle: "Customize how Echo appears"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Hide Dock Icon (Menu Bar Only)", isOn: $menuBarManager.isMenuBarOnly)
                            .toggleStyle(.switch)
                    }
                }

                SettingsSection(
                    icon: "power",
                    title: "Startup & Updates",
                    subtitle: "Launch behavior and update preferences"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
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
                    }
                }

                SettingsSection(
                    icon: "shield.fill",
                    title: "Permissions",
                    subtitle: "Manage system permissions"
                ) {
                    PermissionsView()
                }

                SettingsSection(
                    icon: "lock.shield",
                    title: "Privacy Controls",
                    subtitle: "Control transcript history and storage"
                ) {
                    AudioCleanupSettingsView()
                }

                SettingsSection(
                    icon: "arrow.up.arrow.down.circle",
                    title: "Backup & Restore",
                    subtitle: "Import or export your settings"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export your custom prompts, configurations, smart corrections, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export.")
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

                SettingsSection(
                    icon: "arrow.counterclockwise",
                    title: "Reset",
                    subtitle: "Restore initial setup"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reset the onboarding flow to see the introduction screens again.")
                            .settingsDescription()

                        Button("Reset Onboarding") {
                            showResetOnboardingAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }

                // MARK: - Experimental Features Section
                SettingsSection(
                    icon: "flask",
                    title: "Experimental Features",
                    subtitle: "Try new features that may be unstable"
                ) {
                    ExperimentalFeaturesSection()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
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
}
