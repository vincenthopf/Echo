# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Embr Voice is a native macOS voice-to-text transcription application built with SwiftUI and Swift. It provides offline, privacy-focused transcription using local AI models (whisper.cpp and Parakeet) as well as cloud-based transcription services. The app features intelligent context-aware transcription with "Power Mode" that automatically applies pre-configured settings based on the active application or URL.

## Build and Development Commands

### Building the Project

1. **Build whisper.cpp framework** (required first-time setup):
```bash
cd whisper.cpp
./build-xcframework.sh
```
This creates `build-apple/whisper.xcframework` which must be linked in the Xcode project.

2. **Build Embr Voice**:
```bash
# Open in Xcode
open VoiceInk/VoiceInk.xcodeproj

# Or build from command line
xcodebuild -project VoiceInk/VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug build
```

3. **Run the app**:
- Use Cmd+R in Xcode, or
- Product > Run

### Testing

Run tests with Xcode:
```bash
xcodebuild test -project VoiceInk/VoiceInk.xcodeproj -scheme VoiceInk -destination 'platform=macOS'
```

Test files are located in:
- `VoiceInk/VoiceInkTests/` - Unit tests
- `VoiceInk/VoiceInkUITests/` - UI tests

### Clean Build

If encountering build issues:
- Clean build folder: Cmd+Shift+K
- Clean build cache: Cmd+Shift+K (twice)

## Architecture Overview

### Core Components

**VoiceInk.swift** (to be renamed to EmbrVoice.swift) - Main app entry point that:
- Initializes SwiftData ModelContainer for transcription storage
- Sets up the dependency injection chain: WhisperState → HotkeyManager → MenuBarManager
- Configures the menu bar extra and main window
- Manages onboarding flow and app lifecycle

**WhisperState** - Central state manager that coordinates:
- Recording state machine (idle → recording → transcribing → enhancing)
- Model loading/unloading for local Whisper and Parakeet models
- Transcription service orchestration (local, cloud, native Apple)
- Mini recorder and notch UI presentation
- Audio file transcription

**Recorder** - Audio recording manager that:
- Handles AVAudioRecorder setup with 16kHz PCM format
- Monitors audio input levels with metering
- Manages audio device selection and hot-swapping
- Controls media playback (pauses during recording)

**TranscriptionService Protocol** - Abstraction for all transcription providers:
- `LocalTranscriptionService` - Uses whisper.cpp XCFramework
- `ParakeetTranscriptionService` - Uses FluidAudio for Parakeet models
- `CloudTranscriptionService` - Proxies to Deepgram, Groq, ElevenLabs, Gemini, Mistral
- `NativeAppleTranscriptionService` - Uses Apple's on-device Speech framework

### Power Mode System

Power Mode provides context-aware transcription settings that activate based on:
- Active application (via bundle identifier matching)
- Browser URL patterns (via AppleScript querying Chrome/Safari/Firefox/Edge/Arc)

**PowerModeConfig** defines per-context settings:
- Transcription model and language
- AI enhancement prompts
- Screen capture integration
- Auto-send behavior

**ActiveWindowService** monitors frontmost app changes and applies matching PowerModeConfig.

**PowerModeManager** stores and retrieves configurations from UserDefaults.

### Service Layer

Key services in `VoiceInk/Services/`:
- **AIEnhancementService** - Post-transcription AI processing with custom prompts
- **AIService** - Integration with OpenAI/Anthropic APIs
- **AudioDeviceManager** - CoreAudio device enumeration and configuration
- **ClipboardManager** - Pasteboard operations
- **CursorPaster** - Simulated keyboard input for inline text insertion
- **DictionaryContextService** - Custom word/terminology management
- **WordReplacementService** - Smart text replacement rules
- **ScreenCaptureService** - Screen context for AI enhancement
- **SelectedTextService** - Reads selected text via Accessibility APIs

### Data Model

**Transcription** (SwiftData model):
- Stored in `~/Library/Application Support/com.VincentHopf.EmbrVoice/default.store`
- Contains transcription text, audio file path, timestamps, metadata
- Managed by `TranscriptionAutoCleanupService` for optional auto-deletion

### UI Structure

Views are organized in `VoiceInk/Views/`:
- **Recorder/** - Mini recorder and notch UI windows
- **Settings/** - Preferences panels
- **AI Models/** - Model management and API key configuration
- **Dictionary/** - Custom word dictionary interface
- **Metrics/** - Usage statistics
- **Onboarding/** - First-run setup flow

Window management:
- **MenuBarManager** - Menu bar extra icon and menu
- **WindowManager** - Main app window configuration
- **MiniWindowManager** - Floating mini recorder window
- **NotchWindowManager** - Notch-style recorder UI (for notched Macs)

## Dependencies

Swift Package Manager dependencies:
- **Sparkle** (2.8.0) - Auto-update framework
- **KeyboardShortcuts** (2.4.0) - Global hotkey registration
- **LaunchAtLogin** (main) - Launch at login functionality
- **MediaRemoteAdapter** (master) - Media playback control via private MediaRemote framework
- **Zip** (2.1.2) - Archive handling for model downloads
- **FluidAudio** (main) - Parakeet model inference engine

External frameworks:
- **whisper.xcframework** - Built from whisper.cpp, must be manually linked

## Key Implementation Notes

### Audio Recording
- Uses 16kHz, 16-bit PCM mono format for Whisper compatibility
- Recordings saved to `~/Library/Application Support/com.VincentHopf.EmbrVoice/Recordings/`
- Automatic device hot-swapping if input device changes during recording
- System audio muting during recording (via MediaRemoteAdapter)

### Model Management
- Local Whisper models stored in `~/Library/Application Support/com.VincentHopf.EmbrVoice/WhisperModels/`
- Parakeet models downloaded to application support directory
- Model loading happens asynchronously on first transcription
- Models are unloaded when app quits to free memory

### Transcription Pipeline
1. Audio recording to WAV file
2. Model selection (based on PowerMode or user preference)
3. Transcription via selected service
4. Optional AI enhancement with custom prompts
5. Output filtering (punctuation, formatting)
6. Delivery via clipboard or direct paste

### License Validation
- Uses Polar.sh for license management
- `LicenseViewModel` handles validation and feature gating
- Obfuscated API keys in `Obfuscator.swift`

## Development Tips

- The app requires macOS 14.0+ and uses Swift concurrency extensively (async/await, @MainActor)
- Most state is managed via @Published properties in ObservableObject classes
- SwiftData is used for transcription history persistence
- UserDefaults stores app preferences and PowerMode configurations
- The bundle identifier is `com.VincentHopf.EmbrVoice`
- Logging uses OSLog with subsystem `com.VincentHopf.embrvoice`

## Notable Files

- `VoiceInk/VoiceInk.entitlements` - Required entitlements (microphone, accessibility, etc.)
- `VoiceInk/Info.plist` - App metadata and permissions descriptions
- `VoiceInk/Models/PredefinedModels.swift` - All available transcription models
- `VoiceInk/Models/PredefinedPrompts.swift` - Default AI enhancement prompts
- `VoiceInk/HotkeyManager.swift` - Global keyboard shortcut handling
- `VoiceInk/AppIntents/` - Siri Shortcuts integration
