import SwiftUI

/// Main Settings window with tabbed interface for all app preferences
struct SettingsWindowView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var enhancementService: AIEnhancementService

    @AppStorage("selectedSettingsTab") private var selectedTab = SettingsTab.recording

    var body: some View {
        TabView(selection: $selectedTab) {
            RecordingSettingsView()
                .environmentObject(hotkeyManager)
                .environmentObject(whisperState)
                .tabItem {
                    Label("Recording", systemImage: "mic.circle")
                }
                .tag(SettingsTab.recording)

            TranscriptionSettingsView(whisperState: whisperState)
                .environmentObject(enhancementService)
                .tabItem {
                    Label("Transcription", systemImage: "waveform")
                }
                .tag(SettingsTab.transcription)

            OutputSettingsView()
                .environmentObject(enhancementService)
                .tabItem {
                    Label("Output", systemImage: "arrow.up.doc")
                }
                .tag(SettingsTab.output)

            IntelligenceSettingsView()
                .tabItem {
                    Label("Intelligence", systemImage: "sparkles")
                }
                .tag(SettingsTab.intelligence)

            GeneralSettingsView()
                .environmentObject(updaterViewModel)
                .environmentObject(hotkeyManager)
                .environmentObject(whisperState)
                .environmentObject(enhancementService)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

/// Enum representing available settings tabs
enum SettingsTab: String, Codable, CaseIterable, Identifiable {
    case recording = "Recording"
    case transcription = "Transcription"
    case output = "Output"
    case intelligence = "Intelligence"
    case general = "General"

    var id: String { rawValue }
}
