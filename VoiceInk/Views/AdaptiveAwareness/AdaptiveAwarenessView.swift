import SwiftUI

/// Master-detail container for Adaptive Awareness profile management
/// Uses NavigationSplitView following macOS HIG patterns
struct AdaptiveAwarenessView: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService

    @State private var selectedProfileId: UUID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingDeleteConfirmation = false
    @State private var profileToDelete: PowerModeConfig?
    @State private var showingHelpSheet = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Left Panel: Master List
            ProfileListView(
                selectedProfileId: $selectedProfileId,
                onAdd: addNewProfile,
                onDelete: { profile in
                    profileToDelete = profile
                    showingDeleteConfirmation = true
                }
            )
            .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
        } detail: {
            // Right Panel: Detail Editor
            if let selectedId = selectedProfileId,
               let config = powerModeManager.getConfiguration(with: selectedId) {
                ProfileDetailView(config: config)
            } else {
                // Empty state
                ContentUnavailableView(
                    "Select a Profile",
                    systemImage: "sparkles.square.fill.on.square",
                    description: Text("Choose a profile from the list to view and edit its settings")
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingHelpSheet = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Learn about Adaptive Awareness")
            }
        }
        .sheet(isPresented: $showingHelpSheet) {
            AdaptiveAwarenessHelpSheet(isPresented: $showingHelpSheet)
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
            if selectedProfileId == nil, let firstConfig = powerModeManager.configurations.first {
                selectedProfileId = firstConfig.id
            }
        }
    }

    private func addNewProfile() {
        let newConfig = PowerModeConfig(
            name: "New Profile",
            emoji: "✨",
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

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What is Adaptive Awareness?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("Automatically apply custom transcription settings based on context")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(24)

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Trigger profiles using:")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 16) {
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
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What can profiles include?")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Each profile can have custom AI prompts, transcription models, language settings, and more. Mix and match any combination of triggers to create powerful context-aware workflows.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
            }

            Divider()

            // Footer
            HStack {
                Button(action: {
                    if let url = URL(string: "https://vjh.io/embr-echo-help") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Full Documentation")
                        .font(.system(size: 13))
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Text("Got It")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
            }
            .padding(24)
        }
        .frame(width: 480, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct HelpTriggerRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
