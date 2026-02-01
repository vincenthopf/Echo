import SwiftUI

/// Master-detail container for Adaptive Awareness profile management
/// Uses HSplitView following macOS HIG patterns with parallel.ai design tokens
struct AdaptiveAwarenessView: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedProfileId: UUID?
    @State private var showingDeleteConfirmation = false
    @State private var profileToDelete: PowerModeConfig?
    @State private var showMigrationNotice = false
    @AppStorage("hasSeenAdaptiveAwarenessMigration") private var hasSeenMigrationNotice = false

    var body: some View {
        HSplitView {
            // Left Panel: Master List
            ProfileListView(
                selectedProfileId: $selectedProfileId,
                onAdd: addNewProfile,
                onDelete: { profile in
                    profileToDelete = profile
                    showingDeleteConfirmation = true
                },
                onHelp: {
                    showMigrationNotice = true
                }
            )
            .frame(minWidth: 240, idealWidth: 320, maxWidth: 320)
            .background(ParallelDesignTokens.Colors.cardBackground(for: colorScheme))

            // Right Panel: Detail Editor
            if let selectedId = selectedProfileId,
               let config = powerModeManager.getConfiguration(with: selectedId) {
                ProfileDetailView(config: config)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ParallelDesignTokens.Colors.background(for: colorScheme))
            } else {
                // Empty state
                VStack(spacing: ParallelDesignTokens.Spacing.lg) {
                    Image(systemName: "sparkles.square.fill.on.square")
                        .font(.system(size: 48))
                        .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))

                    Text("Select a Profile")
                        .font(ParallelDesignTokens.Typography.heading2)
                        .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))

                    Text("Choose a profile from the list to view and edit its settings")
                        .font(ParallelDesignTokens.Typography.bodySmall)
                        .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ParallelDesignTokens.Colors.background(for: colorScheme))
            }
        }
        .background(ParallelDesignTokens.Colors.background(for: colorScheme))
        .sheet(isPresented: $showMigrationNotice) {
            AdaptiveAwarenessMigrationSheet(isPresented: $showMigrationNotice)
        }
        .alert("Delete Profile", isPresented: $showingDeleteConfirmation, presenting: profileToDelete) { profile in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteProfile(profile)
            }
        } message: { profile in
            Text("Are you sure you want to delete \"\(profile.name)\"? This action can't be undone.")
        }
        .onAppear {
            // Select first profile by default if none selected
            Task {
                if selectedProfileId == nil, let firstConfig = powerModeManager.configurations.first {
                    selectedProfileId = firstConfig.id
                }
            }
        }
        .task {
            // Show migration notice on first visit if migration occurred
            let didMigrate = UserDefaults.standard.bool(forKey: "didMigrateToAdaptiveAwareness")
            if didMigrate && !hasSeenMigrationNotice {
                try? await Task.sleep(for: .milliseconds(300))
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showMigrationNotice = true
                    }
                }
            }
        }
    }

    private func addNewProfile() {
        let newConfig = PowerModeConfig(
            name: "New Profile",
            emoji: "sparkles",
            isAIEnhancementEnabled: false
        )
        powerModeManager.addConfiguration(newConfig)
        selectedProfileId = newConfig.id
    }

    private func deleteProfile(_ config: PowerModeConfig) {
        powerModeManager.removeConfiguration(with: config.id)

        // Select another profile after deletion
        if selectedProfileId == config.id {
            selectedProfileId = powerModeManager.configurations.first?.id
        }
    }
}

// MARK: - Help Sheet

struct AdaptiveAwarenessHelpSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ParallelDesignTokens.Spacing.xs) {
                    Text("What is Adaptive Awareness?")
                        .font(ParallelDesignTokens.Typography.heading2)
                        .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))

                    Text("Automatically apply custom transcription settings based on context")
                        .font(ParallelDesignTokens.Typography.bodySmall)
                        .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                }

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(ParallelDesignTokens.Spacing.xl)

            Divider()
                .background(ParallelDesignTokens.Colors.border(for: colorScheme))

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: ParallelDesignTokens.Spacing.xl) {
                    Text("Trigger profiles using:")
                        .font(ParallelDesignTokens.Typography.heading3)
                        .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))

                    VStack(alignment: .leading, spacing: ParallelDesignTokens.Spacing.lg) {
                        HelpTriggerRow(
                            icon: "app.fill",
                            title: "Applications",
                            description: "Activate when you switch to a specific app"
                        )

                        HelpTriggerRow(
                            icon: "globe",
                            title: "Websites",
                            description: "Activate when visiting specific URLs"
                        )

                        HelpTriggerRow(
                            icon: "mic.fill",
                            title: "Voice Keywords",
                            description: "Say a trigger word during recording"
                        )
                    }

                    Divider()
                        .background(ParallelDesignTokens.Colors.border(for: colorScheme))
                        .padding(.vertical, ParallelDesignTokens.Spacing.sm)

                    VStack(alignment: .leading, spacing: ParallelDesignTokens.Spacing.md) {
                        Text("What can profiles include?")
                            .font(ParallelDesignTokens.Typography.heading3)
                            .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))

                        Text("Each profile can have custom AI prompts, transcription models, language settings, and more. Mix and match any combination of triggers to create powerful context-aware workflows.")
                            .font(ParallelDesignTokens.Typography.bodySmall)
                            .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(ParallelDesignTokens.Spacing.xl)
            }

            Divider()
                .background(ParallelDesignTokens.Colors.border(for: colorScheme))

            // Footer
            HStack {
                Button(action: {
                    if let url = URL(string: "https://vjh.io/embr-echo-help") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Full Documentation")
                        .font(ParallelDesignTokens.Typography.bodySmall)
                        .foregroundColor(ParallelDesignTokens.Colors.primaryOrange)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Text("Got It")
                        .font(ParallelDesignTokens.Typography.bodySmall.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, ParallelDesignTokens.Spacing.lg)
                        .padding(.vertical, ParallelDesignTokens.Spacing.sm)
                        .background(ParallelDesignTokens.Colors.primaryOrange)
                        .cornerRadius(ParallelDesignTokens.Radius.small)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
            }
            .padding(ParallelDesignTokens.Spacing.xl)
        }
        .frame(width: 480, height: 520)
        .background(ParallelDesignTokens.Colors.cardBackground(for: colorScheme))
    }
}

struct HelpTriggerRow: View {
    let icon: String
    let title: String
    let description: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: ParallelDesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(ParallelDesignTokens.Colors.primaryOrange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: ParallelDesignTokens.Spacing.xs) {
                Text(title)
                    .font(ParallelDesignTokens.Typography.body.weight(.medium))
                    .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))

                Text(description)
                    .font(ParallelDesignTokens.Typography.label)
                    .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
