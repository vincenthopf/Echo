import SwiftUI
import UniformTypeIdentifiers

/// Intelligence settings for AI Enhancement and Adaptive Awareness
struct IntelligenceSettingsView: View {
    // AI Enhancement
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var menuBarManager: MenuBarManager

    // Adaptive Awareness
    @AppStorage(PowerModeDefaults.autoRestoreKey) private var powerModeAutoRestoreEnabled = true

    // Design system
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: Tokens.Spacing.xxxl) {
                // MARK: - AI Provider Integration Section
                aiProviderSection

                // MARK: - Adaptive Awareness Section
                adaptiveAwarenessSection

                // MARK: - AI Enhancement Section
                aiEnhancementSection
            }
            .padding(.horizontal, Tokens.Spacing.xl)
            .padding(.vertical, Tokens.Spacing.sm)
        }
        .background(Tokens.Colors.background(for: colorScheme))
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
                FormRow(label: "Profiles") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Text("Adaptive Awareness is active while profiles exist.")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)

                        InfoTip(
                            title: "Adaptive Awareness",
                            message: "Automatically applies custom profiles based on your active app or website. Create rules to customize transcription models, AI prompts, and other preferences for different contexts."
                        )

                        Spacer()

                        Button("Manage Profiles") {
                            menuBarManager.navigateTo(.adaptiveAwareness)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .accessibilityIdentifier("intelligence.manageProfiles")
                    }
                }

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
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - AI Enhancement Section

    private var aiEnhancementSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Intelligent Transformation",
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

                        // Vision/OCR mode indicator
                        if enhancementService.useScreenCaptureContext,
                           let aiService = enhancementService.getAIService() {
                            ScreenCaptureModeIndicator(aiService: aiService, colorScheme: colorScheme)
                        }
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

}
