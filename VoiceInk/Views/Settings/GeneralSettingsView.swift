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

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: Tokens.Spacing.xl) {
                // MARK: - Appearance Section
                appearanceSection

                // MARK: - Startup & Updates Section
                startupSection

                // MARK: - Permissions Section
                permissionsSection

                // MARK: - Privacy Controls Section
                privacySection

                // MARK: - Backup & Restore Section
                backupSection

                // MARK: - Reset Section
                resetSection

                // MARK: - Experimental Features Section
                experimentalSection
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.vertical, Tokens.Spacing.sm)
        }
        .background(Tokens.Colors.background(for: colorScheme))
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

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Appearance",
                subtitle: "Customize how Echo appears"
            )

            VStack(spacing: 0) {
                FormRow(label: "Dock") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $menuBarManager.isMenuBarOnly)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()

                        Text("Hide Dock Icon (Menu Bar Only)")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

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

    // MARK: - Startup & Updates Section

    private var startupSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Startup & Updates",
                subtitle: "Launch behavior and update preferences"
            )

            VStack(spacing: 0) {
                FormRow(label: "Launch") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        LaunchAtLogin.Toggle {
                            EmptyView()
                        }
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Launch at Login")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Spacer()
                    }
                }

                FormDivider()

                FormRow(label: "Updates") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $autoUpdateCheck)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()
                            .onChange(of: autoUpdateCheck) { _, newValue in
                                updaterViewModel.toggleAutoUpdates(newValue)
                            }

                        Text("Enable automatic update checks")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

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

    // MARK: - Permissions Section

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Permissions",
                subtitle: "Manage system permissions"
            )

            VStack(spacing: 0) {
                PermissionsView()
                    .padding(Tokens.Spacing.lg)
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Privacy Controls Section

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Privacy Controls",
                subtitle: "Control transcript history and storage"
            )

            VStack(spacing: 0) {
                AudioCleanupSettingsView()
                    .padding(Tokens.Spacing.lg)
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Backup & Restore Section

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Backup & Restore",
                subtitle: "Import or export your settings"
            )

            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Text("Export your custom prompts, configurations, smart corrections, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export.")
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Tokens.Spacing.md) {
                    Button(action: {
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
                    }) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Image(systemName: "arrow.down.doc")
                            Text("Import Settings...")
                        }
                        .font(Tokens.Typography.body)
                        .padding(.vertical, Tokens.Spacing.sm)
                        .padding(.horizontal, Tokens.Spacing.md)
                        .background(Tokens.Colors.elevated(for: colorScheme))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
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
                    }) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Image(systemName: "arrow.up.doc")
                            Text("Export Settings...")
                        }
                        .font(Tokens.Typography.body)
                        .padding(.vertical, Tokens.Spacing.sm)
                        .padding(.horizontal, Tokens.Spacing.md)
                        .background(Tokens.Colors.elevated(for: colorScheme))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
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

    // MARK: - Reset Section

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Reset",
                subtitle: "Restore initial setup"
            )

            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Text("Reset the onboarding flow to see the introduction screens again.")
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: {
                    showResetOnboardingAlert = true
                }) {
                    Text("Reset Onboarding")
                        .font(Tokens.Typography.body)
                        .padding(.vertical, Tokens.Spacing.sm)
                        .padding(.horizontal, Tokens.Spacing.md)
                        .background(Tokens.Colors.elevated(for: colorScheme))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
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

    // MARK: - Experimental Features Section

    private var experimentalSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Experimental Features",
                subtitle: "Try new features that may be unstable"
            )

            VStack(spacing: 0) {
                ExperimentalFeaturesSection()
                    .padding(Tokens.Spacing.lg)
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }
}
