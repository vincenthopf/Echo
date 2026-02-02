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

    // Design system
    @Environment(\.colorScheme) private var colorScheme

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
            VStack(spacing: Tokens.Spacing.xxxl) {
                // MARK: - AI Provider Integration Section
                aiProviderSection

                // MARK: - Adaptive Awareness Section
                adaptiveAwarenessSection

                // MARK: - AI Enhancement Section
                aiEnhancementSection

                // MARK: - Smart Corrections Section
                smartCorrectionsSection
            }
            .padding(.horizontal, Tokens.Spacing.xl)
            .padding(.vertical, Tokens.Spacing.sm)
        }
        .background(Tokens.Colors.background(for: colorScheme))
        .alert("Adaptive Awareness Still Active", isPresented: $showDisableAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Adaptive Awareness can't be disabled while any configuration is still enabled. Disable or remove your configurations first.")
        }
    }

    // MARK: - AI Provider Section

    private var aiProviderSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "AI Provider Integration",
                subtitle: "Configure AI models and API keys",
                icon: "brain"
            )

            VStack(spacing: 0) {
                APIKeyManagementView()
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Adaptive Awareness Section

    private var adaptiveAwarenessSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Adaptive Awareness",
                subtitle: "Automatically adjusts settings based on what you're doing",
                icon: "sparkles.square.fill.on.square"
            )

            VStack(spacing: 0) {
                // Main toggle row
                FormRow(label: "Enabled") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: toggleBinding)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()

                        Text("Automatically apply custom configurations based on context")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)

                        InfoTip(
                            title: "Adaptive Awareness",
                            message: "Automatically applies custom configurations based on your active app or website. Create rules to customize transcription models, AI prompts, and other preferences for different contexts."
                        )

                        Spacer()
                    }
                }

                if powerModeUIFlag {
                    FormDivider()

                    FormRow(label: "Restore") {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Toggle("", isOn: $powerModeAutoRestoreEnabled)
                                .toggleStyle(.switch)
                                .tint(Tokens.Colors.orange)
                                .labelsHidden()

                            Text("Restore defaults after each session")
                                .font(Tokens.Typography.bodySmall)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                            InfoTip(
                                title: "Restore Defaults",
                                message: "After each recording session, revert enhancement and transcription preferences to whatever was configured before Adaptive Awareness was activated."
                            )

                            Spacer()
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
            .animation(.easeInOut(duration: Tokens.Animation.duration), value: powerModeUIFlag)
        }
    }

    // MARK: - AI Enhancement Section

    private var aiEnhancementSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "AI Enhancement",
                subtitle: "Transform your transcriptions with AI",
                icon: "wand.and.stars"
            )

            VStack(spacing: 0) {
                // Enable toggle row
                FormRow(label: "Enabled") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $enhancementService.isEnhancementEnabled)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()

                        Text("Turn on AI-powered transformation features")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Intelligent Transformation",
                            message: "Intelligent transformation lets you pass the transcribed audio through LLMs to post-process using different prompts suitable for different use cases like e-mails, summary, writing, etc.",
                            learnMoreURL: "https://vjh.io/embr-echo-docs"
                        )

                        Spacer()
                    }
                }

                FormDivider()

                // Clipboard Context row
                FormRow(label: "Clipboard") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $enhancementService.useClipboardContext)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()
                            .disabled(!enhancementService.isEnhancementEnabled)

                        Text("Use text from clipboard to understand the context")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(enhancementService.isEnhancementEnabled
                                ? Tokens.Colors.textSecondary(for: colorScheme)
                                : Tokens.Colors.textSecondary(for: colorScheme).opacity(0.5))

                        Spacer()
                    }
                }

                FormDivider()

                // Context Awareness row
                FormRow(label: "Screen") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $enhancementService.useScreenCaptureContext)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()
                            .disabled(!enhancementService.isEnhancementEnabled)

                        Text("Learn what is on the screen to understand the context")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(enhancementService.isEnhancementEnabled
                                ? Tokens.Colors.textSecondary(for: colorScheme)
                                : Tokens.Colors.textSecondary(for: colorScheme).opacity(0.5))

                        Spacer()
                    }
                }

                FormDivider()

                // Enhancement shortcuts
                VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                    EnhancementShortcutsSection()
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.vertical, 14)
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Smart Corrections Section

    private var smartCorrectionsSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Smart Corrections",
                subtitle: "Customize your personal vocabulary and replacements",
                icon: "character.book.closed.fill"
            )

            VStack(spacing: 0) {
                // Section Selector row
                HStack(spacing: Tokens.Spacing.xl) {
                    ForEach(DictionarySection.allCases, id: \.self) { section in
                        DictionarySectionCard(
                            section: section,
                            isSelected: selectedDictionarySection == section,
                            colorScheme: colorScheme,
                            action: { selectedDictionarySection = section }
                        )
                    }
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.vertical, 14)

                FormDivider()

                // Selected Section Content
                VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                    switch selectedDictionarySection {
                    case .spellings:
                        DictionaryView(whisperPrompt: whisperPrompt)
                    case .replacements:
                        WordReplacementView()
                    }
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.vertical, 14)
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
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
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Tokens.Colors.orange : Tokens.Colors.textSecondary(for: colorScheme))

                VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                    Text(section.rawValue)
                        .font(Tokens.Typography.heading3)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                    Text(section.description)
                        .font(Tokens.Typography.bodySmall)
                        .foregroundStyle(Tokens.Colors.textSecondary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Tokens.Spacing.lg)
            .background(
                isSelected
                    ? Tokens.Colors.orangeSoft(for: colorScheme)
                    : Tokens.Colors.background(for: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.md)
                    .stroke(
                        isSelected
                            ? Tokens.Colors.orange.opacity(0.5)
                            : Tokens.Colors.border(for: colorScheme),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
