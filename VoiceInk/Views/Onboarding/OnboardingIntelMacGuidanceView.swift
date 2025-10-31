import SwiftUI

struct OnboardingIntelMacGuidanceView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var selectedOption: TranscriptionOption = .appleSpeech
    @State private var showTutorial = false

    enum TranscriptionOption: String, CaseIterable {
        case appleSpeech = "Apple Speech"
        case cloudServices = "Cloud Services"
        case localModels = "Local Models"

        var icon: String {
            switch self {
            case .appleSpeech: return "waveform.badge.mic"
            case .cloudServices: return "cloud.fill"
            case .localModels: return "cpu"
            }
        }

        var iconColor: Color {
            switch self {
            case .appleSpeech: return .blue
            case .cloudServices: return .purple
            case .localModels: return .gray
            }
        }

        var subtitle: String {
            switch self {
            case .appleSpeech: return "Built into macOS. No setup needed."
            case .cloudServices: return "Lightning-fast processing in the cloud."
            case .localModels: return "Run AI directly on your Mac."
            }
        }

        var features: [FeatureItem] {
            switch self {
            case .appleSpeech:
                return [
                    FeatureItem(text: "Works offline after initial download", isPositive: true),
                    FeatureItem(text: "Free forever—no API keys", isPositive: true),
                    FeatureItem(text: "Optimized for Intel processors", isPositive: true),
                    FeatureItem(text: "Supports 50+ languages", isPositive: true)
                ]
            case .cloudServices:
                return [
                    FeatureItem(text: "Fastest transcription available", isPositive: true),
                    FeatureItem(text: "Multiple provider options", isPositive: true),
                    FeatureItem(text: "Medical & technical vocabularies", isPositive: true),
                    FeatureItem(text: "Requires API keys (free tiers available)", isPositive: true)
                ]
            case .localModels:
                return [
                    FeatureItem(text: "Complete privacy—nothing leaves your Mac", isPositive: true),
                    FeatureItem(text: "Works fully offline", isPositive: true),
                    FeatureItem(text: "Slower on Intel processors", isPositive: false),
                    FeatureItem(text: "Uses significant memory (3-8GB)", isPositive: false)
                ]
            }
        }

        var speedRating: Int {
            switch self {
            case .appleSpeech: return 4
            case .cloudServices: return 5
            case .localModels: return 2
            }
        }

        var accuracyRating: Int {
            switch self {
            case .appleSpeech: return 5
            case .cloudServices: return 5
            case .localModels: return 4
            }
        }

        var isRecommended: Bool {
            return self == .appleSpeech
        }
    }

    struct FeatureItem: Identifiable {
        let id = UUID()
        let text: String
        let isPositive: Bool
    }

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

                                Image(systemName: "speedometer.high")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)

                            VStack(spacing: 12) {
                                Text("Let's optimize for your Mac")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("We've detected you're using an Intel Mac. Here are transcription options that work beautifully with your hardware.")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }

                        // Context card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.accentColor)
                                Text("Quick Context")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }

                            Text("Your Intel Mac runs transcription differently than newer Apple Silicon models. We've selected options that give you the best experience—fast, accurate, and optimized for your processor.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: min(geometry.size.width * 0.7, 500))
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .scaleEffect(scale)
                        .opacity(opacity)

                        // Option cards
                        VStack(spacing: 16) {
                            ForEach(TranscriptionOption.allCases, id: \.self) { option in
                                OptionCard(
                                    option: option,
                                    isSelected: selectedOption == option,
                                    onSelect: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedOption = option
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
                            Button(action: handleContinue) {
                                Text(getButtonTitle())
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                            .buttonStyle(ScaleButtonStyle())

                            Button(action: {
                                withAnimation {
                                    showTutorial = true
                                }
                            }) {
                                Text("Skip for now")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                        }
                        .opacity(opacity)

                        Spacer()
                            .frame(height: 40)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if showTutorial {
                OnboardingTutorialView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onAppear {
            animateIn()
            // Store that user has seen Intel guidance
            UserDefaults.standard.set(true, forKey: "hasSeenIntelMacGuidance")
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }

    private func getButtonTitle() -> String {
        switch selectedOption {
        case .appleSpeech:
            return "Choose Apple Speech"
        case .cloudServices:
            return "Set Up Cloud Service"
        case .localModels:
            return "Download Local Model"
        }
    }

    private func handleContinue() {
        // Store the user's choice
        UserDefaults.standard.set(selectedOption.rawValue, forKey: "onboardingTranscriptionChoice")

        // Navigate based on selection
        withAnimation {
            if selectedOption == .localModels {
                // If they really want local models, show the model download view
                // For now, just proceed to tutorial
                showTutorial = true
            } else {
                // For Apple Speech or Cloud, proceed directly to tutorial
                showTutorial = true
            }
        }
    }
}

// MARK: - Option Card
struct OptionCard: View {
    let option: OnboardingIntelMacGuidanceView.TranscriptionOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon, title, and badge
                HStack(spacing: 12) {
                    Image(systemName: option.icon)
                        .font(.system(size: 28))
                        .foregroundColor(option.iconColor)
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(option.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)

                            if option.isRecommended {
                                Text("RECOMMENDED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.green)
                                    .cornerRadius(4)
                            }
                        }

                        Text(option.subtitle)
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

                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(option.features) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: feature.isPositive ? "checkmark" : "exclamationmark.triangle")
                                .font(.system(size: 10))
                                .foregroundColor(feature.isPositive ? .green : .orange)

                            Text(feature.text)
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
                    PerformanceIndicator(label: "Speed", rating: option.speedRating)
                    PerformanceIndicator(label: "Accuracy", rating: option.accuracyRating)
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
}

// MARK: - Performance Indicator
struct PerformanceIndicator: View {
    let label: String
    let rating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < rating ? Color.accentColor : Color.white.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingIntelMacGuidanceView(hasCompletedOnboarding: .constant(false))
}
