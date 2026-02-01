import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AVFoundation

struct AudioTranscribeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var whisperState: WhisperState
    @StateObject private var transcriptionManager = AudioTranscriptionManager.shared
    @State private var isDropTargeted = false
    @State private var selectedAudioURL: URL?
    @State private var isAudioFileSelected = false
    @State private var isEnhancementEnabled = false
    @State private var selectedPromptId: UUID?

    var body: some View {
        ZStack(alignment: .top) {
            Tokens.Colors.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Card
                HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
                    // Icon
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white, Tokens.Colors.orange)
                        .symbolRenderingMode(.palette)

                    // Title and Description
                    VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Text("Transcribe Files")
                                .font(Tokens.Typography.heading1)
                                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                            InfoTip(
                                title: "Transcribe Audio Files",
                                message: "Turn any audio or video file into text. Drop a file, choose your settings, and get accurate transcriptions in seconds."
                            )
                        }

                        Text("Convert recordings and videos to text instantly.")
                            .font(Tokens.Typography.body)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }

                    Spacer()
                }
                .padding(Tokens.Spacing.xl)
                .background(Tokens.Colors.elevated(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.xl)
                        .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                )
                .padding(Tokens.Spacing.xl)

                if transcriptionManager.isProcessing {
                    processingView
                } else {
                    dropZoneView
                }

                // Show current transcription result
                if let transcription = transcriptionManager.currentTranscription {
                    TranscriptionResultView(transcription: transcription)
                }

                Spacer()
            }
        }
        .onDrop(of: [.fileURL, .data, .audio, .movie], isTargeted: $isDropTargeted) { providers in
            if !transcriptionManager.isProcessing && !isAudioFileSelected {
                handleDroppedFile(providers)
                return true
            }
            return false
        }
        .alert("Error", isPresented: .constant(transcriptionManager.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                transcriptionManager.errorMessage = nil
            }
        } message: {
            if let errorMessage = transcriptionManager.errorMessage {
                Text(errorMessage)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openFileForTranscription)) { notification in
            if let url = notification.userInfo?["url"] as? URL {
                // Do not auto-start; only select file for manual transcription
                validateAndSetAudioFile(url)
            }
        }
    }

    private var dropZoneView: some View {
        VStack(spacing: Tokens.Spacing.lg) {
            if isAudioFileSelected {
                VStack(spacing: Tokens.Spacing.lg) {
                    Text("Audio file selected: \(selectedAudioURL?.lastPathComponent ?? "")")
                        .font(Tokens.Typography.heading3)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                    // AI Transformation Settings
                    if let enhancementService = whisperState.getEnhancementService() {
                        VStack(spacing: Tokens.Spacing.lg) {
                            // Intelligent Transformation and Prompt in the same row
                            HStack(spacing: Tokens.Spacing.lg) {
                                Toggle("Intelligent Transformation", isOn: $isEnhancementEnabled)
                                    .toggleStyle(.switch)
                                    .tint(Tokens.Colors.orange)
                                    .onChange(of: isEnhancementEnabled) { oldValue, newValue in
                                        enhancementService.isEnhancementEnabled = newValue
                                    }

                                if isEnhancementEnabled {
                                    Divider()
                                        .frame(height: 20)

                                    // Prompt Selection
                                    HStack(spacing: Tokens.Spacing.sm) {
                                        Text("Prompt:")
                                            .font(Tokens.Typography.bodySmall)
                                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                                        if enhancementService.allPrompts.isEmpty {
                                            Text("No prompts available")
                                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                                                .italic()
                                                .font(Tokens.Typography.caption)
                                        } else {
                                            let promptBinding = Binding<UUID>(
                                                get: {
                                                    selectedPromptId ?? enhancementService.allPrompts.first?.id ?? UUID()
                                                },
                                                set: { newValue in
                                                    selectedPromptId = newValue
                                                    enhancementService.selectedPromptId = newValue
                                                }
                                            )

                                            Picker("", selection: promptBinding) {
                                                ForEach(enhancementService.allPrompts) { prompt in
                                                    Text(prompt.title).tag(prompt.id)
                                                }
                                            }
                                            .tint(Tokens.Colors.orange)
                                            .labelsHidden()
                                            .fixedSize()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, Tokens.Spacing.md)
                            .padding(.vertical, Tokens.Spacing.sm)
                            .background(Tokens.Colors.elevated(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            // Initialize local state from enhancement service
                            isEnhancementEnabled = enhancementService.isEnhancementEnabled
                            selectedPromptId = enhancementService.selectedPromptId
                        }
                    }

                    // Action Buttons in a row
                    HStack(spacing: Tokens.Spacing.md) {
                        Button("Start Transcription") {
                            if let url = selectedAudioURL {
                                transcriptionManager.startProcessing(
                                    url: url,
                                    modelContext: modelContext,
                                    whisperState: whisperState
                                )
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Tokens.Colors.orange)

                        Button("Choose Different File") {
                            selectedAudioURL = nil
                            isAudioFileSelected = false
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(Tokens.Spacing.lg)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: Tokens.Radius.xl)
                        .fill(Tokens.Colors.elevated(for: colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.xl)
                                .strokeBorder(
                                    style: StrokeStyle(
                                        lineWidth: 2,
                                        dash: [8]
                                    )
                                )
                                .foregroundColor(isDropTargeted ? Tokens.Colors.orange : Tokens.Colors.border(for: colorScheme))
                        )

                    VStack(spacing: Tokens.Spacing.lg) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 32))
                            .foregroundColor(isDropTargeted ? Tokens.Colors.orange : Tokens.Colors.textSecondary(for: colorScheme))

                        Text("Drop audio or video file here")
                            .font(Tokens.Typography.heading3)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        Text("or")
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        Button("Choose File") {
                            selectFile()
                        }
                        .buttonStyle(.bordered)
                        .tint(Tokens.Colors.orange)
                    }
                    .padding(Tokens.Spacing.xxl)
                }
                .frame(height: 200)
                .padding(.horizontal, Tokens.Spacing.lg)
            }

            Text("Supported formats: WAV, MP3, M4A, AIFF, MP4, MOV")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
        }
        .padding(Tokens.Spacing.lg)
    }

    private var processingView: some View {
        VStack(spacing: Tokens.Spacing.lg) {
            ProgressView()
                .scaleEffect(0.8)
            Text(transcriptionManager.processingPhase.message)
                .font(Tokens.Typography.heading3)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
        }
        .padding(Tokens.Spacing.lg)
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .audio, .movie
        ]

        if panel.runModal() == .OK {
            if let url = panel.url {
                selectedAudioURL = url
                isAudioFileSelected = true
            }
        }
    }

    private func handleDroppedFile(_ providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }

        // List of type identifiers to try
        let typeIdentifiers = [
            UTType.fileURL.identifier,
            UTType.audio.identifier,
            UTType.movie.identifier,
            UTType.data.identifier,
            "public.file-url"
        ]

        // Try each type identifier
        for typeIdentifier in typeIdentifiers {
            if provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (item, error) in
                    if let error = error {
                        print("Error loading dropped file with type \(typeIdentifier): \(error)")
                        return
                    }

                    var fileURL: URL?

                    if let url = item as? URL {
                        fileURL = url
                    } else if let data = item as? Data {
                        // Try to create URL from data
                        if let url = URL(dataRepresentation: data, relativeTo: nil) {
                            fileURL = url
                        } else if let urlString = String(data: data, encoding: .utf8),
                                  let url = URL(string: urlString) {
                            fileURL = url
                        }
                    } else if let urlString = item as? String {
                        fileURL = URL(string: urlString)
                    }

                    if let finalURL = fileURL {
                        DispatchQueue.main.async {
                            self.validateAndSetAudioFile(finalURL)
                        }
                        return
                    }
                }
                break // Stop trying other types once we find a compatible one
            }
        }
    }

    private func validateAndSetAudioFile(_ url: URL) {
        print("Attempting to validate file: \(url.path)")

        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("File does not exist at path: \(url.path)")
            return
        }

        // Try to access security scoped resource
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        // Validate file type
        guard SupportedMedia.isSupported(url: url) else { return }

        print("File validated successfully: \(url.lastPathComponent)")
        selectedAudioURL = url
        isAudioFileSelected = true
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
