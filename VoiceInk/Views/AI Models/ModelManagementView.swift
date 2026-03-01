import SwiftUI
import SwiftData
import AppKit
import UniformTypeIdentifiers

enum ModelFilter: String, CaseIterable, Identifiable {
    case recommended = "Recommended"
    case local = "Local"
    case cloud = "Cloud"
    case custom = "Custom"
    var id: String { self.rawValue }
}

struct ModelManagementView: View {
    @ObservedObject var whisperState: WhisperState
    @State private var customModelToEdit: CustomCloudModel?
    @StateObject private var aiService = AIService()
    @StateObject private var customModelManager = CustomModelManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var whisperPrompt = WhisperPrompt()
    @ObservedObject private var warmupCoordinator = WhisperModelWarmupCoordinator.shared

    @State private var selectedFilter: ModelFilter = .recommended
    @State private var isShowingSettings = false

    // State for the unified alert
    @State private var isShowingDeleteAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var deleteActionClosure: () -> Void = {}

    var body: some View {
        ScrollView {
            mainContent
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Tokens.Colors.background(for: colorScheme))
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Delete"), action: deleteActionClosure),
                secondaryButton: .cancel()
            )
        }
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
            defaultModelSection
            languageSelectionSection
            availableModelsSection
        }
        .padding(.horizontal, 40)
        .padding(.vertical, Tokens.Spacing.xl)
    }
    
    private var defaultModelSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
            Text("Default Model")
                .font(Tokens.Typography.label)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            Text(whisperState.currentTranscriptionModel?.displayName ?? "No model selected")
                .font(Tokens.Typography.heading2)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
        }
        .padding(Tokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }
    
    private var languageSelectionSection: some View {
        LanguageSelectionView(whisperState: whisperState, displayMode: .full, whisperPrompt: whisperPrompt)
    }
    
    private var availableModelsSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            HStack {
                // Modern compact pill switcher
                HStack(spacing: Tokens.Spacing.md) {
                    ForEach(ModelFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedFilter = filter
                                isShowingSettings = false
                            }
                        }) {
                            Text(filter.rawValue)
                                .font(Tokens.Typography.bodyMedium)
                                .foregroundColor(selectedFilter == filter ? Tokens.Colors.textPrimary(for: colorScheme) : Tokens.Colors.textSecondary(for: colorScheme))
                                .padding(.horizontal, Tokens.Spacing.lg)
                                .padding(.vertical, Tokens.Spacing.sm)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == filter ? Tokens.Colors.orangeSoft(for: colorScheme) : Tokens.Colors.elevated(for: colorScheme))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedFilter == filter ? Tokens.Colors.orange.opacity(0.5) : Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isShowingSettings.toggle()
                    }
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isShowingSettings ? Tokens.Colors.orange : Tokens.Colors.textSecondary(for: colorScheme))
                        .padding(Tokens.Spacing.md)
                        .background(
                            Circle()
                                .fill(isShowingSettings ? Tokens.Colors.orangeSoft(for: colorScheme) : Tokens.Colors.elevated(for: colorScheme))
                        )
                        .overlay(
                            Circle()
                                .stroke(isShowingSettings ? Tokens.Colors.orange.opacity(0.5) : Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, Tokens.Spacing.md)
            
            if isShowingSettings {
                ModelSettingsView(whisperPrompt: whisperPrompt)
            } else {
                VStack(spacing: Tokens.Spacing.md) {
                    ForEach(filteredModels, id: \.id) { model in
                        let isWarming = (model as? LocalModel).map { localModel in
                            warmupCoordinator.isWarming(modelNamed: localModel.name)
                        } ?? false

                        ModelCardRowView(
                            model: model,
                            whisperState: whisperState, 
                            isDownloaded: whisperState.availableModels.contains { $0.name == model.name },
                            isCurrent: whisperState.currentTranscriptionModel?.name == model.name,
                            downloadProgress: whisperState.downloadProgress,
                            modelURL: whisperState.availableModels.first { $0.name == model.name }?.url,
                            isWarming: isWarming,
                            deleteAction: {
                                if let customModel = model as? CustomCloudModel {
                                    alertTitle = "Delete Custom Model"
                                    alertMessage = "Are you sure you want to delete the custom model '\(customModel.displayName)'?"
                                    deleteActionClosure = {
                                        customModelManager.removeCustomModel(withId: customModel.id)
                                        whisperState.refreshAllAvailableModels()
                                    }
                                    isShowingDeleteAlert = true
                                } else if let downloadedModel = whisperState.availableModels.first(where: { $0.name == model.name }) {
                                    alertTitle = "Delete Model"
                                    alertMessage = "Are you sure you want to delete the model '\(downloadedModel.name)'?"
                                    deleteActionClosure = {
                                        Task {
                                            await whisperState.deleteModel(downloadedModel)
                                        }
                                    }
                                    isShowingDeleteAlert = true
                                }
                            },
                            setDefaultAction: {
                                Task {
                                    await whisperState.setDefaultTranscriptionModel(model)
                                }
                            },
                            downloadAction: {
                                if let localModel = model as? LocalModel {
                                    Task { await whisperState.downloadModel(localModel) }
                                }
                            },
                            editAction: model.provider == .custom ? { customModel in
                                customModelToEdit = customModel
                            } : nil
                        )
                    }
                    
                    // MARK: - DISABLED: Import Local Model Feature
                    // Uncomment below to re-enable custom Whisper model import
                    /*
                    // Import button as a card at the end of the Local list
                    if selectedFilter == .local {
                        HStack(spacing: 8) {
                            Button(action: { presentImportPanel() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Import Local Model…")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(CardBackground(isSelected: false))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)

                            InfoTip(
                                title: "Import local Whisper models",
                                message: "Add a custom fine-tuned whisper model to use with Echo. Select the downloaded .bin file.",
                                learnMoreURL: "https://echo.vjh.io/docs"
                            )
                            .help("Read more about custom local models")
                        }
                    }
                    */
                    
                    if selectedFilter == .custom {
                        // Add Custom Model Card at the bottom
                        AddCustomModelCardView(
                            customModelManager: customModelManager,
                            editingModel: customModelToEdit
                        ) {
                            // Refresh the models when a new custom model is added
                            whisperState.refreshAllAvailableModels()
                            customModelToEdit = nil // Clear editing state
                        }
                    }
                }
            }
        }
        .padding(Tokens.Spacing.lg)
    }

    private var filteredModels: [any TranscriptionModel] {
        switch selectedFilter {
        case .recommended:
            return whisperState.allAvailableModels.filter {
                let recommendedNames = ["parakeet-tdt-0.6b-v3", "ggml-large-v3-turbo-q5_0", "whisper-large-v3-turbo"]
                return recommendedNames.contains($0.name)
            }.sorted { model1, model2 in
                let recommendedOrder = ["parakeet-tdt-0.6b-v3", "ggml-large-v3-turbo-q5_0", "whisper-large-v3-turbo"]
                let index1 = recommendedOrder.firstIndex(of: model1.name) ?? Int.max
                let index2 = recommendedOrder.firstIndex(of: model2.name) ?? Int.max
                return index1 < index2
            }
        case .local:
            return whisperState.allAvailableModels.filter { $0.provider == .local || $0.provider == .nativeApple || $0.provider == .parakeet }
        case .cloud:
            let cloudProviders: [ModelProvider] = [.groq, .elevenLabs, .deepgram, .mistral, .gemini]
            return whisperState.allAvailableModels.filter { cloudProviders.contains($0.provider) }
        case .custom:
            return whisperState.allAvailableModels.filter { $0.provider == .custom }
        }
    }

    // MARK: - Import Panel (DISABLED)
    // Uncomment below to re-enable custom Whisper model import
    /*
    private func presentImportPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "bin")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        panel.title = "Select a Whisper ggml .bin model"
        if panel.runModal() == .OK, let url = panel.url {
            Task { @MainActor in
                await whisperState.importLocalModel(from: url)
            }
        }
    }
    */
}
