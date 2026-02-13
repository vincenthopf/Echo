import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var whisperState: WhisperState
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @EnvironmentObject var menuBarManager: MenuBarManager
    @State private var isHovered = false

    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @ObservedObject private var sessionManager = PowerModeSessionManager.shared

    var body: some View {
        VStack {
            // Active Profile Status Section
            if let activeConfig = powerModeManager.activeConfiguration {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if activeConfig.emoji.shouldRenderAsSFSymbol {
                            Image(systemName: activeConfig.emoji)
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)
                        } else {
                            Text(activeConfig.emoji)
                                .font(.system(size: 16))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(activeConfig.name)
                                .font(.system(size: 13, weight: .semibold))

                            if let source = sessionManager.activationSource {
                                Text(source.statusString())
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                Divider()
            }


            Menu {
                ForEach(whisperState.usableModels, id: \.id) { model in
                    Button {
                        Task {
                            await whisperState.setDefaultTranscriptionModel(model)
                        }
                    } label: {
                        HStack {
                            Text(model.displayName)
                            if whisperState.currentTranscriptionModel?.id == model.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                Button("Manage Models") {
                    // Set the selected tab to Transcription before opening Settings
                    UserDefaults.standard.set(SettingsTab.transcription.rawValue, forKey: "selectedSettingsTab")
                    menuBarManager.openMainWindowAndNavigate(to: .settings)
                }
            } label: {
                HStack {
                    Text("Transcription Model: \(whisperState.currentTranscriptionModel?.displayName ?? "None")")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
            LanguageSelectionView(whisperState: whisperState, displayMode: .menuItem, whisperPrompt: whisperState.whisperPrompt)

            Divider()
            
            Button("Retry Last Transcription") {
                LastTranscriptionService.retryLastTranscription(from: whisperState.modelContext, whisperState: whisperState)
            }
            
            Button("Copy Last Transcription") {
                LastTranscriptionService.copyLastTranscription(from: whisperState.modelContext)
            }

            Button("Open App") {
                menuBarManager.openMainWindowAndNavigate(to: .dashboard)
            }

            Button("Help and Support") {
                EmailSupport.openSupportEmail()
            }
            
            Divider()
            
            Button("Quit Echo") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
