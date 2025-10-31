import Foundation

/// Defines how multiple trigger types should be evaluated for profile activation
enum TriggerLogicMode: String, Codable {
    case any  // OR logic: ANY trigger from ANY category activates profile (default)
    case all  // AND logic: At least ONE trigger from at least TWO categories must match
}

struct PowerModeConfig: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var emoji: String
    var appConfigs: [AppConfig]?
    var urlConfigs: [URLConfig]?
    var isAIEnhancementEnabled: Bool
    var selectedPrompt: String?
    var selectedTranscriptionModelName: String?
    var selectedLanguage: String?
    var useScreenCapture: Bool
    var selectedAIProvider: String?
    var selectedAIModel: String?
    var isAutoSendEnabled: Bool = false
    var isEnabled: Bool = true
    var isDefault: Bool = false

    // Voice trigger support for Adaptive Awareness integration
    var triggerWords: [String] = []

    // Trigger logic mode: determines how multiple triggers are evaluated
    var triggerLogicMode: TriggerLogicMode = .any

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, appConfigs, urlConfigs, isAIEnhancementEnabled, selectedPrompt, selectedLanguage, useScreenCapture, selectedAIProvider, selectedAIModel, isAutoSendEnabled, isEnabled, isDefault, triggerWords, triggerLogicMode
        case selectedWhisperModel
        case selectedTranscriptionModelName
    }
    
    init(id: UUID = UUID(), name: String, emoji: String, appConfigs: [AppConfig]? = nil,
         urlConfigs: [URLConfig]? = nil, isAIEnhancementEnabled: Bool, selectedPrompt: String? = nil,
         selectedTranscriptionModelName: String? = nil, selectedLanguage: String? = nil, useScreenCapture: Bool = false,
         selectedAIProvider: String? = nil, selectedAIModel: String? = nil, isAutoSendEnabled: Bool = false, isEnabled: Bool = true, isDefault: Bool = false, triggerWords: [String] = [], triggerLogicMode: TriggerLogicMode = .any) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.appConfigs = appConfigs
        self.urlConfigs = urlConfigs
        self.isAIEnhancementEnabled = isAIEnhancementEnabled
        self.selectedPrompt = selectedPrompt
        self.useScreenCapture = useScreenCapture
        self.isAutoSendEnabled = isAutoSendEnabled
        self.selectedAIProvider = selectedAIProvider ?? UserDefaults.standard.string(forKey: "selectedAIProvider")
        self.selectedAIModel = selectedAIModel
        self.selectedTranscriptionModelName = selectedTranscriptionModelName ?? UserDefaults.standard.string(forKey: "CurrentTranscriptionModel")
        self.selectedLanguage = selectedLanguage ?? UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
        self.isEnabled = isEnabled
        self.isDefault = isDefault
        self.triggerWords = triggerWords
        self.triggerLogicMode = triggerLogicMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        appConfigs = try container.decodeIfPresent([AppConfig].self, forKey: .appConfigs)
        urlConfigs = try container.decodeIfPresent([URLConfig].self, forKey: .urlConfigs)
        isAIEnhancementEnabled = try container.decode(Bool.self, forKey: .isAIEnhancementEnabled)
        selectedPrompt = try container.decodeIfPresent(String.self, forKey: .selectedPrompt)
        selectedLanguage = try container.decodeIfPresent(String.self, forKey: .selectedLanguage)
        useScreenCapture = try container.decode(Bool.self, forKey: .useScreenCapture)
        selectedAIProvider = try container.decodeIfPresent(String.self, forKey: .selectedAIProvider)
        selectedAIModel = try container.decodeIfPresent(String.self, forKey: .selectedAIModel)
        isAutoSendEnabled = try container.decodeIfPresent(Bool.self, forKey: .isAutoSendEnabled) ?? false
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false

        // Decode triggerWords with fallback to empty array for backward compatibility
        triggerWords = try container.decodeIfPresent([String].self, forKey: .triggerWords) ?? []

        // Decode triggerLogicMode with fallback to .any for backward compatibility
        triggerLogicMode = try container.decodeIfPresent(TriggerLogicMode.self, forKey: .triggerLogicMode) ?? .any

        if let newModelName = try container.decodeIfPresent(String.self, forKey: .selectedTranscriptionModelName) {
            selectedTranscriptionModelName = newModelName
        } else if let oldModelName = try container.decodeIfPresent(String.self, forKey: .selectedWhisperModel) {
            selectedTranscriptionModelName = oldModelName
        } else {
            selectedTranscriptionModelName = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(emoji, forKey: .emoji)
        try container.encodeIfPresent(appConfigs, forKey: .appConfigs)
        try container.encodeIfPresent(urlConfigs, forKey: .urlConfigs)
        try container.encode(isAIEnhancementEnabled, forKey: .isAIEnhancementEnabled)
        try container.encodeIfPresent(selectedPrompt, forKey: .selectedPrompt)
        try container.encodeIfPresent(selectedLanguage, forKey: .selectedLanguage)
        try container.encode(useScreenCapture, forKey: .useScreenCapture)
        try container.encodeIfPresent(selectedAIProvider, forKey: .selectedAIProvider)
        try container.encodeIfPresent(selectedAIModel, forKey: .selectedAIModel)
        try container.encode(isAutoSendEnabled, forKey: .isAutoSendEnabled)
        try container.encodeIfPresent(selectedTranscriptionModelName, forKey: .selectedTranscriptionModelName)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(isDefault, forKey: .isDefault)
        try container.encode(triggerWords, forKey: .triggerWords)
        try container.encode(triggerLogicMode, forKey: .triggerLogicMode)
    }
    
    
    static func == (lhs: PowerModeConfig, rhs: PowerModeConfig) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Trigger Logic Helpers

    /// Returns the number of trigger categories that have at least one configured trigger
    func configuredTriggerCategories() -> Int {
        var count = 0
        if let apps = appConfigs, !apps.isEmpty { count += 1 }
        if let urls = urlConfigs, !urls.isEmpty { count += 1 }
        if !triggerWords.isEmpty { count += 1 }
        return count
    }

    /// Returns whether the profile has triggers configured across multiple categories
    func hasMultipleTriggerCategories() -> Bool {
        return configuredTriggerCategories() >= 2
    }

    /// Returns whether the profile can use "All" logic mode
    func canUseAllLogicMode() -> Bool {
        return hasMultipleTriggerCategories()
    }
}

