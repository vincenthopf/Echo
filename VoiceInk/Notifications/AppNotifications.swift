import Foundation

enum AppDestination: String, Codable {
    case dashboard
    case transcribeFiles
    case adaptiveAwareness
    case vocabulary
    case history
    case settings
    case about
}

extension Notification.Name {
    static let AppSettingsDidChange = Notification.Name("appSettingsDidChange")
    static let languageDidChange = Notification.Name("languageDidChange")
    static let promptDidChange = Notification.Name("promptDidChange")
    static let toggleMiniRecorder = Notification.Name("toggleMiniRecorder")
    static let dismissMiniRecorder = Notification.Name("dismissMiniRecorder")
    static let didChangeModel = Notification.Name("didChangeModel")
    static let aiProviderKeyChanged = Notification.Name("aiProviderKeyChanged")
    static let navigateToDestination = Notification.Name("navigateToDestination")
    static let promptSelectionChanged = Notification.Name("promptSelectionChanged")
    static let powerModeConfigurationApplied = Notification.Name("powerModeConfigurationApplied")
    static let transcriptionCreated = Notification.Name("transcriptionCreated")
    static let transcriptionCompleted = Notification.Name("transcriptionCompleted")
    static let enhancementToggleChanged = Notification.Name("enhancementToggleChanged")
    static let openFileForTranscription = Notification.Name("openFileForTranscription")
    static let toggleSidebar = Notification.Name("toggleSidebar")
}

extension Notification {
    static func destinationUserInfo(_ destination: AppDestination) -> [AnyHashable: Any] {
        ["destination": destination.rawValue]
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    var appDestination: AppDestination? {
        guard let rawDestination = self["destination"] as? String else {
            return nil
        }
        return AppDestination(rawValue: rawDestination)
    }
}
