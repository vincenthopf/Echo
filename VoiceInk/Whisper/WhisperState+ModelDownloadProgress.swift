import Foundation

struct ModelDownloadProgressState: Equatable {
    let fraction: Double
    let phase: String
    let isEstimated: Bool
}

extension WhisperState {
    func downloadProgressState(for model: any TranscriptionModel) -> ModelDownloadProgressState? {
        switch model.provider {
        case .local:
            return localModelProgressState(modelName: model.name)
        case .parakeet:
            return parakeetProgressState(modelName: model.name)
        default:
            return nil
        }
    }

    private func localModelProgressState(modelName: String) -> ModelDownloadProgressState? {
        Self.resolveLocalProgressState(modelName: modelName, downloadProgress: downloadProgress)
    }

    private func parakeetProgressState(modelName: String) -> ModelDownloadProgressState? {
        Self.resolveParakeetProgressState(
            modelName: modelName,
            downloadProgress: downloadProgress,
            isDownloading: parakeetDownloadStates[modelName] == true
        )
    }

    static func resolveLocalProgressState(
        modelName: String,
        downloadProgress: [String: Double]
    ) -> ModelDownloadProgressState? {
        let mainKey = modelName + "_main"
        let coreMLKey = modelName + "_coreml"
        let supportsCoreML = !modelName.contains("q5") && !modelName.contains("q8")

        guard downloadProgress[mainKey] != nil || downloadProgress[coreMLKey] != nil else {
            return nil
        }

        let main = downloadProgress[mainKey] ?? 0
        let coreML = supportsCoreML ? (downloadProgress[coreMLKey] ?? 0) : 0
        let fraction = supportsCoreML ? (main * 0.5 + coreML * 0.5) : main
        let phase = supportsCoreML && downloadProgress[coreMLKey] != nil
            ? "Downloading Core ML Model for \(modelName)"
            : "Downloading \(modelName) Model"

        return ModelDownloadProgressState(
            fraction: max(0, min(1, fraction)),
            phase: phase,
            isEstimated: false
        )
    }

    static func resolveParakeetProgressState(
        modelName: String,
        downloadProgress: [String: Double],
        isDownloading: Bool
    ) -> ModelDownloadProgressState? {
        guard isDownloading || downloadProgress[modelName] != nil else {
            return nil
        }
        return ModelDownloadProgressState(
            fraction: max(0, min(1, downloadProgress[modelName] ?? 0)),
            phase: "Downloading \(modelName) Model",
            isEstimated: true
        )
    }
}
