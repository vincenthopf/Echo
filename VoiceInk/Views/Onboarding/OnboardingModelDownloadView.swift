import SwiftUI

struct OnboardingModelDownloadView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var whisperState: WhisperState
    @Environment(\.colorScheme) private var colorScheme

    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var isDownloading = false
    @State private var isModelSet = false
    @State private var showTutorial = false
    @State private var errorMessage: String?
    private let launchArguments = ProcessInfo.processInfo.arguments

    var selectedModel: (any TranscriptionModel)?

    private var resolvedModel: (any TranscriptionModel)? {
        selectedModel ?? OnboardingModelPicker.recommendedModel()
    }

    private var progressState: ModelDownloadProgressState? {
        guard let model = resolvedModel else { return nil }
        return whisperState.downloadProgressState(for: model)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                OnboardingBackgroundView()

                VStack(spacing: 40) {
                    VStack(spacing: 30) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 100, height: 100)

                            if isModelSet {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.accentColor)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Image(systemName: "brain")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)

                        VStack(spacing: 12) {
                            Text("Download AI Model")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            Text("We'll download the optimized model to get you started.")
                                .font(.body)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)
                    }

                    if let resolvedModel {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .center, spacing: 8) {
                                Text(resolvedModel.displayName)
                                    .font(.headline)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                                Text(modelDetailsText(for: resolvedModel))
                                    .font(.caption)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            }
                            .frame(maxWidth: .infinity)

                            Divider()
                                .background(Tokens.Colors.border(for: colorScheme))

                            HStack(spacing: 20) {
                                performanceIndicator(label: "Speed", value: modelSpeed(for: resolvedModel))
                                performanceIndicator(label: "Accuracy", value: modelAccuracy(for: resolvedModel))
                                ramUsageLabel(gb: modelRAM(for: resolvedModel))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)

                            if let progressState {
                                DownloadProgressView(progressState: progressState)
                                    .transition(.opacity)
                                    .accessibilityIdentifier("onboarding.download.progress")
                            }

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(24)
                        .frame(width: min(geometry.size.width * 0.6, 420))
                        .background(Tokens.Colors.elevated(for: colorScheme))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                        .scaleEffect(scale)
                        .opacity(opacity)
                    } else {
                        Text("No compatible model is available on this device.")
                            .font(.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    }

                    VStack(spacing: 16) {
                        Button(action: handleAction) {
                            Text(getButtonTitle())
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 230, height: 50)
                                .background(Color.accentColor)
                                .cornerRadius(25)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(isDownloading || resolvedModel == nil)
                        .accessibilityIdentifier("onboarding.modelDownload.action")

                        if !isModelSet {
                            SkipButton(text: "Skip for now", colorScheme: colorScheme) {
                                withAnimation {
                                    showTutorial = true
                                }
                            }
                        }
                    }
                    .opacity(opacity)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(width: min(geometry.size.width * 0.8, 600))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }

            if showTutorial {
                OnboardingTutorialView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onAppear {
            animateIn()
            seedUITestProgressIfNeeded()
            refreshModelStatus()
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }

    private func seedUITestProgressIfNeeded() {
        guard launchArguments.contains("-uiTestMode") else { return }

        if launchArguments.contains("-uiTestMockParakeetProgress") {
            whisperState.downloadProgress["parakeet-tdt-0.6b-v3"] = 0.42
        }

        if launchArguments.contains("-uiTestMockLocalProgress") {
            whisperState.downloadProgress["ggml-base.en_main"] = 0.30
            whisperState.downloadProgress["ggml-base.en_coreml"] = 0.50
        }
    }

    private func refreshModelStatus() {
        guard let resolvedModel else {
            isModelSet = false
            return
        }
        let isInstalled = whisperState.usableModels.contains { $0.name == resolvedModel.name }
        isModelSet = isInstalled && whisperState.currentTranscriptionModel?.name == resolvedModel.name
    }

    private func handleAction() {
        errorMessage = nil

        guard let resolvedModel else {
            errorMessage = "No model available for onboarding."
            return
        }

        if isModelSet {
            withAnimation {
                showTutorial = true
            }
            return
        }

        if whisperState.usableModels.contains(where: { $0.name == resolvedModel.name }) {
            if let modelToSet = whisperState.allAvailableModels.first(where: { $0.name == resolvedModel.name }) {
                whisperState.setDefaultTranscriptionModel(modelToSet)
                withAnimation {
                    isModelSet = true
                }
            }
            return
        }

        Task {
            isDownloading = true
            defer { isDownloading = false }

            if let localModel = resolvedModel as? LocalModel {
                await whisperState.downloadModel(localModel)
            } else if let parakeetModel = resolvedModel as? ParakeetModel {
                await whisperState.downloadParakeetModel(parakeetModel)
            }

            let isInstalled = whisperState.usableModels.contains { $0.name == resolvedModel.name }
            guard isInstalled else {
                errorMessage = "Download failed. Please retry."
                return
            }

            guard let modelToSet = whisperState.allAvailableModels.first(where: { $0.name == resolvedModel.name }) else {
                errorMessage = "Model downloaded but could not be activated."
                return
            }

            whisperState.setDefaultTranscriptionModel(modelToSet)
            withAnimation {
                isModelSet = true
            }
        }
    }

    private func getButtonTitle() -> String {
        if isModelSet {
            return "Continue"
        }
        if isDownloading {
            return "Downloading..."
        }
        if let resolvedModel, whisperState.usableModels.contains(where: { $0.name == resolvedModel.name }) {
            return "Set as Default"
        }
        return "Download Model"
    }

    private func modelDetailsText(for model: any TranscriptionModel) -> String {
        if let localModel = model as? LocalModel {
            return "\(localModel.size) • \(localModel.language)"
        }
        if let parakeetModel = model as? ParakeetModel {
            return "\(parakeetModel.size) • Multilingual"
        }
        return model.displayName
    }

    private func modelSpeed(for model: any TranscriptionModel) -> Double {
        if let localModel = model as? LocalModel { return localModel.speed }
        if let parakeetModel = model as? ParakeetModel { return parakeetModel.speed }
        return 0
    }

    private func modelAccuracy(for model: any TranscriptionModel) -> Double {
        if let localModel = model as? LocalModel { return localModel.accuracy }
        if let parakeetModel = model as? ParakeetModel { return parakeetModel.accuracy }
        return 0
    }

    private func modelRAM(for model: any TranscriptionModel) -> Double {
        if let localModel = model as? LocalModel { return localModel.ramUsage }
        if let parakeetModel = model as? ParakeetModel { return parakeetModel.ramUsage }
        return 0
    }

    private func performanceIndicator(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Double(index) / 5.0 <= value ? Color.accentColor : Tokens.Colors.textTertiary(for: colorScheme).opacity(0.5))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }

    private func ramUsageLabel(gb: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RAM")
                .font(.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

            Text(String(format: "%.1f GB", gb))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
        }
    }
}
