import Foundation

enum OnboardingModelPicker {
    static func recommendedModel() -> (any TranscriptionModel)? {
        if let overrideName = ProcessInfo.processInfo.environment["VOICEINK_ONBOARDING_MODEL_OVERRIDE"],
           let overriddenModel = model(named: overrideName) {
            return overriddenModel
        }

        return recommendedModel(
            isAppleSilicon: SystemInfoService.isAppleSilicon(),
            isIntel: SystemInfoService.isIntelMac()
        )
    }

    static func recommendedModel(isAppleSilicon: Bool, isIntel: Bool) -> (any TranscriptionModel)? {
        if isAppleSilicon {
            return model(named: "parakeet-tdt-0.6b-v3")
        }

        if isIntel {
            return model(named: "ggml-large-v3-turbo-q5_0")
        }

        return firstLocalModel() ?? PredefinedModels.models.first
    }

    static func recommendedOptions() -> [any TranscriptionModel] {
        var options: [any TranscriptionModel] = []
        if let primary = recommendedModel() {
            options.append(primary)
        }

        if let localFallback = model(named: "ggml-large-v3-turbo-q5_0"), !containsModel(named: localFallback.name, in: options) {
            options.append(localFallback)
        }
        if let parakeet = model(named: "parakeet-tdt-0.6b-v3"), !containsModel(named: parakeet.name, in: options) {
            options.append(parakeet)
        }
        if let turbo = model(named: "ggml-large-v3-turbo-q5_0"), !containsModel(named: turbo.name, in: options) {
            options.append(turbo)
        }

        return options
    }

    private static func model(named name: String) -> (any TranscriptionModel)? {
        PredefinedModels.models.first { $0.name == name }
    }

    private static func firstLocalModel() -> (any TranscriptionModel)? {
        PredefinedModels.models.first { $0.provider == .local }
    }

    private static func containsModel(named name: String, in models: [any TranscriptionModel]) -> Bool {
        models.contains { $0.name == name }
    }
}
