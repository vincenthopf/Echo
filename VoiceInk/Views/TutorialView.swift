import SwiftUI

/// Tutorial and documentation view for all Embr Voice features
struct TutorialView: View {
    @State private var selectedCategory: TutorialCategory = .gettingStarted
    @State private var searchText = ""

    var body: some View {
        HSplitView {
            // Sidebar with categories
            categoryList
                .frame(minWidth: 200, idealWidth: 220, maxWidth: 250)

            // Main content area
            contentArea
                .frame(minWidth: 450)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var categoryList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))

                TextField("Search tutorials...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)

            Divider()

            // Category list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(TutorialCategory.allCases.filter { category in
                        searchText.isEmpty || category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                        category.topics.contains { $0.title.localizedCaseInsensitiveContains(searchText) }
                    }, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var contentArea: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Category header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: selectedCategory.icon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedCategory.rawValue)
                                .font(.system(size: 28, weight: .bold))
                            Text(selectedCategory.description)
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.bottom, 8)

                // Topics
                ForEach(selectedCategory.topics.filter { topic in
                    searchText.isEmpty || topic.title.localizedCaseInsensitiveContains(searchText) ||
                    topic.content.localizedCaseInsensitiveContains(searchText)
                }, id: \.title) { topic in
                    TutorialTopicCard(topic: topic)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Tutorial Category Button
struct CategoryButton: View {
    let category: TutorialCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 24)

                Text(category.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tutorial Topic Card
struct TutorialTopicCard: View {
    let topic: TutorialTopic
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    if let icon = topic.icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.accentColor)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.accentColor.opacity(0.1))
                            )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(topic.title)
                            .font(.system(size: 16, weight: .semibold))
                        if let subtitle = topic.subtitle {
                            Text(subtitle)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                // Content
                VStack(alignment: .leading, spacing: 16) {
                    Text(topic.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Steps if available
                    if let steps = topic.steps, !steps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(Color.accentColor)
                                        )

                                    Text(step)
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }

                    // Tips if available
                    if let tips = topic.tips, !tips.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.orange)

                                    Text(tip)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // Keyboard shortcut if available
                    if let shortcut = topic.keyboardShortcut {
                        HStack(spacing: 8) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 13))
                                .foregroundColor(.accentColor)

                            Text("Keyboard Shortcut:")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            Text(shortcut)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(NSColor.textBackgroundColor))
                                )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(CardBackground(isSelected: false))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Data Models
enum TutorialCategory: String, CaseIterable {
    case gettingStarted = "Getting Started"
    case recording = "Recording & Transcription"
    case aiEnhancement = "AI Enhancement"
    case powerMode = "Power Mode"
    case models = "Models & Languages"
    case customization = "Customization"
    case advanced = "Advanced Features"

    var icon: String {
        switch self {
        case .gettingStarted: return "hand.wave.fill"
        case .recording: return "mic.circle.fill"
        case .aiEnhancement: return "wand.and.stars"
        case .powerMode: return "sparkles.square.fill.on.square"
        case .models: return "brain.head.profile"
        case .customization: return "slider.horizontal.3"
        case .advanced: return "gearshape.2.fill"
        }
    }

    var description: String {
        switch self {
        case .gettingStarted: return "Learn the basics of Embr Voice"
        case .recording: return "Master voice recording and transcription"
        case .aiEnhancement: return "Enhance transcripts with AI"
        case .powerMode: return "Context-aware intelligent transcription"
        case .models: return "Choose and configure transcription models"
        case .customization: return "Personalize your experience"
        case .advanced: return "Pro tips and advanced workflows"
        }
    }

