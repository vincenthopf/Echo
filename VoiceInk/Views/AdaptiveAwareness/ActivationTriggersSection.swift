import SwiftUI
import AppKit

/// Activation triggers section showing apps, URLs, and voice keywords in a 3-column grid
struct ActivationTriggersSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @State private var isShowingAppPicker = false
    @State private var installedApps: [(url: URL, name: String, bundleId: String, icon: NSImage)] = []
    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            // Header with trigger logic control
            HStack(alignment: .top) {
                SectionHeader(
                    title: "Activation Triggers",
                    subtitle: subtitleText
                )

                Spacer()

                if hasTriggers {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Picker("", selection: Binding(
                            get: { config.triggerLogicMode },
                            set: { newValue in
                                config.triggerLogicMode = newValue
                                onSave()
                            }
                        )) {
                            Text("Any").tag(TriggerLogicMode.any)
                            if config.hasMultipleTriggerCategories() {
                                Text("All").tag(TriggerLogicMode.all)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 100)
                        .tint(Tokens.Colors.orange)

                        InfoTip(
                            title: "Trigger Matching",
                            message: infoTipMessage
                        )
                    }
                }
            }

            // 3-column trigger grid - all columns same white background
            HStack(spacing: 0) {
                // Applications column
                triggerColumn(
                    icon: "square.grid.2x2",
                    title: "Applications"
                ) {
                    if let appConfigs = config.appConfigs, !appConfigs.isEmpty {
                        VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                            ForEach(appConfigs) { appConfig in
                                TriggerAppItem(appConfig: appConfig) {
                                    removeApp(appConfig)
                                }
                            }
                        }
                    }

                    Button(action: { isShowingAppPicker = true }) {
                        Text("+ Add app")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Tokens.Colors.orange)
                    }
                    .buttonStyle(.plain)
                }

                columnDivider

                // Websites column
                triggerColumn(
                    icon: "globe",
                    title: "Websites"
                ) {
                    URLPatternInput(
                        urlConfigs: Binding(
                            get: { config.urlConfigs ?? [] },
                            set: { newConfigs in
                                config.urlConfigs = newConfigs
                                onSave()
                            }
                        )
                    )
                }

                columnDivider

                // Voice Keywords column
                triggerColumn(
                    icon: "mic",
                    title: "Voice Keywords"
                ) {
                    VoiceKeywordInput(
                        triggerWords: Binding(
                            get: { config.triggerWords },
                            set: { newWords in
                                config.triggerWords = newWords
                                onSave()
                            }
                        )
                    )
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
        .sheet(isPresented: $isShowingAppPicker) {
            AppPickerSheet(
                installedApps: installedApps,
                selectedAppConfigs: Binding(
                    get: { config.appConfigs ?? [] },
                    set: { newConfigs in
                        config.appConfigs = newConfigs
                        onSave()
                    }
                ),
                searchText: $searchText,
                onDismiss: {
                    isShowingAppPicker = false
                }
            )
            .onAppear {
                loadInstalledApps()
            }
        }
    }

    // MARK: - Column Builder

    @ViewBuilder
    private func triggerColumn<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            // Header
            HStack(spacing: Tokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Tokens.Colors.orange)

                Text(title.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }

            // Content
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Tokens.Spacing.lg)
    }

    private var columnDivider: some View {
        Rectangle()
            .fill(Tokens.Colors.border(for: colorScheme))
            .frame(width: 1)
    }

    // MARK: - Computed Properties

    private var hasTriggers: Bool {
        return config.configuredTriggerCategories() > 0
    }

    private var subtitleText: String {
        if !hasTriggers {
            return "Add triggers to enable automatic activation"
        }

        switch config.triggerLogicMode {
        case .any:
            return "Activates when any trigger matches"
        case .all:
            return "Requires at least two trigger types to match"
        }
    }

    private var infoTipMessage: String {
        """
        Any: Profile activates when at least one trigger matches.

        All: Profile only activates when triggers from at least two categories match simultaneously.
        """
    }

    // MARK: - Helper Methods

    private func loadInstalledApps() {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> (url: URL, name: String, bundleId: String, icon: NSImage)? in
                guard let bundleId = app.bundleIdentifier,
                      let url = app.bundleURL,
                      let name = app.localizedName else {
                    return nil
                }
                let icon = workspace.icon(forFile: url.path)
                return (url: url, name: name, bundleId: bundleId, icon: icon)
            }

        let fileManager = FileManager.default
        let applicationsPaths = [
            "/Applications",
            "\(NSHomeDirectory())/Applications"
        ]

        var allApps = apps
        for path in applicationsPaths {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else { continue }

            for item in contents where item.hasSuffix(".app") {
                let appPath = "\(path)/\(item)"
                let appURL = URL(fileURLWithPath: appPath)

                if let bundle = Bundle(url: appURL),
                   let bundleId = bundle.bundleIdentifier,
                   let name = bundle.infoDictionary?["CFBundleName"] as? String,
                   !allApps.contains(where: { $0.bundleId == bundleId }) {
                    let icon = workspace.icon(forFile: appPath)
                    allApps.append((url: appURL, name: name, bundleId: bundleId, icon: icon))
                }
            }
        }

        installedApps = allApps
    }

    private func removeApp(_ appConfig: AppConfig) {
        config.appConfigs?.removeAll { $0.id == appConfig.id }
        onSave()
    }
}

// MARK: - Trigger App Item

/// Compact app item for trigger grid
struct TriggerAppItem: View {
    let appConfig: AppConfig
    let onDelete: () -> Void

    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            // App icon
            let icon = NSWorkspace.shared.icon(forFile: getAppPath(for: appConfig.bundleIdentifier))
            Image(nsImage: icon)
                .resizable()
                .frame(width: 20, height: 20)

            Text(appConfig.appName)
                .font(Tokens.Typography.bodySmall)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                .lineLimit(1)

            Spacer(minLength: 4)

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Tokens.Spacing.sm)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .fill(Tokens.Colors.background(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }

    private func getAppPath(for bundleIdentifier: String) -> String {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return url.path
        }
        return ""
    }
}

/// Legacy alias for backwards compatibility
struct AppConfigIconView: View {
    let appConfig: AppConfig
    let onDelete: () -> Void

    var body: some View {
        TriggerAppItem(appConfig: appConfig, onDelete: onDelete)
    }
}

/// Legacy component aliases
struct TriggerColumnView<Content: View>: View {
    let icon: String
    let title: String
    let isEmpty: Bool
    let emptyText: String
    let addText: String
    let onAdd: (() -> Void)?
    let showRequiredBadge: Bool
    @ViewBuilder let content: Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            HStack(spacing: Tokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Tokens.Colors.orange)

                Text(title.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }

            content

            if let onAdd = onAdd {
                Button(action: onAdd) {
                    Text(addText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Tokens.Colors.orange)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Tokens.Spacing.lg)
    }
}

struct TriggerColumnDivider: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(Tokens.Colors.border(for: colorScheme))
            .frame(width: 1)
    }
}
