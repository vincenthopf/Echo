import SwiftUI
import AppKit

// MARK: - Cloud Model Card View
struct CloudModelCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let model: CloudModel
    let isCurrent: Bool
    var setDefaultAction: () -> Void

    @EnvironmentObject private var whisperState: WhisperState
    @StateObject private var aiService = AIService()
    @State private var isExpanded = false
    @State private var apiKey = ""
    @State private var isVerifying = false
    @State private var verificationStatus: VerificationStatus = .none
    @State private var isConfiguredState: Bool = false

    enum VerificationStatus {
        case none, verifying, success, failure
    }

    private var isConfigured: Bool {
        guard let savedKey = UserDefaults.standard.string(forKey: "\(providerKey)APIKey") else {
            return false
        }
        return !savedKey.isEmpty
    }

    private var providerKey: String {
        switch model.provider {
        case .groq:
            return "GROQ"
        case .elevenLabs:
            return "ElevenLabs"
        case .deepgram:
            return "Deepgram"
        case .mistral:
            return "Mistral"
        case .gemini:
            return "Gemini"
        case .soniox:
            return "Soniox"
        default:
            return model.provider.rawValue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content
            HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                    headerSection
                    metadataSection
                    descriptionSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                actionSection
            }
            .padding(Tokens.Spacing.lg)

            // Expandable configuration section
            if isExpanded {
                Divider()
                    .padding(.horizontal, Tokens.Spacing.lg)

                configurationSection
                    .padding(Tokens.Spacing.lg)
            }
        }
        .background(isCurrent ? Tokens.Colors.orangeSoft(for: colorScheme) : Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(isCurrent ? Tokens.Colors.orange.opacity(0.5) : Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
        .onAppear {
            loadSavedAPIKey()
            isConfiguredState = isConfigured
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(model.displayName)
                .font(Tokens.Typography.bodyMedium)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            statusBadge

            Spacer()
        }
    }

    private var statusBadge: some View {
        Group {
            if isCurrent {
                Text("Default")
                    .font(Tokens.Typography.labelSmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Tokens.Colors.orange))
                    .foregroundColor(.white)
            } else if isConfiguredState {
                Text("Configured")
                    .font(Tokens.Typography.labelSmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Tokens.Colors.successSoft(for: colorScheme)))
                    .foregroundColor(Tokens.Colors.success)
            } else {
                Text("Setup Required")
                    .font(Tokens.Typography.labelSmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Tokens.Colors.orangeMedium(for: colorScheme)))
                    .foregroundColor(Tokens.Colors.orange)
            }
        }
    }
    
    private var metadataSection: some View {
        HStack(spacing: Tokens.Spacing.md) {
            // Provider
            Label(model.provider.rawValue, systemImage: "cloud")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Language
            Label(model.language, systemImage: "globe")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            Label("Cloud Model", systemImage: "icloud")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Accuracy
            HStack(spacing: 3) {
                Text("Accuracy")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                progressDotsWithNumber(value: model.accuracy * 10)
            }
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
        }
        .lineLimit(1)
    }

    private var descriptionSection: some View {
        Text(model.description)
            .font(Tokens.Typography.caption)
            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, Tokens.Spacing.xs)
    }
    
    private var actionSection: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            if isCurrent {
                Text("Default Model")
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            } else if isConfiguredState {
                Button(action: setDefaultAction) {
                    Text("Set as Default")
                        .font(Tokens.Typography.label)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(Tokens.Colors.orange)
            } else {
                Button(action: {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 20)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: Tokens.Spacing.xs) {
                        Text("Configure")
                            .font(Tokens.Typography.label)
                        Image(systemName: "gear")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Tokens.Colors.orange)
                    )
                }
                .buttonStyle(.plain)
            }

            if isConfiguredState {
                Menu {
                    Button {
                        clearAPIKey()
                    } label: {
                        Label("Remove API Key", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20, height: 20)
            }
        }
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text("API Key Configuration")
                .font(Tokens.Typography.bodyMedium)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            HStack(spacing: Tokens.Spacing.sm) {
                SecureField("Enter your \(model.provider.rawValue) API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isVerifying)

                Button(action: verifyAPIKey) {
                    HStack(spacing: Tokens.Spacing.xs) {
                        if isVerifying {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: verificationStatus == .success ? "checkmark" : "checkmark.shield")
                                .font(.system(size: 12, weight: .medium))
                        }
                        Text(isVerifying ? "Verifying..." : "Verify")
                            .font(Tokens.Typography.label)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(verificationStatus == .success ? Tokens.Colors.success : Tokens.Colors.orange)
                    )
                }
                .buttonStyle(.plain)
                .disabled(apiKey.isEmpty || isVerifying)
            }

            if verificationStatus == .failure {
                Text("Invalid API key. Please check your key and try again.")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.error)
            } else if verificationStatus == .success {
                Text("API key verified successfully!")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.success)
            }
        }
    }
    
    private func loadSavedAPIKey() {
        if let savedKey = UserDefaults.standard.string(forKey: "\(providerKey)APIKey") {
            apiKey = savedKey
            verificationStatus = .success
        }
    }
    
    private func verifyAPIKey() {
        guard !apiKey.isEmpty else { return }

        isVerifying = true
        verificationStatus = .verifying

        switch model.provider {
        case .gemini:
            // Gemini exists as both AI Enhancement and transcription provider — verify via AIService
            aiService.selectedProvider = .gemini
            aiService.saveAPIKey(apiKey) { isValid in
                DispatchQueue.main.async {
                    self.isVerifying = false
                    if isValid {
                        self.verificationStatus = .success
                        UserDefaults.standard.set(self.apiKey, forKey: "\(self.providerKey)APIKey")
                        self.isConfiguredState = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.isExpanded = false
                        }
                    } else {
                        self.verificationStatus = .failure
                    }
                }
            }
        case .groq, .elevenLabs, .deepgram, .mistral, .soniox:
            // Transcription-only providers — save key directly, validated at transcription time
            UserDefaults.standard.set(apiKey, forKey: "\(providerKey)APIKey")
            isVerifying = false
            verificationStatus = .success
            isConfiguredState = true
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded = false
            }
        default:
            print("Warning: verifyAPIKey called for unsupported provider \(model.provider.rawValue)")
            isVerifying = false
            verificationStatus = .failure
            return
        }
    }
    
    private func clearAPIKey() {
        UserDefaults.standard.removeObject(forKey: "\(providerKey)APIKey")
        apiKey = ""
        verificationStatus = .none
        isConfiguredState = false
        
        // If this model is currently the default, clear it
        if isCurrent {
            Task {
                await MainActor.run {
                    whisperState.currentTranscriptionModel = nil
                    UserDefaults.standard.removeObject(forKey: "CurrentTranscriptionModel")
                }
            }
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isExpanded = false
        }
    }
}