    var topics: [TutorialTopic] {
        switch self {
        case .gettingStarted:
            return [
                TutorialTopic(
                    title: "Welcome to Embr Voice",
                    subtitle: "Your privacy-focused voice transcription companion",
                    icon: "sparkles",
                    content: "Embr Voice is a native macOS application that converts your voice to text using powerful AI models. Everything runs locally on your Mac for maximum privacy, with optional cloud services for advanced features.",
                    tips: [
                        "All transcriptions are processed on your device by default",
                        "Your voice data never leaves your Mac unless you choose cloud models",
                        "Transcription history is stored locally and can be auto-deleted"
                    ]
                ),
                TutorialTopic(
                    title: "Quick Setup",
                    subtitle: "Get started in 3 easy steps",
                    icon: "checkmark.circle.fill",
                    content: "Before you start transcribing, make sure you have the required permissions and a keyboard shortcut configured.",
                    steps: [
                        "Grant Microphone access when prompted",
                        "Enable Accessibility permissions to paste text automatically",
                        "Set up your preferred keyboard shortcut (e.g., Right Option key)",
                        "Download your first transcription model from the Models tab"
                    ]
                ),
                TutorialTopic(
                    title: "First Transcription",
                    subtitle: "Record your first voice note",
                    icon: "1.circle.fill",
                    content: "Once setup is complete, transcribing is as simple as pressing your hotkey and speaking.",
                    steps: [
                        "Press your configured hotkey to start recording",
                        "Speak clearly into your microphone",
                        "Press the hotkey again to stop (or release if using push-to-talk)",
                        "Watch as your speech is transcribed and automatically pasted!"
                    ],
                    keyboardShortcut: "Right Option (or your configured hotkey)"
                )
            ]

        case .recording:
            return [
                TutorialTopic(
                    title: "Recording Modes",
                    subtitle: "Choose between toggle and push-to-talk",
                    icon: "record.circle",
                    content: "Embr Voice supports two recording modes: Toggle mode (tap to start, tap to stop) and Push-to-Talk mode (hold to record, release to stop).",
                    steps: [
                        "Quick tap: Starts hands-free recording (tap again to stop)",
                        "Press and hold: Push-to-talk mode (release to stop and transcribe)",
                        "Double-tap Escape: Cancel current recording without transcribing"
                    ],
                    tips: [
                        "Push-to-talk is great for quick voice commands",
                        "Toggle mode is perfect for longer dictation sessions",
                        "You can see the recording timer in the recorder window"
                    ]
                ),
                TutorialTopic(
                    title: "Recorder Styles",
                    subtitle: "Mini recorder or notch interface",
                    icon: "rectangle.on.rectangle",
                    content: "Choose between two beautiful recorder interfaces: the floating Mini Recorder or the elegant Notch Recorder (for Macs with a notch).",
                    steps: [
                        "Open Settings → General → Recorder Style",
                        "Select your preferred style",
                        "The recorder will appear in your chosen style on next recording"
                    ]
                ),
                TutorialTopic(
                    title: "Audio Input Settings",
                    subtitle: "Configure your microphone",
                    icon: "mic.fill",
                    content: "Select which microphone to use for recording. You can use the system default, choose a specific device, or set up prioritized devices.",
                    steps: [
                        "Open Settings → Audio Input",
                        "Choose 'System Default' for automatic device selection",
                        "Or select 'Custom Device' to always use a specific microphone",
                        "Or use 'Prioritized Devices' to create a fallback list"
                    ],
                    tips: [
                        "Embr Voice automatically handles device hot-swapping",
                        "System audio can be muted during recording to avoid interference"
                    ]
                ),
                TutorialTopic(
                    title: "Transcribe Audio Files",
                    subtitle: "Transcribe existing recordings",
                    icon: "waveform.circle.fill",
                    content: "You can transcribe audio files you already have, not just live recordings.",
                    steps: [
                        "Navigate to the 'Transcribe Audio' tab in the main window",
                        "Drag and drop an audio file, or click to browse",
                        "Select your preferred model and language",
                        "Click 'Transcribe' and wait for the result"
                    ],
                    tips: [
                        "Supported formats: WAV, MP3, M4A, and more",
                        "Longer files may take several minutes to process"
                    ]
                )
            ]

        case .aiEnhancement:
            return [
                TutorialTopic(
                    title: "What is AI Enhancement?",
                    subtitle: "Polish your transcripts with AI",
                    icon: "sparkle.magnifyingglass",
                    content: "AI Enhancement uses advanced language models to improve your transcriptions by fixing grammar, adding punctuation, improving clarity, and even applying custom transformations.",
                    tips: [
                        "Enhancement happens after transcription is complete",
                        "You can still access the original transcript in History",
                        "Different AI providers offer different capabilities"
                    ]
                ),
                TutorialTopic(
                    title: "Using Enhancement Prompts",
                    subtitle: "Customize AI behavior",
                    icon: "text.bubble",
                    content: "Enhancement prompts tell the AI how to process your transcript. You can use pre-built prompts or create your own custom ones.",
                    steps: [
                        "Open Settings → Enhancement",
                        "Browse the available prompts (Grammar Fix, Professional Tone, etc.)",
                        "Select a prompt or create a custom one",
                        "Enable AI Enhancement toggle",
                        "Your next transcription will be enhanced automatically"
                    ]
                ),
                TutorialTopic(
                    title: "Custom Prompts",
                    subtitle: "Create your own transformations",
                    icon: "pencil.circle",
                    content: "Create custom prompts to transform your speech into specific formats like emails, code comments, social media posts, and more.",
                    steps: [
                        "Open Settings → Enhancement",
                        "Click 'Add Custom Prompt'",
                        "Give it a descriptive name",
                        "Write your prompt (e.g., 'Convert this to a professional email')",
                        "Save and select it as your active prompt"
                    ],
                    tips: [
                        "Be specific in your prompts for better results",
                        "You can create prompts for different use cases",
                        "Experiment with different phrasings to find what works best"
                    ]
                ),
                TutorialTopic(
                    title: "AI Provider Setup",
                    subtitle: "Configure OpenAI, Anthropic, or other services",
                    icon: "key.fill",
                    content: "To use AI Enhancement, you need to configure at least one AI provider with your API key.",
                    steps: [
                        "Open Settings → Enhancement → AI Providers",
                        "Select your preferred provider (OpenAI, Anthropic, etc.)",
                        "Enter your API key",
                        "Choose your preferred model",
                        "Test the connection"
                    ],
                    tips: [
                        "API keys are stored securely in your Mac's Keychain",
                        "Different providers offer different models and pricing",
                        "You can switch providers anytime"
                    ]
                )
            ]

        case .powerMode:
            return [
                TutorialTopic(
                    title: "What is Power Mode?",
                    subtitle: "Context-aware transcription settings",
                    icon: "sparkles",
                    content: "Power Mode automatically applies different transcription settings based on which app you're using or which website you're on. It's like having multiple transcription profiles that activate automatically.",
                    tips: [
                        "Create different configurations for work vs. personal apps",
                        "Use different models for different contexts",
                        "Apply specific AI prompts based on what you're doing"
                    ]
                ),
                TutorialTopic(
                    title: "Creating Power Modes",
                    subtitle: "Set up app-specific configurations",
                    icon: "plus.circle.fill",
                    content: "Create a Power Mode configuration to automatically use specific settings when you're in certain apps.",
                    steps: [
                        "Open Settings → Power Mode (if available in sidebar)",
                        "Click 'Add New Configuration'",
                        "Choose to match by App or by URL pattern",
                        "Select the app or enter URL pattern",
                        "Configure model, language, AI prompt, and other settings",
                        "Enable the configuration"
                    ]
                ),
                TutorialTopic(
                    title: "URL-Based Power Modes",
                    subtitle: "Smart transcription for web apps",
                    icon: "globe",
                    content: "Create Power Modes that activate when you're on specific websites, perfect for web-based tools like Gmail, Notion, or Google Docs.",
                    steps: [
                        "Create a new Power Mode configuration",
                        "Select 'URL Pattern' as the trigger",
                        "Enter the URL pattern (e.g., 'mail.google.com')",
                        "Configure your preferred settings",
                        "The configuration will activate automatically when you visit that site"
                    ],
                    tips: [
                        "Use wildcards for broader matching (e.g., '*.google.com')",
                        "You can have multiple configurations for different sites",
                        "Configurations are checked from top to bottom"
                    ]
                ),
                TutorialTopic(
                    title: "Screen Context Integration",
                    subtitle: "AI reads your screen for better accuracy",
                    icon: "eye.circle",
                    content: "Power Mode can capture on-screen text to give the AI context about what you're working on, dramatically improving transcription accuracy.",
                    tips: [
                        "Screen Recording permission is required for this feature",
                        "All screen data is processed locally",
                        "Data is never stored, only used during transcription"
                    ]
                )
            ]

        case .models:
            return [
                TutorialTopic(
                    title: "Local vs Cloud Models",
                    subtitle: "Understanding your options",
                    icon: "cloud.fill",
                    content: "Embr Voice supports both local models (running on your Mac) and cloud models (running on remote servers). Local models are private and work offline, while cloud models are often more accurate but require internet.",
                    tips: [
                        "Local models: Private, offline, free after download",
                        "Cloud models: More accurate, require API keys, cost per use",
                        "You can switch between them anytime"
                    ]
                ),
                TutorialTopic(
                    title: "Downloading Local Models",
                    subtitle: "Install Whisper or Parakeet models",
                    icon: "arrow.down.circle.fill",
                    content: "Local models need to be downloaded before use. Choose based on accuracy vs. speed tradeoffs.",
                    steps: [
                        "Open Settings → Models",
                        "Browse available local models",
                        "Click 'Download' on your preferred model",
                        "Wait for download to complete",
                        "The model is now available for transcription"
                    ],
                    tips: [
                        "Tiny models are fastest but less accurate",
                        "Large models are most accurate but slower",
                        "Medium models offer the best balance for most users"
                    ]
                ),
                TutorialTopic(
                    title: "Language Selection",
                    subtitle: "Transcribe in your language",
                    icon: "globe.americas.fill",
                    content: "Embr Voice supports transcription in 90+ languages. You can set a default language or let the model auto-detect.",
                    steps: [
                        "Open Settings → Models",
                        "Find the 'Language' section",
                        "Choose 'Auto-detect' or select a specific language",
                        "Your choice applies to all future transcriptions"
                    ]
                ),
                TutorialTopic(
                    title: "Cloud Model Setup",
                    subtitle: "Use Deepgram, Groq, and more",
                    icon: "server.rack",
                    content: "Cloud models offer state-of-the-art accuracy with minimal latency. Configure them in the Models settings.",
                    steps: [
                        "Open Settings → Models",
                        "Switch to the 'Cloud' tab",
                        "Choose a provider (Deepgram, Groq, ElevenLabs, etc.)",
                        "Enter your API key in Settings → Enhancement → AI Providers",
                        "Select the cloud model as your default"
                    ]
                )
            ]

        case .customization:
            return [
                TutorialTopic(
                    title: "Keyboard Shortcuts",
                    subtitle: "Customize your hotkeys",
                    icon: "keyboard",
                    content: "Configure one or two keyboard shortcuts to trigger Embr Voice from anywhere on your Mac.",
                    steps: [
                        "Open Settings → General → VoiceInk Shortcuts",
                        "Choose Hotkey 1 (e.g., Right Option, Right Command, or Custom)",
                        "Optionally add Hotkey 2 for additional flexibility",
                        "Test your hotkey to ensure it works"
                    ],
                    tips: [
                        "Choose keys that won't conflict with other apps",
                        "Option keys are popular choices",
                        "You can use custom keyboard combinations"
                    ]
                ),
                TutorialTopic(
                    title: "Custom Dictionary",
                    subtitle: "Teach Embr Voice your vocabulary",
                    icon: "character.book.closed.fill",
                    content: "Add custom words, names, and technical terms to improve transcription accuracy for your specific vocabulary.",
                    steps: [
                        "Open Settings → Dictionary",
                        "Click 'Add Word' in the Spellings section",
                        "Enter the word or phrase exactly as it should appear",
                        "The model will now recognize this word better",
                        "Use Word Replacements to auto-correct common mistakes"
                    ],
                    tips: [
                        "Add proper nouns, brand names, and technical jargon",
                        "Add words that the model frequently gets wrong",
                        "Use consistent capitalization"
                    ]
                ),
                TutorialTopic(
                    title: "Word Replacements",
                    subtitle: "Auto-correct common errors",
                    icon: "arrow.2.squarepath",
                    content: "Create automatic text replacements to fix common transcription errors or create shortcuts.",
                    steps: [
                        "Open Settings → Dictionary → Replacements tab",
                        "Click 'Add Replacement'",
                        "Enter the word/phrase as transcribed",
                        "Enter what it should be replaced with",
                        "Replacements happen automatically after transcription"
                    ]
                ),
                TutorialTopic(
                    title: "Output Preferences",
                    subtitle: "Control how transcripts are delivered",
                    icon: "doc.on.clipboard",
                    content: "Customize how and where your transcriptions appear.",
                    steps: [
                        "Open Settings → General",
                        "Configure 'Paste Method' (standard or AppleScript)",
                        "Toggle 'Preserve transcript in clipboard' if desired",
                        "Enable 'Sound feedback' for audio cues"
                    ]
                ),
                TutorialTopic(
                    title: "Appearance Settings",
                    subtitle: "Menu bar, dock icon, and startup",
                    icon: "paintbrush.fill",
                    content: "Customize how Embr Voice appears in your macOS interface.",
                    steps: [
                        "Open Settings → General",
                        "Toggle 'Hide Dock Icon' to use menu bar only",
                        "Enable 'Launch at Login' to start automatically",
                        "Choose your preferred recorder style (Mini or Notch)"
                    ]
                )
            ]

        case .advanced:
            return [
                TutorialTopic(
                    title: "Data Privacy & Cleanup",
                    subtitle: "Manage your transcription data",
                    icon: "lock.shield.fill",
                    content: "Configure automatic deletion of recordings and transcripts to maintain your privacy.",
                    steps: [
                        "Open Settings → General → Data & Privacy",
                        "Enable automatic cleanup if desired",
                        "Set retention period (immediately, 24 hours, 7 days, etc.)",
                        "Old transcripts and recordings will be deleted automatically"
                    ],
                    tips: [
                        "All data is stored locally on your Mac",
                        "You can manually delete items from the History tab",
                        "Audio files are separate from transcript text"
                    ]
                ),
                TutorialTopic(
                    title: "Transcription History",
                    subtitle: "Access past transcriptions",
                    icon: "clock.fill",
                    content: "View, search, and manage all your previous transcriptions from the History tab.",
                    steps: [
                        "Navigate to the History tab in the main window",
                        "Browse your transcription history",
                        "Click any transcript to view details",
                        "Copy, edit, or delete transcripts as needed"
                    ],
                    tips: [
                        "Use the search bar to find specific transcripts",
                        "Both original and enhanced versions are saved",
                        "You can re-transcribe from the original audio"
                    ]
                ),
                TutorialTopic(
                    title: "Import & Export Settings",
                    subtitle: "Backup your configuration",
                    icon: "arrow.up.arrow.down.circle",
                    content: "Export your settings, prompts, and configurations to back them up or transfer to another Mac.",
                    steps: [
                        "Open Settings → General → Data Management",
                        "Click 'Export Settings' to create a backup file",
                        "Save the file to a safe location",
                        "Use 'Import Settings' on another Mac to restore"
                    ],
                    tips: [
                        "API keys are NOT included in exports for security",
                        "All prompts, shortcuts, and preferences are saved",
                        "Regular exports are recommended as backups"
                    ]
                ),
                TutorialTopic(
                    title: "Middle-Click Recording",
                    subtitle: "Use your mouse to record",
                    icon: "computermouse.fill",
                    content: "Enable middle mouse button as an alternative way to trigger recording.",
                    steps: [
                        "Open Settings → General → Other App Shortcuts",
                        "Enable 'Middle-Click Toggle'",
                        "Optionally adjust the activation delay",
                        "Middle-click your mouse to start/stop recording"
                    ]
                ),
                TutorialTopic(
                    title: "System Integration",
                    subtitle: "Media control and muting",
                    icon: "speaker.wave.2.fill",
                    content: "Embr Voice can automatically manage your system audio during recording.",
                    steps: [
                        "Open Settings → General → Recording Feedback",
                        "Enable 'Mute system audio during recording'",
                        "Your media will pause and audio will mute automatically",
                        "Everything resumes when recording stops"
                    ],
                    tips: [
                        "Prevents background noise from interfering",
                        "Works with music, videos, and system sounds",
                        "Can be disabled if you prefer manual control"
                    ]
                ),
                TutorialTopic(
                    title: "Keyboard Shortcut Conflicts",
                    subtitle: "Troubleshooting hotkey issues",
                    icon: "exclamationmark.triangle.fill",
                    content: "If your hotkey doesn't work, it might be conflicting with another app.",
                    steps: [
                        "Try a different hotkey in Settings → General",
                        "Check System Settings → Keyboard → Keyboard Shortcuts",
                        "Disable conflicting shortcuts in other apps",
                        "Restart Embr Voice after changing hotkeys"
                    ],
                    tips: [
                        "Right Option and Right Command are usually safe choices",
                        "Custom shortcuts give you maximum flexibility",
                        "Some apps capture hotkeys before they reach Embr Voice"
                    ]
                )
            ]
        }
    }
}

struct TutorialTopic {
    let title: String
    let subtitle: String?
    let icon: String?
    let content: String
    let steps: [String]?
    let tips: [String]?
    let keyboardShortcut: String?

    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        content: String,
        steps: [String]? = nil,
        tips: [String]? = nil,
        keyboardShortcut: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content
        self.steps = steps
        self.tips = tips
        self.keyboardShortcut = keyboardShortcut
    }
}

#Preview {
    TutorialView()
        .frame(width: 900, height: 700)
}
