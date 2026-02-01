import SwiftUI

struct APIKeyManagementView: View {
    @EnvironmentObject private var aiService: AIService
    @State private var apiKey: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isVerifying = false
    @State private var ollamaBaseURL: String = UserDefaults.standard.string(forKey: "ollamaBaseURL") ?? "http://localhost:11434"
    @State private var ollamaModels: [OllamaService.OllamaModel] = []
    @State private var selectedOllamaModel: String = UserDefaults.standard.string(forKey: "ollamaSelectedModel") ?? "mistral"
    @State private var isCheckingOllama = false
    @State private var isEditingURL = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Provider Selection Row
            FormRow(label: "AI Provider") {
                HStack {
                    Picker("", selection: $aiService.selectedProvider) {
                        ForEach(AIProvider.allCases.filter { $0 != .elevenLabs && $0 != .deepgram }, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .labelsHidden()
                    .tint(Tokens.Colors.orange)

                    Spacer()

                    if aiService.isAPIKeyValid && aiService.selectedProvider != .ollama {
                        connectedBadge
                    }
                }
            }
            .onChange(of: aiService.selectedProvider) { oldValue, newValue in
                if aiService.selectedProvider == .ollama {
                    checkOllamaConnection()
                }
            }

            // Model Selection Row (for providers with models)
            if shouldShowModelPicker {
                FormDivider()
                modelSelectionRow
            }

            // Provider-specific content
            if aiService.selectedProvider == .ollama {
                FormDivider()
                ollamaConfigSection
            } else if aiService.selectedProvider == .custom {
                FormDivider()
                customProviderSection
            } else {
                FormDivider()
                apiKeySection
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            if aiService.selectedProvider == .ollama {
                checkOllamaConnection()
            }
        }
    }

    // MARK: - Connected Badge

    private var connectedBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Tokens.Colors.success)
                .frame(width: 6, height: 6)
            Text("Connected")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Tokens.Colors.success)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Tokens.Colors.successSoft(for: colorScheme))
        .clipShape(Capsule())
    }

    // MARK: - Model Selection

    private var shouldShowModelPicker: Bool {
        if aiService.selectedProvider == .ollama || aiService.selectedProvider == .custom {
            return false
        }
        return !aiService.availableModels.isEmpty || aiService.selectedProvider == .openRouter
    }

    private var modelSelectionRow: some View {
        FormRow(label: "Model") {
            HStack {
                if aiService.selectedProvider == .openRouter {
                    if aiService.availableModels.isEmpty {
                        Text("No models loaded")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                    } else {
                        Picker("", selection: Binding(
                            get: { aiService.currentModel },
                            set: { aiService.selectModel($0) }
                        )) {
                            ForEach(aiService.availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .labelsHidden()
                        .tint(Tokens.Colors.orange)
                    }

                    Spacer()

                    Button(action: {
                        Task {
                            await aiService.fetchOpenRouterModels()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .foregroundColor(Tokens.Colors.orange)
                    }
                    .buttonStyle(.plain)
                    .help("Refresh models")
                } else {
                    Picker("", selection: Binding(
                        get: { aiService.currentModel },
                        set: { aiService.selectModel($0) }
                    )) {
                        ForEach(aiService.availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .labelsHidden()
                    .tint(Tokens.Colors.orange)

                    Spacer()
                }
            }
        }
    }

    // MARK: - API Key Section

    private var apiKeySection: some View {
        Group {
            if aiService.isAPIKeyValid {
                // Show masked key with remove button
                FormRow(label: "API Key") {
                    HStack {
                        Text(String(repeating: "•", count: 32))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        Spacer()

                        Button(action: {
                            aiService.clearAPIKey()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Tokens.Colors.error)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                // Show input field
                VStack(spacing: 0) {
                    FormRow(label: "API Key") {
                        SecureField("Enter your API key", text: $apiKey)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, design: .monospaced))
                    }

                    FormDivider()

                    // Verify button row
                    HStack {
                        Button(action: verifyAndSave) {
                            HStack(spacing: 6) {
                                if isVerifying {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .frame(width: 14, height: 14)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                }
                                Text("Verify and Save")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(apiKey.isEmpty ? Tokens.Colors.orange.opacity(0.5) : Tokens.Colors.orange)
                            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                        }
                        .buttonStyle(.plain)
                        .disabled(apiKey.isEmpty || isVerifying)

                        Spacer()

                        // Free/Paid badge
                        Text(isFreeProvider ? "Free" : "Paid")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Tokens.Colors.background(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))

                        // Get API Key link
                        if let url = apiKeyURL {
                            Button(action: { NSWorkspace.shared.open(url) }) {
                                HStack(spacing: 4) {
                                    Text("Get API Key")
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(Tokens.Colors.orange)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Tokens.Spacing.lg)
                    .padding(.vertical, 14)
                }
            }
        }
    }

    // MARK: - Ollama Config Section

    private var ollamaConfigSection: some View {
        VStack(spacing: 0) {
            // Status row
            FormRow(label: "Status") {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isCheckingOllama ? Color.orange : (ollamaModels.isEmpty ? Tokens.Colors.error : Tokens.Colors.success))
                        .frame(width: 6, height: 6)
                    Text(isCheckingOllama ? "Checking..." : (ollamaModels.isEmpty ? "Disconnected" : "Connected"))
                        .font(Tokens.Typography.bodySmall)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                    Spacer()

                    Button(action: checkOllamaConnection) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Tokens.Colors.orange)
                    }
                    .buttonStyle(.plain)
                    .disabled(isCheckingOllama)
                }
            }

            FormDivider()

            // Server URL row
            FormRow(label: "Server URL") {
                HStack {
                    if isEditingURL {
                        TextField("Base URL", text: $ollamaBaseURL)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, design: .monospaced))

                        Button("Save") {
                            aiService.updateOllamaBaseURL(ollamaBaseURL)
                            checkOllamaConnection()
                            isEditingURL = false
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Tokens.Colors.orange)
                        .buttonStyle(.plain)
                    } else {
                        Text(ollamaBaseURL)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Spacer()

                        Button(action: { isEditingURL = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12))
                                .foregroundColor(Tokens.Colors.orange)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            FormDivider()

            // Model selection row
            FormRow(label: "Model") {
                HStack {
                    if ollamaModels.isEmpty {
                        Text("No models available")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                            .italic()
                    } else {
                        Picker("", selection: $selectedOllamaModel) {
                            ForEach(ollamaModels) { model in
                                Text(model.name).tag(model.name)
                            }
                        }
                        .labelsHidden()
                        .tint(Tokens.Colors.orange)
                        .onChange(of: selectedOllamaModel) { oldValue, newValue in
                            aiService.updateSelectedOllamaModel(newValue)
                        }
                    }

                    Spacer()
                }
            }

            // Troubleshooting section if not connected
            if ollamaModels.isEmpty {
                FormDivider()

                VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                    Text("Troubleshooting")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                    VStack(alignment: .leading, spacing: 4) {
                        bulletPoint("Ensure Ollama is installed and running")
                        bulletPoint("Check if the server URL is correct")
                        bulletPoint("Verify you have at least one model pulled")
                    }
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                    Button("Learn More") {
                        NSWorkspace.shared.open(URL(string: "https://ollama.ai/download")!)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Tokens.Colors.orange)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tokens.Colors.orangeSoft(for: colorScheme))
            }
        }
    }

    // MARK: - Custom Provider Section

    private var customProviderSection: some View {
        VStack(spacing: 0) {
            if !aiService.isAPIKeyValid {
                // Endpoint URL row
                FormRow(label: "Endpoint") {
                    TextField("https://api.example.com/v1/chat/completions", text: $aiService.customBaseURL)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                }

                FormDivider()

                // Model name row
                FormRow(label: "Model") {
                    TextField("gpt-4o-mini", text: $aiService.customModel)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                }

                FormDivider()

                // API Key row
                FormRow(label: "API Key") {
                    SecureField("Enter your API key", text: $apiKey)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                }

                FormDivider()

                // Verify button
                HStack {
                    Button(action: verifyAndSave) {
                        HStack(spacing: 6) {
                            if isVerifying {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .frame(width: 14, height: 14)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text("Verify and Save")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(canVerifyCustom ? Tokens.Colors.orange : Tokens.Colors.orange.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canVerifyCustom || isVerifying)

                    Spacer()
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.vertical, 14)
            } else {
                // Show configured values
                FormRow(label: "Endpoint") {
                    Text(aiService.customBaseURL)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                }

                FormDivider()

                FormRow(label: "Model") {
                    Text(aiService.customModel)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                }

                FormDivider()

                FormRow(label: "API Key") {
                    HStack {
                        Text(String(repeating: "•", count: 32))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        Spacer()

                        Button(action: {
                            aiService.clearAPIKey()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Tokens.Colors.error)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var isFreeProvider: Bool {
        [.groq, .gemini, .cerebras].contains(aiService.selectedProvider)
    }

    private var canVerifyCustom: Bool {
        !aiService.customBaseURL.isEmpty && !aiService.customModel.isEmpty && !apiKey.isEmpty
    }

    private var apiKeyURL: URL? {
        switch aiService.selectedProvider {
        case .groq: return URL(string: "https://console.groq.com/keys")
        case .openAI: return URL(string: "https://platform.openai.com/api-keys")
        case .gemini: return URL(string: "https://makersuite.google.com/app/apikey")
        case .anthropic: return URL(string: "https://console.anthropic.com/settings/keys")
        case .mistral: return URL(string: "https://console.mistral.ai/api-keys")
        case .openRouter: return URL(string: "https://openrouter.ai/keys")
        case .cerebras: return URL(string: "https://cloud.cerebras.ai/")
        case .ollama, .custom, .elevenLabs, .deepgram: return nil
        }
    }

    private func verifyAndSave() {
        isVerifying = true
        aiService.saveAPIKey(apiKey) { success in
            isVerifying = false
            if !success {
                alertMessage = "Invalid API key. Please check and try again."
                showAlert = true
            }
            apiKey = ""
        }
    }

    private func checkOllamaConnection() {
        isCheckingOllama = true
        aiService.checkOllamaConnection { connected in
            if connected {
                Task {
                    ollamaModels = await aiService.fetchOllamaModels()
                    isCheckingOllama = false
                }
            } else {
                ollamaModels = []
                isCheckingOllama = false
                alertMessage = "Could not connect to Ollama. Please check if Ollama is running and the base URL is correct."
                showAlert = true
            }
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
            Text(text)
        }
    }
}
