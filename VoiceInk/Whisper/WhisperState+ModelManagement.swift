import Foundation
import SwiftUI

@MainActor
extension WhisperState {
    func isNativeModelSupported(_ model: any TranscriptionModel) -> Bool {
        guard model.provider == .nativeApple else { return true }
        if #available(macOS 26, *) {
            return true
        }
        return false
    }

    // Loads the default transcription model from UserDefaults
    func loadCurrentTranscriptionModel() {
        if let savedModelName = UserDefaults.standard.string(forKey: "CurrentTranscriptionModel"),
           let savedModel = allAvailableModels.first(where: { $0.name == savedModelName }) {
            if isNativeModelSupported(savedModel) {
                currentTranscriptionModel = savedModel
            }
        } else if let savedModelName = UserDefaults.standard.string(forKey: "CurrentTranscriptionModel") {
            // Migrate users from removed local models to the recommended model
            let removedLocalModels = ["ggml-tiny", "ggml-tiny.en", "ggml-base", "ggml-base.en",
                                       "ggml-small", "ggml-small.en", "ggml-medium", "ggml-medium.en",
                                       "ggml-large-v2"]
            if removedLocalModels.contains(savedModelName),
               let replacement = allAvailableModels.first(where: { $0.name == "ggml-large-v3-turbo-q5_0" }) {
                currentTranscriptionModel = replacement
                UserDefaults.standard.set(replacement.name, forKey: "CurrentTranscriptionModel")
            }
        }
    }

    // Function to set any transcription model as default
    func setDefaultTranscriptionModel(_ model: any TranscriptionModel) {
        guard isNativeModelSupported(model) else {
            Task { @MainActor in
                await NotificationManager.shared.showNotification(
                    title: "Apple Speech requires macOS 26 or later.",
                    type: .warning
                )
            }
            return
        }

        self.currentTranscriptionModel = model
        UserDefaults.standard.set(model.name, forKey: "CurrentTranscriptionModel")
        
        // For cloud models, clear the old loadedLocalModel
        if model.provider != .local {
            self.loadedLocalModel = nil
        }
        
        // Enable transcription for cloud models immediately since they don't need loading
        if model.provider != .local {
            self.isModelLoaded = true
        }
        // Post notification about the model change
        NotificationCenter.default.post(name: .didChangeModel, object: nil, userInfo: ["modelName": model.name])
        NotificationCenter.default.post(name: .AppSettingsDidChange, object: nil)
    }
    
    func refreshAllAvailableModels() {
        let currentModelName = currentTranscriptionModel?.name
        var models = PredefinedModels.models

        // Append dynamically discovered local models (imported .bin files) with minimal metadata
        for whisperModel in availableModels {
            if !models.contains(where: { $0.name == whisperModel.name }) {
                let importedModel = ImportedLocalModel(fileBaseName: whisperModel.name)
                models.append(importedModel)
            }
        }

        allAvailableModels = models

        // Preserve current selection by name (IDs may change for dynamic models)
        if let currentName = currentModelName,
           let updatedModel = allAvailableModels.first(where: { $0.name == currentName }) {
            setDefaultTranscriptionModel(updatedModel)
        }
    }
} 
