# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Embr Voice is a native macOS voice-to-text transcription application built with SwiftUI and Swift. It provides offline, privacy-focused transcription using local AI models (whisper.cpp and Parakeet) as well as cloud-based transcription services. The app features intelligent context-aware transcription with "Adaptive Awareness" that automatically applies pre-configured settings based on voice triggers, browser URLs, or active applications.

## Build and Development Commands

### First-Time Setup

Build whisper.cpp framework (required before first build):
```bash
cd whisper.cpp && ./build-xcframework.sh
```
This creates `build-apple/whisper.xcframework` which is already linked in the Xcode project.

### Building

```bash
# Open in Xcode (recommended)
open VoiceInk.xcodeproj

# Or build from command line
xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug build
```

Run with Cmd+R in Xcode. Clean build folder with Cmd+Shift+K if needed.

### Testing

```bash
xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInk -destination 'platform=macOS'
```

Tests: `VoiceInkTests/` (unit), `VoiceInkUITests/` (UI)

## Architecture Overview

### Core Components

**VoiceInk.swift** - Main app entry point. Initializes the dependency injection chain:
```
SwiftData ModelContainer → AIEnhancementService → WhisperState → HotkeyManager → MenuBarManager
```
Also configures menu bar extra, main window, and onboarding flow.

**WhisperState** - Central state manager coordinating the recording state machine:
```
idle → recording → transcribing → enhancing → idle
```
Handles model loading/unloading, transcription service orchestration, and UI presentation for mini/notch recorders.

**Recorder** - Audio capture using AVAudioRecorder with 16kHz/16-bit PCM mono format. Manages device selection, hot-swapping, and media playback control.

**TranscriptionService Protocol** - Abstraction for all providers:
- `LocalTranscriptionService` - whisper.cpp XCFramework
- `ParakeetTranscriptionService` - FluidAudio engine
- `CloudTranscriptionService` - Routes to Groq, ElevenLabs, Deepgram, Mistral, Gemini, Soniox, and OpenAI-compatible custom providers
- `NativeAppleTranscriptionService` - Apple's on-device Speech framework

### Adaptive Awareness System

Context-aware transcription profiles that auto-activate based on triggers. Activation precedence (highest to lowest):

1. **Voice Triggers** - Keywords spoken during recording (locks until changed)
2. **URL Patterns** - Browser URL matching via AppleScript (Chrome/Safari/Firefox/Edge/Arc)
3. **App Bundles** - Frontmost app bundle ID matching
4. **Default Profile** - Fallback

Key classes (internally prefixed "PowerMode", displayed as "Adaptive Awareness"):
- **PowerModeConfig** - Profile definition: model, language, prompts, screen capture, auto-send, trigger words
- **ActiveWindowService** - Monitors app/URL changes and voice triggers, applies matching config
- **PowerModeManager** - Persistence via UserDefaults (`powerModeConfigurationsV2`)
- **PowerModeSessionManager** - State transitions and activation source tracking

### Service Layer

Key services in `VoiceInk/Services/`:
- **AIEnhancementService** - Post-transcription AI processing with custom prompts
- **AIService** - AI Enhancement provider integration (Gemini, Anthropic, OpenAI, OpenRouter, Ollama, Custom)
- **AudioDeviceManager** - CoreAudio device enumeration
- **CursorPaster** - Simulated keyboard input for inline text insertion
- **DictionaryContextService** - Custom word/terminology management
- **WordReplacementService** - Smart text replacement rules
- **ScreenCaptureService** - Screen context capture for AI enhancement
- **SelectedTextService** - Selected text via Accessibility APIs

### Data Model

**Transcription** (SwiftData) stored in `~/Library/Application Support/com.VincentHopf.EmbrVoice/default.store`. Auto-cleanup handled by `TranscriptionAutoCleanupService`.

### UI Structure

Views in `VoiceInk/Views/`:
- **Recorder/** - MiniWindowManager (floating), NotchWindowManager (for notched Macs)
- **AdaptiveAwareness/** - ProfileListView + ProfileDetailView (master-detail)
- **Settings/**, **AI Models/**, **Dictionary/**, **Metrics/**, **Onboarding/**

Window managers: MenuBarManager, WindowManager, MiniWindowManager, NotchWindowManager

## Dependencies

SPM packages:
- **Sparkle** - Auto-updates
- **KeyboardShortcuts** - Global hotkeys
- **LaunchAtLogin** - Launch at login
- **MediaRemoteAdapter** - Media playback control (private MediaRemote framework)
- **FluidAudio** - Parakeet model inference
- **Zip** - Archive handling for model downloads
- **AXSwift** - Accessibility APIs
- **KeySender** - Simulated key events
- **SelectedTextKit** - Selected text detection

External: **whisper.xcframework** (built from whisper.cpp submodule)

## Key Implementation Details

### Transcription Pipeline
```
Audio (16kHz PCM) → Model Selection → Transcription Service → AI Enhancement → Output Filter → Clipboard/Paste
```

### File Locations
- Recordings: `~/Library/Application Support/com.VincentHopf.EmbrVoice/Recordings/`
- Whisper models: `~/Library/Application Support/com.VincentHopf.EmbrVoice/WhisperModels/`
- SwiftData store: `~/Library/Application Support/com.VincentHopf.EmbrVoice/default.store`

### Key Patterns
- Swift concurrency (async/await, @MainActor) throughout
- @Published properties in ObservableObject classes for state
- EnvironmentObject injection for shared state (WhisperState, AIService, etc.)
- UserDefaults for preferences, SwiftData for transcription history
- OSLog with subsystem `com.VincentHopf.embrvoice`

### License System
Polar.sh for license management. `LicenseManager` handles validation. Obfuscated keys in `Obfuscator.swift`.

## Notable Files

- `VoiceInk.entitlements` - Microphone, accessibility permissions
- `Models/PredefinedModels.swift` - Available transcription models
- `Models/PredefinedPrompts.swift` - Default AI prompts
- `HotkeyManager.swift` - Global shortcuts
- `AppIntents/` - Siri Shortcuts integration
- `PowerMode/` - Adaptive Awareness logic (internal naming)
