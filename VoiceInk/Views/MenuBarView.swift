import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var whisperState: WhisperState
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @EnvironmentObject var menuBarManager: MenuBarManager
    @EnvironmentObject var enhancementService: AIEnhancementService
    @EnvironmentObject var aiService: AIService
    @State private var menuRefreshTrigger = false  // Added to force menu updates
    @State private var isHovered = false
    @Environment(\.openSettings) private var openSettings

    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @ObservedObject private var sessionManager = PowerModeSessionManager.shared

    var body: some View {
        VStack {
            // Active Profile Status Section
            if let activeConfig = powerModeManager.activeConfiguration {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(activeConfig.emoji)
                            .font(.system(size: 16))

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
                    // Set the selected tab to Transcription before opening Settings window
                    UserDefaults.standard.set(SettingsTab.transcription.rawValue, forKey: "selectedSettingsTab")
                    openSettings()
                }
            } label: {
                HStack {
                    Text("Transcription Model: \(whisperState.currentTranscriptionModel?.displayName ?? "None")")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
            Divider()

            Toggle("Intelligent Transformation", isOn: $enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(enhancementService.allPrompts) { prompt in
                    Button {
                        enhancementService.setActivePrompt(prompt)
                    } label: {
                        HStack {
                            Image(systemName: prompt.icon.rawValue)
                                .foregroundColor(.accentColor)
                            Text(prompt.title)
                            if enhancementService.selectedPromptId == prompt.id {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Prompt: \(enhancementService.activePrompt?.title ?? "None")")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            .disabled(!enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(aiService.connectedProviders, id: \.self) { provider in
                    Button {
                        aiService.selectedProvider = provider
                    } label: {
                        HStack {
                            Text(provider.rawValue)
                            if aiService.selectedProvider == provider {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                if aiService.connectedProviders.isEmpty {
                    Text("No providers connected")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Button("Manage AI Providers") {
                    menuBarManager.openMainWindowAndNavigate(to: "Transformation")
                }
            } label: {
                HStack {
                    Text("AI Provider: \(aiService.selectedProvider.rawValue)")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            .disabled(!enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(aiService.availableModels, id: \.self) { model in
                    Button {
                        aiService.selectModel(model)
                    } label: {
                        HStack {
                            Text(model)
                            if aiService.currentModel == model {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                if aiService.availableModels.isEmpty {
                    Text("No models available")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Button("Manage AI Models") {
                    menuBarManager.openMainWindowAndNavigate(to: "Transformation")
                }
            } label: {
                HStack {
                    Text("AI Model: \(aiService.currentModel)")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            .disabled(!enhancementService.isEnhancementEnabled)
            
            LanguageSelectionView(whisperState: whisperState, displayMode: .menuItem, whisperPrompt: whisperState.whisperPrompt)
            
            Menu("Additional") {
                Button {
                    enhancementService.useClipboardContext.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
                        Text("Clipboard Context")
                        Spacer()
                        if enhancementService.useClipboardContext {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(!enhancementService.isEnhancementEnabled)
                
                Button {
                    enhancementService.useScreenCaptureContext.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
                        Text("Context Awareness")
                        Spacer()
                        if enhancementService.useScreenCaptureContext {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(!enhancementService.isEnhancementEnabled)
            }
            .id("additional-menu-\(menuRefreshTrigger)")
            
            Divider()
            
            Button("Retry Last Transcription") {
                LastTranscriptionService.retryLastTranscription(from: whisperState.modelContext, whisperState: whisperState)
            }
            
            Button("Copy Last Transcription") {
                LastTranscriptionService.copyLastTranscription(from: whisperState.modelContext)
            }

            Button("Open App") {
                menuBarManager.openMainWindowAndNavigate(to: "Settings")
            }
            .keyboardShortcut(",", modifiers: .command)

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
