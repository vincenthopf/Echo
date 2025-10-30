import SwiftUI

/// Left panel master list showing all awareness profiles
struct ProfileListView: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @Binding var selectedProfileId: UUID?

    let onAdd: () -> Void
    let onDelete: (PowerModeConfig) -> Void
    let onHelp: () -> Void

    @State private var searchText = ""

    private var filteredProfiles: [PowerModeConfig] {
        if searchText.isEmpty {
            return powerModeManager.configurations
        }
        return powerModeManager.configurations.filter { config in
            config.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Profiles")
                    .font(.headline)
                Spacer()

                // Help button
                Button(action: onHelp) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("What's New")

                // Add button
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Add new profile")
            }
            .padding()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search profiles", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // Profile list
            if filteredProfiles.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(filteredProfiles, id: \.id, selection: $selectedProfileId) { config in
                    ProfileListItem(
                        config: config,
                        isSelected: selectedProfileId == config.id,
                        onToggleEnabled: {
                            if config.isEnabled {
                                powerModeManager.disableConfiguration(with: config.id)
                            } else {
                                powerModeManager.enableConfiguration(with: config.id)
                            }
                        }
                    )
                    .tag(config.id)
                    .contextMenu {
                        Button("Duplicate") {
                            duplicateProfile(config)
                        }
                        if !config.isDefault {
                            Button("Set as Default") {
                                powerModeManager.setAsDefault(configId: config.id)
                            }
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            onDelete(config)
                        }
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
            }

            Spacer()
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func duplicateProfile(_ config: PowerModeConfig) {
        let duplicatedConfig = PowerModeConfig(
            name: "\(config.name) Copy",
            emoji: config.emoji,
            appConfigs: config.appConfigs,
            urlConfigs: config.urlConfigs,
            isAIEnhancementEnabled: config.isAIEnhancementEnabled,
            selectedPrompt: config.selectedPrompt,
            selectedTranscriptionModelName: config.selectedTranscriptionModelName,
            selectedLanguage: config.selectedLanguage,
            useScreenCapture: config.useScreenCapture,
            selectedAIProvider: config.selectedAIProvider,
            selectedAIModel: config.selectedAIModel,
            isAutoSendEnabled: config.isAutoSendEnabled,
            isEnabled: false, // Start disabled
            isDefault: false, // Never copy default status
            triggerWords: config.triggerWords
        )
        powerModeManager.addConfiguration(duplicatedConfig)
        selectedProfileId = duplicatedConfig.id
    }
}

/// Individual profile list item
struct ProfileListItem: View {
    let config: PowerModeConfig
    let isSelected: Bool
    let onToggleEnabled: () -> Void

    @ObservedObject private var powerModeManager = PowerModeManager.shared

    private var triggerCount: Int {
        let appCount = config.appConfigs?.count ?? 0
        let urlCount = config.urlConfigs?.count ?? 0
        let voiceCount = config.triggerWords.count
        return appCount + urlCount + voiceCount
    }

    private var isActive: Bool {
        powerModeManager.activeConfiguration?.id == config.id
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon (emoji or SF Symbol)
            ZStack {
                Circle()
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                    .frame(width: 36, height: 36)

                if config.emoji.shouldRenderAsSFSymbol {
                    Image(systemName: config.emoji)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .accentColor : .primary)
                } else {
                    Text(config.emoji)
                        .font(.title3)
                }
            }

            // Name and badges
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(config.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if isActive {
                        Text("Active")
                            .font(.system(size: 9, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green))
                            .foregroundColor(.white)
                    }
                }

                HStack(spacing: 8) {
                    if config.isDefault {
                        Text("Default")
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
                    }

                    if triggerCount > 0 {
                        Text("\(triggerCount) trigger\(triggerCount == 1 ? "" : "s")")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Enable toggle
            Toggle("", isOn: Binding(
                get: { config.isEnabled },
                set: { _ in onToggleEnabled() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.mini)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.accentColor.opacity(0.08) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isActive ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
    }
}
