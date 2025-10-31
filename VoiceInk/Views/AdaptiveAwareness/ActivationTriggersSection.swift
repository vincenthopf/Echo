import SwiftUI
import AppKit

/// Activation triggers section showing apps, URLs, and voice keywords
struct ActivationTriggersSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @State private var isShowingAppPicker = false
    @State private var installedApps: [(url: URL, name: String, bundleId: String, icon: NSImage)] = []
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Activation Triggers")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitleText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Trigger Logic Mode Selector
            if shouldShowTriggerLogicControl {
                HStack(spacing: 8) {
                    Picker("Trigger Logic", selection: Binding(
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
                    .frame(width: 160)
                    .disabled(!hasTriggers)

                    InfoTip(
                        title: "Trigger Matching",
                        message: infoTipMessage
                    )

                    Spacer()
                }
            }

            // Applications Subsection
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Text("Applications")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if shouldShowRequiredBadge(hasItems: config.appConfigs?.isEmpty == false) {
                        Text("(1 required)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let appConfigs = config.appConfigs, !appConfigs.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120))], spacing: 12) {
                        ForEach(appConfigs) { appConfig in
                            AppConfigIconView(appConfig: appConfig) {
                                removeApp(appConfig)
                            }
                        }
                    }
                } else {
                    Text("No applications added")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    isShowingAppPicker = true
                }) {
                    Label("Add Application", systemImage: "plus.circle")
                        .font(.system(size: 13))
                }
                .buttonStyle(.bordered)
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

            Divider()
                .padding(.vertical, 4)

            // Websites Subsection
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Text("Websites")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if shouldShowRequiredBadge(hasItems: config.urlConfigs?.isEmpty == false) {
                        Text("(1 required)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

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

            Divider()
                .padding(.vertical, 4)

            // Voice Keywords Subsection
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Text("Voice Keywords")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if shouldShowRequiredBadge(hasItems: !config.triggerWords.isEmpty) {
                        Text("(1 required)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

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
    }

    // MARK: - Computed Properties

    /// Whether the control should be shown (disabled control when no triggers)
    private var shouldShowTriggerLogicControl: Bool {
        return true  // Always show, disabled when empty per user choice
    }

    /// Whether any triggers are configured
    private var hasTriggers: Bool {
        return config.configuredTriggerCategories() > 0
    }

    /// Dynamic subtitle text based on configuration state and logic mode
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

    /// Info tip message explaining trigger logic
    private var infoTipMessage: String {
        """
        Any: Profile activates when at least one trigger matches.

        All: Profile only activates when triggers from at least two categories match simultaneously. For example, if you've set both an application and a website trigger, both must be active at the same time.
        """
    }

    /// Whether to show "(1 required)" badge on category headers
    private func shouldShowRequiredBadge(hasItems: Bool) -> Bool {
        return config.triggerLogicMode == .all && hasItems && config.hasMultipleTriggerCategories()
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

        // Add common applications even if not running
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

/// App config icon view with delete button
struct AppConfigIconView: View {
    let appConfig: AppConfig
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                // App icon
                let icon = NSWorkspace.shared.icon(forFile: getAppPath(for: appConfig.bundleIdentifier))
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 48, height: 48)

                // Delete button on hover
                if isHovered {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.red)
                            .font(.title3)
                            .background(Circle().fill(Color.white.opacity(0.9)))
                    }
                    .buttonStyle(.plain)
                    .offset(x: 8, y: -8)
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }

            Text(appConfig.appName)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }

    private func getAppPath(for bundleIdentifier: String) -> String {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return url.path
        }
        return ""
    }
}
