import SwiftUI

/// Main Settings window with tabbed interface for all app preferences
struct SettingsWindowView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService

    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("selectedSettingsTab") private var selectedTab = SettingsTab.general

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .environmentObject(updaterViewModel)
                .environmentObject(hotkeyManager)
                .environmentObject(whisperState)
                .environmentObject(enhancementService)
                .accessibilityIdentifier("settings.tab.general")
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)

            RecordingSettingsView()
                .environmentObject(hotkeyManager)
                .environmentObject(whisperState)
                .accessibilityIdentifier("settings.tab.recording")
                .tabItem {
                    Label("Recording", systemImage: "mic.circle")
                }
                .tag(SettingsTab.recording)

            TranscriptionSettingsView(whisperState: whisperState)
                .environmentObject(enhancementService)
                .accessibilityIdentifier("settings.tab.transcription")
                .tabItem {
                    Label("Transcription", systemImage: "waveform")
                }
                .tag(SettingsTab.transcription)

            IntelligenceSettingsView()
                .environmentObject(enhancementService)
                .accessibilityIdentifier("settings.tab.intelligence")
                .tabItem {
                    Label("Intelligence", systemImage: "wand.and.stars")
                }
                .tag(SettingsTab.intelligence)
        }
        .accessibilityIdentifier("settings.tabs")
        .frame(minWidth: 700, minHeight: 500)
        .background(Tokens.Colors.elevated(for: colorScheme))
    }
}

/// Enum representing available settings tabs
enum SettingsTab: String, Codable, CaseIterable, Identifiable {
    case general = "General"
    case recording = "Recording"
    case transcription = "Transcription"
    case intelligence = "Intelligence"

    var id: String { rawValue }
}