struct AppConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var bundleIdentifier: String
    var appName: String
    
    init(id: UUID = UUID(), bundleIdentifier: String, appName: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
    }
    
    static func == (lhs: AppConfig, rhs: AppConfig) -> Bool {
        lhs.id == rhs.id
    }
}

struct URLConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var url: String
    
    init(id: UUID = UUID(), url: String) {
        self.id = id
        self.url = url
    }
    
    static func == (lhs: URLConfig, rhs: URLConfig) -> Bool {
        lhs.id == rhs.id
    }
}

class PowerModeManager: ObservableObject {
    static let shared = PowerModeManager()
    @Published var configurations: [PowerModeConfig] = []
    @Published var activeConfiguration: PowerModeConfig?

    private let configKey = "powerModeConfigurationsV2"
    private let activeConfigIdKey = "activeConfigurationId"

    private init() {
        loadConfigurations()

        if let activeConfigIdString = UserDefaults.standard.string(forKey: activeConfigIdKey),
           let activeConfigId = UUID(uuidString: activeConfigIdString) {
            activeConfiguration = configurations.first { $0.id == activeConfigId }
        } else {
            activeConfiguration = nil
        }
    }

    private func loadConfigurations() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let configs = try? JSONDecoder().decode([PowerModeConfig].self, from: data) {
            configurations = configs
        }
    }

    func saveConfigurations() {
        if let data = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }

    func addConfiguration(_ config: PowerModeConfig) {
        if !configurations.contains(where: { $0.id == config.id }) {
            configurations.append(config)
            saveConfigurations()
        }
    }

    func removeConfiguration(with id: UUID) {
        configurations.removeAll { $0.id == id }
        saveConfigurations()
    }

    func getConfiguration(with id: UUID) -> PowerModeConfig? {
        return configurations.first { $0.id == id }
    }

    func updateConfiguration(_ config: PowerModeConfig) {
        if let index = configurations.firstIndex(where: { $0.id == config.id }) {
            configurations[index] = config
            saveConfigurations()
        }
    }

    func moveConfigurations(fromOffsets: IndexSet, toOffset: Int) {
        configurations.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveConfigurations()
    }

    func getConfigurationForURL(_ url: String) -> PowerModeConfig? {
        let cleanedURL = cleanURL(url)
        
        for config in configurations.filter({ $0.isEnabled }) {
            if let urlConfigs = config.urlConfigs {
                for urlConfig in urlConfigs {
                    let configURL = cleanURL(urlConfig.url)
                    
                    if cleanedURL.contains(configURL) {
                        return config
                    }
                }
            }
        }
        return nil
    }
    
    func getConfigurationForApp(_ bundleId: String) -> PowerModeConfig? {
        for config in configurations.filter({ $0.isEnabled }) {
            if let appConfigs = config.appConfigs {
                if appConfigs.contains(where: { $0.bundleIdentifier == bundleId }) {
                    return config
                }
            }
        }
        return nil
    }
    
    func getDefaultConfiguration() -> PowerModeConfig? {
        return configurations.first { $0.isEnabled && $0.isDefault }
    }
    
    func hasDefaultConfiguration() -> Bool {
        return configurations.contains { $0.isDefault }
    }
    
    func setAsDefault(configId: UUID) {
        // Clear any existing default
        for index in configurations.indices {
            configurations[index].isDefault = false
        }
        
        // Set the specified config as default
        if let index = configurations.firstIndex(where: { $0.id == configId }) {
            configurations[index].isDefault = true
        }
        
        saveConfigurations()
    }
    
    func enableConfiguration(with id: UUID) {
        if let index = configurations.firstIndex(where: { $0.id == id }) {
            configurations[index].isEnabled = true
            saveConfigurations()
        }
    }
    
    func disableConfiguration(with id: UUID) {
        if let index = configurations.firstIndex(where: { $0.id == id }) {
            configurations[index].isEnabled = false
            saveConfigurations()
        }
    }
    
    var enabledConfigurations: [PowerModeConfig] {
        return configurations.filter { $0.isEnabled }
    }

    func addAppConfig(_ appConfig: AppConfig, to config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            var configs = updatedConfig.appConfigs ?? []
            configs.append(appConfig)
            updatedConfig.appConfigs = configs
            updateConfiguration(updatedConfig)
        }
    }

    func removeAppConfig(_ appConfig: AppConfig, from config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            updatedConfig.appConfigs?.removeAll(where: { $0.id == appConfig.id })
            updateConfiguration(updatedConfig)
        }
    }

    func addURLConfig(_ urlConfig: URLConfig, to config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            var configs = updatedConfig.urlConfigs ?? []
            configs.append(urlConfig)
            updatedConfig.urlConfigs = configs
            updateConfiguration(updatedConfig)
        }
    }

    func removeURLConfig(_ urlConfig: URLConfig, from config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            updatedConfig.urlConfigs?.removeAll(where: { $0.id == urlConfig.id })
            updateConfiguration(updatedConfig)
        }
    }

    func cleanURL(_ url: String) -> String {
        return url.lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func setActiveConfiguration(_ config: PowerModeConfig?) {
        activeConfiguration = config
        UserDefaults.standard.set(config?.id.uuidString, forKey: activeConfigIdKey)
        self.objectWillChange.send()
    }

    var currentActiveConfiguration: PowerModeConfig? {
        return activeConfiguration
    }

    func getAllAvailableConfigurations() -> [PowerModeConfig] {
        return configurations
    }

    func isEmojiInUse(_ emoji: String) -> Bool {
        return configurations.contains { $0.emoji == emoji }
    }

    // MARK: - Unified Matching Logic

    /// Finds a matching configuration based on current context and trigger logic mode
    /// - Parameters:
    ///   - bundleId: Current application bundle identifier
    ///   - url: Current URL (if in a browser), optional
    ///   - voiceTrigger: Detected voice keyword, optional
    /// - Returns: The first matching enabled configuration, or nil
    func findMatchingConfiguration(bundleId: String, url: String?, voiceTrigger: String?) -> PowerModeConfig? {
        for config in configurations.filter({ $0.isEnabled }) {
            if matchesConfiguration(config, bundleId: bundleId, url: url, voiceTrigger: voiceTrigger) {
                return config
            }
        }
        return nil
    }

    /// Determines if a configuration matches the current context based on its trigger logic mode
    private func matchesConfiguration(_ config: PowerModeConfig, bundleId: String, url: String?, voiceTrigger: String?) -> Bool {
        switch config.triggerLogicMode {
        case .any:
            // OR logic: ANY trigger matches
            return matchesAnyTrigger(config, bundleId: bundleId, url: url, voiceTrigger: voiceTrigger)

        case .all:
            // AND logic: At least TWO categories must match
            return matchesAllLogic(config, bundleId: bundleId, url: url, voiceTrigger: voiceTrigger)
        }
    }

    /// Checks if ANY trigger from ANY category matches (OR logic)
    private func matchesAnyTrigger(_ config: PowerModeConfig, bundleId: String, url: String?, voiceTrigger: String?) -> Bool {
        // Check voice trigger first (highest precedence)
        if let trigger = voiceTrigger, !config.triggerWords.isEmpty {
            let normalizedTrigger = trigger.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if config.triggerWords.contains(where: {
                $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedTrigger
            }) {
                return true
            }
        }

        // Check URL patterns
        if let currentURL = url, let urlConfigs = config.urlConfigs, !urlConfigs.isEmpty {
            let cleanedCurrentURL = cleanURL(currentURL)
            for urlConfig in urlConfigs {
                let configURL = cleanURL(urlConfig.url)
                if cleanedCurrentURL.contains(configURL) {
                    return true
                }
            }
        }

        // Check app bundles
        if let appConfigs = config.appConfigs, !appConfigs.isEmpty {
            if appConfigs.contains(where: { $0.bundleIdentifier == bundleId }) {
                return true
            }
        }

        return false
    }

    /// Checks if at least TWO trigger categories match (AND logic)
    private func matchesAllLogic(_ config: PowerModeConfig, bundleId: String, url: String?, voiceTrigger: String?) -> Bool {
        var matchedCategories = 0

        // Check voice triggers
        if !config.triggerWords.isEmpty {
            if let trigger = voiceTrigger {
                let normalizedTrigger = trigger.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if config.triggerWords.contains(where: {
                    $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedTrigger
                }) {
                    matchedCategories += 1
                }
            }
            // If voice keywords are configured but none matched, this category requirement is NOT met
            // However, we continue checking other categories since we need at least 2 total matches
        }

        // Check URL patterns
        if let urlConfigs = config.urlConfigs, !urlConfigs.isEmpty {
            if let currentURL = url {
                let cleanedCurrentURL = cleanURL(currentURL)
                let urlMatches = urlConfigs.contains { urlConfig in
                    let configURL = cleanURL(urlConfig.url)
                    return cleanedCurrentURL.contains(configURL)
                }
                if urlMatches {
                    matchedCategories += 1
                }
            }
        }

        // Check app bundles
        if let appConfigs = config.appConfigs, !appConfigs.isEmpty {
            if appConfigs.contains(where: { $0.bundleIdentifier == bundleId }) {
                matchedCategories += 1
            }
        }

        // Require at least 2 categories to match
        return matchedCategories >= 2
    }

    // MARK: - Voice Trigger Support (Adaptive Awareness)

    /// Finds a PowerModeConfig that contains the specified trigger word
    /// - Parameter word: The trigger word to search for (case-insensitive)
    /// - Returns: The first enabled configuration containing the trigger word, or nil if not found
    func findByTriggerWord(_ word: String) -> PowerModeConfig? {
        let normalizedWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        return configurations.first { config in
            config.isEnabled && config.triggerWords.contains { triggerWord in
                triggerWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedWord
            }
        }
    }

    /// Returns a dictionary mapping all trigger words to their corresponding configurations
    /// - Returns: Dictionary with lowercase trigger words as keys and PowerModeConfig as values
    func allTriggerWords() -> [String: PowerModeConfig] {
        var result: [String: PowerModeConfig] = [:]

        for config in configurations.filter({ $0.isEnabled }) {
            for triggerWord in config.triggerWords {
                let normalizedWord = triggerWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                // First matching config wins if multiple configs have the same trigger word
                if result[normalizedWord] == nil {
                    result[normalizedWord] = config
                }
            }
        }

        return result
    }
} 