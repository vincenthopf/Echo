# Embr Voice Tutorial & Documentation

Complete guide to mastering voice transcription with Embr Voice.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Recording & Transcription](#recording--transcription)
- [AI Enhancement](#ai-enhancement)
- [Power Mode](#power-mode)
- [Models & Languages](#models--languages)
- [Customization](#customization)
- [Advanced Features](#advanced-features)

---

## Getting Started

### Welcome to Embr Voice

Embr Voice is a native macOS application that converts your voice to text using powerful AI models. Everything runs locally on your Mac for maximum privacy, with optional cloud services for advanced features.

**Key Benefits:**
- All transcriptions are processed on your device by default
- Your voice data never leaves your Mac unless you choose cloud models
- Transcription history is stored locally and can be auto-deleted

### Quick Setup

Before you start transcribing, make sure you have the required permissions and a keyboard shortcut configured.

**Steps:**
1. Grant Microphone access when prompted
2. Enable Accessibility permissions to paste text automatically
3. Set up your preferred keyboard shortcut (e.g., Right Option key)
4. Download your first transcription model from the Models tab

### First Transcription

Once setup is complete, transcribing is as simple as pressing your hotkey and speaking.

**Steps:**
1. Press your configured hotkey to start recording
2. Speak clearly into your microphone
3. Press the hotkey again to stop (or release if using push-to-talk)
4. Watch as your speech is transcribed and automatically pasted!

**Keyboard Shortcut:** Right Option (or your configured hotkey)

---

## Recording & Transcription

### Recording Modes

Embr Voice supports two recording modes: Toggle mode (tap to start, tap to stop) and Push-to-Talk mode (hold to record, release to stop).

**How it works:**
- **Quick tap:** Starts hands-free recording (tap again to stop)
- **Press and hold:** Push-to-talk mode (release to stop and transcribe)
- **Double-tap Escape:** Cancel current recording without transcribing

**Pro Tips:**
- Push-to-talk is great for quick voice commands
- Toggle mode is perfect for longer dictation sessions
- You can see the recording timer in the recorder window

### Recorder Styles

Choose between two beautiful recorder interfaces: the floating Mini Recorder or the elegant Notch Recorder (for Macs with a notch).

**Steps:**
1. Open Settings → General → Recorder Style
2. Select your preferred style
3. The recorder will appear in your chosen style on next recording

### Audio Input Settings

Select which microphone to use for recording. You can use the system default, choose a specific device, or set up prioritized devices.

**Steps:**
1. Open Settings → Audio Input
2. Choose 'System Default' for automatic device selection
3. Or select 'Custom Device' to always use a specific microphone
4. Or use 'Prioritized Devices' to create a fallback list

**Pro Tips:**
- Embr Voice automatically handles device hot-swapping
- System audio can be muted during recording to avoid interference

### Transcribe Audio Files

You can transcribe audio files you already have, not just live recordings.

**Steps:**
1. Navigate to the 'Transcribe Audio' tab in the main window
2. Drag and drop an audio file, or click to browse
3. Select your preferred model and language
4. Click 'Transcribe' and wait for the result

**Pro Tips:**
- Supported formats: WAV, MP3, M4A, and more
- Longer files may take several minutes to process

---

## AI Enhancement

### What is AI Enhancement?

AI Enhancement uses advanced language models to improve your transcriptions by fixing grammar, adding punctuation, improving clarity, and even applying custom transformations.

**Pro Tips:**
- Enhancement happens after transcription is complete
- You can still access the original transcript in History
- Different AI providers offer different capabilities

### Using Enhancement Prompts

Enhancement prompts tell the AI how to process your transcript. You can use pre-built prompts or create your own custom ones.

**Steps:**
1. Open Settings → Enhancement
2. Browse the available prompts (Grammar Fix, Professional Tone, etc.)
3. Select a prompt or create a custom one
4. Enable AI Enhancement toggle
5. Your next transcription will be enhanced automatically

### Custom Prompts

Create custom prompts to transform your speech into specific formats like emails, code comments, social media posts, and more.

**Steps:**
1. Open Settings → Enhancement
2. Click 'Add Custom Prompt'
3. Give it a descriptive name
4. Write your prompt (e.g., 'Convert this to a professional email')
5. Save and select it as your active prompt

**Pro Tips:**
- Be specific in your prompts for better results
- You can create prompts for different use cases
- Experiment with different phrasings to find what works best

### AI Provider Setup

To use AI Enhancement, you need to configure at least one AI provider with your API key.

**Steps:**
1. Open Settings → Enhancement → AI Providers
2. Select your preferred provider (OpenAI, Anthropic, etc.)
3. Enter your API key
4. Choose your preferred model
5. Test the connection

**Pro Tips:**
- API keys are stored securely in your Mac's Keychain
- Different providers offer different models and pricing
- You can switch providers anytime

---

## Power Mode

### What is Power Mode?

Power Mode automatically applies different transcription settings based on which app you're using or which website you're on. It's like having multiple transcription profiles that activate automatically.

**Pro Tips:**
- Create different configurations for work vs. personal apps
- Use different models for different contexts
- Apply specific AI prompts based on what you're doing

### Creating Power Modes

Create a Power Mode configuration to automatically use specific settings when you're in certain apps.

**Steps:**
1. Open Settings → Power Mode (if available in sidebar)
2. Click 'Add New Configuration'
3. Choose to match by App or by URL pattern
4. Select the app or enter URL pattern
5. Configure model, language, AI prompt, and other settings
6. Enable the configuration

### URL-Based Power Modes

Create Power Modes that activate when you're on specific websites, perfect for web-based tools like Gmail, Notion, or Google Docs.

**Steps:**
1. Create a new Power Mode configuration
2. Select 'URL Pattern' as the trigger
3. Enter the URL pattern (e.g., 'mail.google.com')
4. Configure your preferred settings
5. The configuration will activate automatically when you visit that site

**Pro Tips:**
- Use wildcards for broader matching (e.g., '*.google.com')
- You can have multiple configurations for different sites
- Configurations are checked from top to bottom

### Screen Context Integration

Power Mode can capture on-screen text to give the AI context about what you're working on, dramatically improving transcription accuracy.

**Pro Tips:**
- Screen Recording permission is required for this feature
- All screen data is processed locally
- Data is never stored, only used during transcription

---

## Models & Languages

### Local vs Cloud Models

Embr Voice supports both local models (running on your Mac) and cloud models (running on remote servers). Local models are private and work offline, while cloud models are often more accurate but require internet.

**Key Differences:**
- **Local models:** Private, offline, free after download
- **Cloud models:** More accurate, require API keys, cost per use
- You can switch between them anytime

### Downloading Local Models

Local models need to be downloaded before use. Choose based on accuracy vs. speed tradeoffs.

**Steps:**
1. Open Settings → Models
2. Browse available local models
3. Click 'Download' on your preferred model
4. Wait for download to complete
5. The model is now available for transcription

**Model Sizes:**
- **Tiny models:** Fastest but less accurate
- **Large models:** Most accurate but slower
- **Medium models:** Best balance for most users

### Language Selection

Embr Voice supports transcription in 90+ languages. You can set a default language or let the model auto-detect.

**Steps:**
1. Open Settings → Models
2. Find the 'Language' section
3. Choose 'Auto-detect' or select a specific language
4. Your choice applies to all future transcriptions

### Cloud Model Setup

Cloud models offer state-of-the-art accuracy with minimal latency. Configure them in the Models settings.

**Steps:**
1. Open Settings → Models
2. Switch to the 'Cloud' tab
3. Choose a provider (Deepgram, Groq, ElevenLabs, etc.)
4. Enter your API key in Settings → Enhancement → AI Providers
5. Select the cloud model as your default

---

## Customization

### Keyboard Shortcuts

Configure one or two keyboard shortcuts to trigger Embr Voice from anywhere on your Mac.

**Steps:**
1. Open Settings → General → VoiceInk Shortcuts
2. Choose Hotkey 1 (e.g., Right Option, Right Command, or Custom)
3. Optionally add Hotkey 2 for additional flexibility
4. Test your hotkey to ensure it works

**Pro Tips:**
- Choose keys that won't conflict with other apps
- Option keys are popular choices
- You can use custom keyboard combinations

### Custom Dictionary

Add custom words, names, and technical terms to improve transcription accuracy for your specific vocabulary.

**Steps:**
1. Open Settings → Dictionary
2. Click 'Add Word' in the Spellings section
3. Enter the word or phrase exactly as it should appear
4. The model will now recognize this word better
5. Use Word Replacements to auto-correct common mistakes

**Pro Tips:**
- Add proper nouns, brand names, and technical jargon
- Add words that the model frequently gets wrong
- Use consistent capitalization

### Word Replacements

Create automatic text replacements to fix common transcription errors or create shortcuts.

**Steps:**
1. Open Settings → Dictionary → Replacements tab
2. Click 'Add Replacement'
3. Enter the word/phrase as transcribed
4. Enter what it should be replaced with
5. Replacements happen automatically after transcription

### Output Preferences

Customize how and where your transcriptions appear.

**Steps:**
1. Open Settings → General
2. Configure 'Paste Method' (standard or AppleScript)
3. Toggle 'Preserve transcript in clipboard' if desired
4. Enable 'Sound feedback' for audio cues

### Appearance Settings

Customize how Embr Voice appears in your macOS interface.

**Steps:**
1. Open Settings → General
2. Toggle 'Hide Dock Icon' to use menu bar only
3. Enable 'Launch at Login' to start automatically
4. Choose your preferred recorder style (Mini or Notch)

---

## Advanced Features

### Data Privacy & Cleanup

Configure automatic deletion of recordings and transcripts to maintain your privacy.

**Steps:**
1. Open Settings → General → Data & Privacy
2. Enable automatic cleanup if desired
3. Set retention period (immediately, 24 hours, 7 days, etc.)
4. Old transcripts and recordings will be deleted automatically

**Pro Tips:**
- All data is stored locally on your Mac
- You can manually delete items from the History tab
- Audio files are separate from transcript text

### Transcription History

View, search, and manage all your previous transcriptions from the History tab.

**Steps:**
1. Navigate to the History tab in the main window
2. Browse your transcription history
3. Click any transcript to view details
4. Copy, edit, or delete transcripts as needed

**Pro Tips:**
- Use the search bar to find specific transcripts
- Both original and enhanced versions are saved
- You can re-transcribe from the original audio

### Import & Export Settings

Export your settings, prompts, and configurations to back them up or transfer to another Mac.

**Steps:**
1. Open Settings → General → Data Management
2. Click 'Export Settings' to create a backup file
3. Save the file to a safe location
4. Use 'Import Settings' on another Mac to restore

**Pro Tips:**
- API keys are NOT included in exports for security
- All prompts, shortcuts, and preferences are saved
- Regular exports are recommended as backups

### Middle-Click Recording

Enable middle mouse button as an alternative way to trigger recording.

**Steps:**
1. Open Settings → General → Other App Shortcuts
2. Enable 'Middle-Click Toggle'
3. Optionally adjust the activation delay
4. Middle-click your mouse to start/stop recording

### System Integration

Embr Voice can automatically manage your system audio during recording.

**Steps:**
1. Open Settings → General → Recording Feedback
2. Enable 'Mute system audio during recording'
3. Your media will pause and audio will mute automatically
4. Everything resumes when recording stops

**Pro Tips:**
- Prevents background noise from interfering
- Works with music, videos, and system sounds
- Can be disabled if you prefer manual control

### Keyboard Shortcut Conflicts

If your hotkey doesn't work, it might be conflicting with another app.

**Troubleshooting Steps:**
1. Try a different hotkey in Settings → General
2. Check System Settings → Keyboard → Keyboard Shortcuts
3. Disable conflicting shortcuts in other apps
4. Restart Embr Voice after changing hotkeys

**Pro Tips:**
- Right Option and Right Command are usually safe choices
- Custom shortcuts give you maximum flexibility
- Some apps capture hotkeys before they reach Embr Voice

---

## Need More Help?

- Check the About tab for app information
- Visit our documentation at [embr.sh/docs](https://embr.sh/docs)
- Report issues on GitHub
- Contact support for assistance

---

**Embr Voice** - Your voice, transcribed beautifully. 🎙️✨
