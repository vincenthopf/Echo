import SwiftUI

struct OnboardingModelSelectionView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var selectedModel: any TranscriptionModel = PredefinedModels.models.first { $0.name == "parakeet-tdt-0.6b-v3" }!
    @State private var showModelDownload = false

    // Recommended models for onboarding
    private let recommendedModels: [any TranscriptionModel] = [
        PredefinedModels.models.first { $0.name == "parakeet-tdt-0.6b-v3" }!,
        PredefinedModels.models.first { $0.name == "ggml-large-v3-turbo-q5_0" }!
    ]

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // Reusable background
                OnboardingBackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        Spacer()
                            .frame(height: 20)

                        // Icon and title
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
                                    .foregroundColor(.white)

                                Text("Select the transcription model that best fits your needs. You can always change this later in settings.")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }

                        // Model cards
                        VStack(spacing: 16) {
                            ForEach(recommendedModels.indices, id: \.self) { index in
                                ModelSelectionCard(
                                    model: recommendedModels[index],
                                    isSelected: selectedModel.name == recommendedModels[index].name,
                                    isRecommended: index == 0, // First model (Parakeet V3) is recommended
                                    onSelect: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedModel = recommendedModels[index]
                                        }
                                    }
                                )
                            }
                        }
                        .frame(maxWidth: min(geometry.size.width * 0.7, 500))
                        .scaleEffect(scale)
                        .opacity(opacity)

                        // Action button
                        VStack(spacing: 16) {
                            Button(action: {
                                withAnimation {
                                    showModelDownload = true
                                }
                            }) {
                                Text("Continue with \(selectedModel.displayName)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 300, height: 50)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                            .buttonStyle(ScaleButtonStyle())

                            SkipButton(text: "Skip for now") {
                                withAnimation {
                                    showModelDownload = true
                                }
                            }
                        }
                        .opacity(opacity)

                        Spacer()
                            .frame(height: 40)
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
        .onAppear {
            animateIn()
        }
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
    let model: any TranscriptionModel
    let isSelected: Bool
    let isRecommended: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon, title, and badge
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
                                .foregroundColor(.white)

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
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .accentColor : .white.opacity(0.3))
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Model stats
                HStack(spacing: 20) {
                    if let localModel = model as? LocalModel {
                        StatItem(label: "Size", value: localModel.size, icon: "square.stack.3d.down.right")
                        StatItem(label: "Languages", value: languageCount, icon: "globe")
                    } else if let parakeetModel = model as? ParakeetModel {
                        StatItem(label: "Size", value: parakeetModel.size, icon: "square.stack.3d.down.right")
                        StatItem(label: "Languages", value: languageCount, icon: "globe")
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(modelFeatures, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10))
                                .foregroundColor(.green)

                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))

                            Spacer()
                        }
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Performance indicators
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
                    Color.black.opacity(0.3)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentColor, lineWidth: 2)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(isSelected ? 0 : 0.1), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : .clear, radius: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var modelIcon: String {
        if model is ParakeetModel {
            return "waveform.badge.mic"
        } else {
            return "cpu"
        }
    }

    private var modelColor: Color {
        if model is ParakeetModel {
            return .blue
        } else {
            return .purple
        }
    }

    private var modelSubtitle: String {
        if model.name.contains("parakeet") {
            return "NVIDIA's Parakeet V3 model with multilingual support across English and 25 European languages."
        } else {
            return "OpenAI's Whisper model optimized for speed and accuracy."
        }
    }

    private var languageCount: String {
        let count = model.supportedLanguages.count
        if count > 20 {
            return "Multilingual"
        } else {
            return "\(count) languages"
        }
    }

    private var modelFeatures: [String] {
        if model is ParakeetModel {
            return [
                "Lightning-fast transcription",
                "Multilingual support (English + 25 European languages)",
                "Optimized for Apple Silicon",
                "Works completely offline"
            ]
        } else {
            return [
                "High-quality transcription",
                "Supports 90+ languages",
                "Quantized for efficiency",
                "Works completely offline"
            ]
        }
    }

    private func performanceIndicator(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Double(index) / 5.0 <= value ? Color.accentColor : Color.white.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }

    private func ramUsageLabel(gb: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RAM")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            Text(String(format: "%.1f GB", gb))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingModelSelectionView(hasCompletedOnboarding: .constant(false))
}
