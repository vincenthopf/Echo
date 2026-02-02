# Copilot Code Review - Embr Voice / VoiceInk

## Review Philosophy
- Only comment when you have HIGH CONFIDENCE (>80%) that an issue exists
- Be concise: one sentence per comment when possible
- Focus on actionable findings, not observations or minor style nits
- Prioritize issues that could cause runtime crashes, memory leaks, or security vulnerabilities

## Project Context
- **Platform**: macOS native app (SwiftUI + AppKit)
- **Architecture**: MVVM with ObservableObject, EnvironmentObject injection
- **Concurrency**: Swift concurrency (async/await, @MainActor, actors)
- **Data**: SwiftData for persistence, UserDefaults for preferences
- **Audio**: AVAudioRecorder with 16kHz/16-bit PCM mono format
- **AI Integration**: whisper.cpp (local), cloud APIs (Deepgram, Groq, OpenAI, Anthropic)

## Priority Areas (Review These First)

### Security & Safety
- Hardcoded API keys or secrets (check for patterns like `sk-`, `api_key`, credentials)
- Improper handling of user data or transcription content
- Insecure URL handling or network requests
- Missing input validation on external data
- Credential exposure in logs (OSLog statements)

### Correctness
- Force unwraps (`!`) that could crash - prefer `guard let` or `if let`
- Retain cycles in closures - check for missing `[weak self]`
- Main thread violations - UI updates must be on @MainActor
- Race conditions in async code
- Resource leaks (audio sessions, file handles, network connections)
- Off-by-one errors or boundary conditions

### Regressions
- Changes to WhisperState state machine that could break recording flow
- Modifications to transcription pipeline that could corrupt output
- Changes to Adaptive Awareness (PowerMode) activation logic

### Architectural Violations
- Direct UI updates from background threads
- Bypassing the established service layer
- Breaking the dependency injection chain
- Mixing SwiftUI and AppKit inappropriately

## Skip These (Covered by CI / Low Value)
- Code formatting and style (SwiftLint handles this)
- Minor naming suggestions unless truly confusing
- Generic "add comments" suggestions for self-documenting code
- Test file formatting
- TODO comments (we track these separately)
- Multiple issues in one comment - focus on the most critical

## Response Format
For each issue, structure your comment as:
1. **Problem**: State the issue in one clear sentence
2. **Why it matters**: Brief impact explanation (only if not obvious)
3. **Suggested fix**: Provide a code snippet or clear action

## Key Files Reference
When reviewing changes to these critical files, apply extra scrutiny:
- `WhisperState.swift` - Central state machine, affects entire app
- `Recorder.swift` - Audio capture, affects transcription quality
- `VoiceInk.swift` - App entry point, dependency injection
- `PowerMode/*.swift` - Adaptive Awareness logic
- `Services/*.swift` - Core business logic

## Domain Terminology
- **Adaptive Awareness** = PowerMode (internal naming)
- **Mini Recorder** = Floating pill UI for recording status
- **Notch Recorder** = Recording UI positioned at MacBook notch
- **Enhancement** = AI post-processing of transcription
