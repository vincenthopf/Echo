import SwiftUI
import UniformTypeIdentifiers

/// Intelligence settings for AI Enhancement
struct IntelligenceSettingsView: View {
    // AI Enhancement
    @EnvironmentObject private var enhancementService: AIEnhancementService

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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

                        // AI Provider Integration
                        VStack(alignment: .leading, spacing: 16) {
                            Text("AI Provider Integration")
                                .font(.headline)

                            APIKeyManagementView()
                        }

                        Divider()

                        // Enhancement Shortcuts
                        EnhancementShortcutsSection()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}
