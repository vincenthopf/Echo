import SwiftUI
import SwiftData

struct AudioCleanupSettingsView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @Environment(\.colorScheme) private var colorScheme

    // Audio cleanup settings
    @AppStorage("IsTranscriptionCleanupEnabled") private var isTranscriptionCleanupEnabled = false
    @AppStorage("TranscriptionRetentionMinutes") private var transcriptionRetentionMinutes = 24 * 60
    @AppStorage("IsAudioCleanupEnabled") private var isAudioCleanupEnabled = false
    @AppStorage("AudioRetentionPeriod") private var audioRetentionPeriod = 7
    @State private var isPerformingCleanup = false
    @State private var isShowingConfirmation = false
    @State private var cleanupInfo: (fileCount: Int, totalSize: Int64, transcriptions: [Transcription]) = (0, 0, [])
    @State private var showResultAlert = false
    @State private var cleanupResult: (deletedCount: Int, errorCount: Int) = (0, 0)
    @State private var showTranscriptCleanupResult = false

    var body: some View {
        VStack(spacing: 0) {
            // Description row
            FormRow(label: "Info") {
                Text("Control how Echo handles your transcription data and audio recordings for privacy and storage management.")
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }

            FormDivider()

            // Transcript cleanup toggle
            FormRow(label: "Transcripts") {
                HStack(spacing: Tokens.Spacing.sm) {
                    Toggle("", isOn: $isTranscriptionCleanupEnabled)
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                    Text("Automatically delete transcript history")
                        .font(Tokens.Typography.body)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                    Spacer()
                }
            }

            if isTranscriptionCleanupEnabled {
                FormDivider()

                // Retention period picker
                FormRow(label: "Retention") {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        Picker("Delete transcripts older than", selection: $transcriptionRetentionMinutes) {
                            Text("Immediately").tag(0)
                            Text("1 hour").tag(60)
                            Text("1 day").tag(24 * 60)
                            Text("3 days").tag(3 * 24 * 60)
                            Text("7 days").tag(7 * 24 * 60)
                        }
                        .pickerStyle(.menu)
                        .tint(Tokens.Colors.orange)

                        Text("Older transcripts will be deleted automatically based on your selection.")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                FormDivider()

                // Run cleanup button
                FormRow(label: "Action") {
                    Button(action: {
                        Task {
                            await TranscriptionAutoCleanupService.shared.runManualCleanup(modelContext: whisperState.modelContext)
                            await MainActor.run {
                                showTranscriptCleanupResult = true
                            }
                        }
                    }) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Image(systemName: "trash.circle")
                            Text("Run Transcript Cleanup Now")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Tokens.Colors.orange)
                    .controlSize(.large)
                    .alert("Transcript Cleanup", isPresented: $showTranscriptCleanupResult) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Cleanup triggered. Old transcripts are cleaned up according to your retention setting.")
                    }
                }
            }

            if !isTranscriptionCleanupEnabled {
                FormDivider()

                // Audio cleanup toggle
                FormRow(label: "Audio") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $isAudioCleanupEnabled)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()

                        Text("Enable automatic audio cleanup")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Spacer()
                    }
                }
            }

            if isAudioCleanupEnabled && !isTranscriptionCleanupEnabled {
                FormDivider()

                // Audio retention picker
                FormRow(label: "Keep For") {
                    VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                        Picker("Keep audio files for", selection: $audioRetentionPeriod) {
                            Text("1 day").tag(1)
                            Text("3 days").tag(3)
                            Text("7 days").tag(7)
                            Text("14 days").tag(14)
                            Text("30 days").tag(30)
                        }
                        .pickerStyle(.menu)
                        .tint(Tokens.Colors.orange)

                        Text("Audio files older than the selected period will be automatically deleted, while keeping the text transcripts intact.")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                FormDivider()

                // Run audio cleanup button
                FormRow(label: "Action") {
                    Button(action: {
                        // Start by analyzing what would be cleaned up
                        Task {
                            // Update UI state
                            await MainActor.run {
                                isPerformingCleanup = true
                            }

                            // Get cleanup info
                            let info = await AudioCleanupManager.shared.getCleanupInfo(modelContext: whisperState.modelContext)

                            // Update UI with results
                            await MainActor.run {
                                cleanupInfo = info
                                isPerformingCleanup = false
                                isShowingConfirmation = true
                            }
                        }
                    }) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            if isPerformingCleanup {
                                ProgressView()
                                    .controlSize(.small)
                                    .padding(.trailing, Tokens.Spacing.xs)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(isPerformingCleanup ? "Analyzing..." : "Run Cleanup Now")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Tokens.Colors.orange)
                    .controlSize(.large)
                    .disabled(isPerformingCleanup)
                    .alert("Audio Cleanup", isPresented: $isShowingConfirmation) {
                        Button("Cancel", role: .cancel) { }

                        if cleanupInfo.fileCount > 0 {
                            Button("Delete \(cleanupInfo.fileCount) Files", role: .destructive) {
                                Task {
                                    // Update UI state
                                    await MainActor.run {
                                        isPerformingCleanup = true
                                    }

                                    // Perform cleanup
                                    let result = await AudioCleanupManager.shared.runCleanupForTranscriptions(
                                        modelContext: whisperState.modelContext,
                                        transcriptions: cleanupInfo.transcriptions
                                    )

                                    // Update UI with results
                                    await MainActor.run {
                                        cleanupResult = result
                                        isPerformingCleanup = false
                                        showResultAlert = true
                                    }
                                }
                            }
                        }
                    } message: {
                        VStack(alignment: .leading, spacing: 8) {
                            if cleanupInfo.fileCount > 0 {
                                Text("This will delete \(cleanupInfo.fileCount) audio files older than \(audioRetentionPeriod) day\(audioRetentionPeriod > 1 ? "s" : "").")
                                Text("Total size to be freed: \(AudioCleanupManager.shared.formatFileSize(cleanupInfo.totalSize))")
                                Text("The text transcripts will be preserved.")
                            } else {
                                Text("No audio files found that are older than \(audioRetentionPeriod) day\(audioRetentionPeriod > 1 ? "s" : "").")
                            }
                        }
                    }
                    .alert("Cleanup Complete", isPresented: $showResultAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        if cleanupResult.errorCount > 0 {
                            Text("Successfully deleted \(cleanupResult.deletedCount) audio files. Failed to delete \(cleanupResult.errorCount) files.")
                        } else {
                            Text("Successfully deleted \(cleanupResult.deletedCount) audio files.")
                        }
                    }
                }
            }
        }
        .onChange(of: isTranscriptionCleanupEnabled) { _, newValue in
            if newValue {
                AudioCleanupManager.shared.stopAutomaticCleanup()
            } else if isAudioCleanupEnabled {
                AudioCleanupManager.shared.startAutomaticCleanup(modelContext: whisperState.modelContext)
            }
        }
    }
}
