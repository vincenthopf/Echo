import SwiftUI
import UniformTypeIdentifiers

/// Intelligence settings for AI Enhancement and Adaptive Awareness
struct IntelligenceSettingsView: View {
    // AI Enhancement
    @EnvironmentObject private var enhancementService: AIEnhancementService

    // Adaptive Awareness
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = true
    @AppStorage(PowerModeDefaults.autoRestoreKey) private var powerModeAutoRestoreEnabled = true
    @State private var showDisableAlert = false

    // Smart Corrections
    @StateObject private var whisperPrompt = WhisperPrompt()
    @State private var selectedDictionarySection: DictionarySection = .replacements

    enum DictionarySection: String, CaseIterable {
        case replacements = "Smart Corrections"
        case spellings = "Personal Vocabulary"

        var description: String {
            switch self {
            case .spellings:
                return "Add words to help Echo recognize them properly"
            case .replacements:
                return "Automatically replace specific words/phrases with custom formatted text"
            }
        }

        var icon: String {
            switch self {
            case .spellings:
                return "character.book.closed.fill"
            case .replacements:
                return "arrow.2.squarepath"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - AI Provider Integration Section
                SettingsSection(
                    icon: "brain",
                    title: "AI Provider Integration",
                    subtitle: "Configure AI models and API keys"
                ) {
                    APIKeyManagementView()
                }

                // MARK: - Adaptive Awareness Section
                SettingsSection(
                    icon: "sparkles.square.fill.on.square",
                    title: "Adaptive Awareness",
                    subtitle: "Automatically adjusts settings based on what you're doing"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Main toggle and description
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Enable Adaptive Awareness")
                                        .font(.headline)

                                    InfoTip(
                                        title: "Adaptive Awareness",
                                        message: "Automatically applies custom configurations based on your active app or website. Create rules to customize transcription models, AI prompts, and other preferences for different contexts."
                                    )
                                }

                                Text("Automatically apply custom configurations based on the app or website you are using")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Toggle("Enable Adaptive Awareness", isOn: toggleBinding)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }

                        if powerModeUIFlag {
                            Divider()
                                .padding(.vertical, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))

                            HStack(spacing: 8) {
                                Toggle(isOn: $powerModeAutoRestoreEnabled) {
                                    Text("Restore defaults after each session")
                                }
                                .toggleStyle(.switch)

                                InfoTip(
                                    title: "Restore Defaults",
                                    message: "After each recording session, revert enhancement and transcription preferences to whatever was configured before Adaptive Awareness was activated."
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: powerModeUIFlag)
                }

                // MARK: - AI Enhancement Section
                SettingsSection(
                    icon: "wand.and.stars",
                    title: "AI Enhancement",
                    subtitle: "Transform your transcriptions with AI"
                ) {
                    VStack(spacing: 24) {
                        // Enable/Disable Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Enable Transformation")
                                            .font(.headline)

                                        InfoTip(
                                            title: "Intelligent Transformation",
                                            message: "Intelligent transformation lets you pass the transcribed audio through LLMs to post-process using different prompts suitable for different use cases like e-mails, summary, writing, etc.",
                                            learnMoreURL: "https://vjh.io/embr-echo-docs"
                                        )
                                    }

                                    Text("Turn on AI-powered transformation features")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Toggle("", isOn: $enhancementService.isEnhancementEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    .labelsHidden()
                                    .scaleEffect(1.2)
                            }

                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Toggle("Clipboard Context", isOn: $enhancementService.useClipboardContext)
                                        .toggleStyle(.switch)
                                        .disabled(!enhancementService.isEnhancementEnabled)
                                    Text("Use text from clipboard to understand the context")
                                        .font(.caption)
                                        .foregroundColor(enhancementService.isEnhancementEnabled ? .secondary : .secondary.opacity(0.5))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Toggle("Context Awareness", isOn: $enhancementService.useScreenCaptureContext)
                                        .toggleStyle(.switch)
                                        .disabled(!enhancementService.isEnhancementEnabled)
                                    Text("Learn what is on the screen to understand the context")
                                        .font(.caption)
                                        .foregroundColor(enhancementService.isEnhancementEnabled ? .secondary : .secondary.opacity(0.5))
                                }
                            }
                        }

                        Divider()

                        // Enhancement Shortcuts
                        EnhancementShortcutsSection()
                    }
                }

                // MARK: - Smart Corrections Section
                SettingsSection(
                    icon: "character.book.closed.fill",
                    title: "Smart Corrections",
                    subtitle: "Customize your personal vocabulary and replacements"
                ) {
                    VStack(spacing: 20) {
                        // Section Selector
                        HStack(spacing: 20) {
                            ForEach(DictionarySection.allCases, id: \.self) { section in
                                DictionarySectionCard(
                                    section: section,
                                    isSelected: selectedDictionarySection == section,
                                    action: { selectedDictionarySection = section }
                                )
                            }
                        }

                        Divider()

                        // Selected Section Content
                        switch selectedDictionarySection {
                        case .spellings:
                            DictionaryView(whisperPrompt: whisperPrompt)
                        case .replacements:
                            WordReplacementView()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Adaptive Awareness Still Active", isPresented: $showDisableAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Adaptive Awareness can't be disabled while any configuration is still enabled. Disable or remove your configurations first.")
        }
    }

    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { powerModeUIFlag },
            set: { newValue in
                if newValue {
                    powerModeUIFlag = true
                } else if powerModeManager.configurations.noneEnabled {
                    powerModeUIFlag = false
                } else {
                    showDisableAlert = true
                }
            }
        )
    }
}

private extension Array where Element == PowerModeConfig {
    var noneEnabled: Bool {
        allSatisfy { !$0.isEnabled }
    }
}

// MARK: - Dictionary Section Card
private struct DictionarySectionCard: View {
    let section: IntelligenceSettingsView.DictionarySection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.headline)

                    Text(section.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(CardBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }
}
