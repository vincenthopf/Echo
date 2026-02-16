import SwiftUI

struct OnboardingModelSelectionView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.colorScheme) private var colorScheme

    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var selectedModel: (any TranscriptionModel)? = OnboardingModelPicker.recommendedModel()
    @State private var showModelDownload = false
    @State private var modelSelectionError: String?

    private var recommendedModels: [any TranscriptionModel] {
        OnboardingModelPicker.recommendedOptions()
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                OnboardingBackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        Spacer().frame(height: 20)

                        VStack(spacing: 30) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "brain")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)

                            VStack(spacing: 12) {
                                Text("Choose Your AI Model")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                                Text("Select the transcription model that best fits your needs. You can always change this later in settings.")
                                    .font(.body)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }

                        if recommendedModels.isEmpty {
                            Text("No onboarding model is currently available.")
                                .font(.body)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(recommendedModels.indices, id: \.self) { index in
                                    let model = recommendedModels[index]
                                    ModelSelectionCard(
                                        model: model,
                                        isSelected: selectedModel?.name == model.name,
                                        isRecommended: index == 0,
                                        onSelect: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedModel = model
                                                modelSelectionError = nil
                                            }
                                        }
                                    )
                                    .accessibilityIdentifier("onboarding.modelSelection.\(model.name)")
                                }
                            }
                            .frame(maxWidth: min(geometry.size.width * 0.7, 500))
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }

                        if let modelSelectionError {
                            Text(modelSelectionError)
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.9))
                        }

                        VStack(spacing: 16) {
                            Button(action: {
                                guard selectedModel != nil else {
                                    modelSelectionError = "Please select a model to continue."
                                    return
                                }
                                withAnimation {
                                    showModelDownload = true
                                }
                            }) {
                                Text(buttonTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 300, height: 50)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .accessibilityIdentifier("onboarding.modelSelection.continue")

                            SkipButton(text: "Skip for now", colorScheme: colorScheme) {
                                withAnimation {
                                    showModelDownload = true
                                }
                            }
                        }
                        .opacity(opacity)

                        Spacer().frame(height: 40)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if showModelDownload {
                OnboardingModelDownloadView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    selectedModel: selectedModel
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onAppear { animateIn() }
    }

    private var buttonTitle: String {
        if let selectedModel {
            return "Continue with \(selectedModel.displayName)"
        }
        return "Continue"
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }
}

// MARK: - Model Selection Card
struct ModelSelectionCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let model: any TranscriptionModel
    let isSelected: Bool
    let isRecommended: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(modelColor.opacity(0.2))
                            .frame(width: 50, height: 50)

                        Image(systemName: modelIcon)
                            .font(.system(size: 24))
                            .foregroundColor(modelColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(model.displayName)
                                .font(.headline)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            if isRecommended {
                                Text("RECOMMENDED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.green)
                                    .cornerRadius(4)
                            }
                        }

                        Text(modelSubtitle)
                            .font(.caption)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .accentColor : Tokens.Colors.textTertiary(for: colorScheme))
                }

                Divider().background(Tokens.Colors.border(for: colorScheme))

                HStack(spacing: 20) {
                    if let localModel = model as? LocalModel {
                        StatItem(label: "Size", value: localModel.size, icon: "square.stack.3d.down.right")
                        StatItem(label: "Languages", value: languageCount, icon: "globe")
                    } else if let parakeetModel = model as? ParakeetModel {
                        StatItem(label: "Size", value: parakeetModel.size, icon: "square.stack.3d.down.right")
                        StatItem(label: "Languages", value: languageCount, icon: "globe")
                    }
                }

                Divider().background(Tokens.Colors.border(for: colorScheme))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(modelFeatures, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10))
                                .foregroundColor(.green)

                            Text(feature)
                                .font(.caption)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            Spacer()
                        }
                    }
                }

                Divider().background(Tokens.Colors.border(for: colorScheme))

                HStack(spacing: 20) {
                    if let localModel = model as? LocalModel {
                        performanceIndicator(label: "Speed", value: localModel.speed)
                        performanceIndicator(label: "Accuracy", value: localModel.accuracy)
                        ramUsageLabel(gb: localModel.ramUsage)
                    } else if let parakeetModel = model as? ParakeetModel {
                        performanceIndicator(label: "Speed", value: parakeetModel.speed)
                        performanceIndicator(label: "Accuracy", value: parakeetModel.accuracy)
                        ramUsageLabel(gb: parakeetModel.ramUsage)
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    Tokens.Colors.elevated(for: colorScheme)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentColor, lineWidth: 2)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Tokens.Colors.border(for: colorScheme).opacity(isSelected ? 0 : 1), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : .clear, radius: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var modelIcon: String {
        model is ParakeetModel ? "waveform.badge.mic" : "cpu"
    }

    private var modelColor: Color {
        model is ParakeetModel ? .blue : .purple
    }

    private var modelSubtitle: String {
        if model.name.contains("parakeet") {
            return "NVIDIA's Parakeet V3 model with multilingual support across English and 25 European languages."
        }
        return "OpenAI's Whisper model optimized for speed and accuracy."
    }

    private var languageCount: String {
        let count = model.supportedLanguages.count
        return count > 20 ? "Multilingual" : "\(count) languages"
    }

    private var modelFeatures: [String] {
        if model is ParakeetModel {
            return [
                "Lightning-fast transcription",
                "Multilingual support (English + 25 European languages)",
                "Optimized for Apple Silicon",
                "Works completely offline"
            ]
        }
        return [
            "High-quality transcription",
            "Supports 90+ languages",
            "Quantized for efficiency",
            "Works completely offline"
        ]
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

struct StatItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                Text(value)
                    .font(.caption)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
            }
        }
    }
}
