import SwiftUI

/// Main Settings window with tabbed interface for all app preferences
struct SettingsWindowView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService

    @AppStorage("selectedSettingsTab") private var selectedTab = SettingsTab.general

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .environmentObject(updaterViewModel)
                .environmentObject(hotkeyManager)
                .environmentObject(whisperState)
                .environmentObject(enhancementService)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)

            ModelManagementView(whisperState: whisperState)
                .environmentObject(enhancementService)
                .tabItem {
                    Label("Models", systemImage: "brain.head.profile")
                }
                .tag(SettingsTab.models)

            PermissionsView()
                .tabItem {
                    Label("Permissions", systemImage: "shield.fill")
                }
                .tag(SettingsTab.permissions)

            AudioInputSettingsView()
                .tabItem {
                    Label("Audio Input", systemImage: "mic.fill")
                }
                .tag(SettingsTab.audioInput)

            DictionarySettingsView(whisperPrompt: whisperState.whisperPrompt)
                .tabItem {
                    Label("Dictionary", systemImage: "character.book.closed.fill")
                }
                .tag(SettingsTab.dictionary)

            EnhancementSettingsView()
                .environmentObject(enhancementService)
                .tabItem {
                    Label("Enhancement", systemImage: "wand.and.stars")
                }
                .tag(SettingsTab.enhancement)
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

/// Enum representing available settings tabs
enum SettingsTab: String, Codable, CaseIterable, Identifiable {
    case general = "General"
    case models = "Models"
    case permissions = "Permissions"
    case audioInput = "Audio Input"
    case dictionary = "Dictionary"
    case enhancement = "Enhancement"

    var id: String { rawValue }
}
