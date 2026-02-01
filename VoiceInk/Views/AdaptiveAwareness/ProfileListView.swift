import SwiftUI

/// Left panel master list showing all awareness profiles
/// Grid-based design with 1px borders, left accent bars for selection
struct ProfileListView: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @Binding var selectedProfileId: UUID?
    @Environment(\.colorScheme) private var colorScheme

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
            // Header - clean with title and orange + button
            HStack {
                Text("Profiles")
                    .font(Tokens.Typography.sectionTitle)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                Spacer()

                // Add button - orange filled
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Tokens.Colors.orange)
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                }
                .buttonStyle(.plain)
                .help("Add new profile")
            }
            .padding(.horizontal, Tokens.Spacing.xl)
            .padding(.vertical, Tokens.Spacing.lg)

            // Divider under header
            Rectangle()
                .fill(Tokens.Colors.border(for: colorScheme))
                .frame(height: 1)

            // Search bar - simpler styling
            HStack(spacing: Tokens.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                TextField("Search profiles", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(Tokens.Typography.body)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Tokens.Spacing.xl)
            .padding(.vertical, Tokens.Spacing.md)

            // Divider under search
            Rectangle()
                .fill(Tokens.Colors.border(for: colorScheme))
                .frame(height: 1)

            // Profile list
            if filteredProfiles.isEmpty {
                VStack(spacing: Tokens.Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                    Text("No Results")
                        .font(Tokens.Typography.sectionTitle)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    Text("No profiles match \"\(searchText)\"")
                        .font(Tokens.Typography.bodySmall)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredProfiles, id: \.id) { config in
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedProfileId = config.id
                            }
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
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .background(Tokens.Colors.elevated(for: colorScheme))
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

/// Individual profile list item with grid-based design
/// Selected: left 3px orange bar + soft orange background
/// Not selected: bottom border only
struct ProfileListItem: View {
    let config: PowerModeConfig
    let isSelected: Bool
    let onToggleEnabled: () -> Void

    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @Environment(\.colorScheme) private var colorScheme

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
        HStack(spacing: 0) {
            // Left accent bar - 3px orange when selected
            Rectangle()
                .fill(isSelected ? Tokens.Colors.orange : Color.clear)
                .frame(width: 3)

            HStack(spacing: Tokens.Spacing.md) {
                // Profile icon - 36px, rounded 8px, border style
                ZStack {
                    RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                        .fill(isSelected
                              ? Tokens.Colors.orangeMedium(for: colorScheme)
                              : Tokens.Colors.background(for: colorScheme))
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                                .stroke(
                                    isSelected
                                    ? Tokens.Colors.orange
                                    : Tokens.Colors.border(for: colorScheme),
                                    lineWidth: 1
                                )
                        )

                    if config.emoji.shouldRenderAsSFSymbol {
                        Image(systemName: config.emoji)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected
                                             ? Tokens.Colors.orange
                                             : Tokens.Colors.textPrimary(for: colorScheme))
                    } else {
                        Text(config.emoji)
                            .font(.system(size: 18))
                    }
                }

                // Name and meta
                VStack(alignment: .leading, spacing: 2) {
                    Text(config.name)
                        .font(Tokens.Typography.body.weight(.medium))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    if config.isDefault {
                        Text("Fallback profile")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                    } else if triggerCount > 0 {
                        Text("\(triggerCount) trigger\(triggerCount == 1 ? "" : "s")")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                    }
                }

                Spacer()

                // Right side: badge or toggle
                if isActive {
                    // Active badge - success green
                    Text("ACTIVE")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .tracking(0.5)
                        .padding(.horizontal, Tokens.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(Tokens.Colors.successSoft(for: colorScheme))
                        .foregroundColor(Tokens.Colors.success)
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
                } else if config.isDefault {
                    // Default badge - orange
                    Text("DEFAULT")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .tracking(0.5)
                        .padding(.horizontal, Tokens.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(Tokens.Colors.orangeMedium(for: colorScheme))
                        .foregroundColor(Tokens.Colors.orange)
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
                } else {
                    // Toggle for non-default profiles
                    Toggle("", isOn: Binding(
                        get: { config.isEnabled },
                        set: { _ in onToggleEnabled() }
                    ))
                    .toggleStyle(.switch)
                    .tint(Tokens.Colors.orange)
                    .labelsHidden()
                    .controlSize(.mini)
                }
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.vertical, 14)
        }
        .background(isSelected ? Tokens.Colors.orangeSoft(for: colorScheme) : Color.clear)
        .overlay(alignment: .bottom) {
            // Bottom border
            Rectangle()
                .fill(Tokens.Colors.border(for: colorScheme))
                .frame(height: 1)
        }
    }
}
