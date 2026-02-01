# Voice Keyword Recording & Detection Fix

## Overview

Two improvements to the Adaptive Awareness voice keyword system:

1. **Voice-based keyword entry** — Users speak keywords instead of typing them, ensuring the stored keyword matches exactly what Whisper transcribes
2. **Middle-of-text detection** — Fix bug where keywords only trigger when at the start or end of transcription

## Problem Statement

### Keyword Entry
Users currently type keywords manually. This causes mismatches when:
- Whisper transcribes differently than expected (capitalization, spacing)
- Multi-word phrases have subtle variations

### Detection Reliability
Keywords are only detected at the START or END of transcriptions:
- "code review this function" → ✅ detected (start)
- "please do a code review" → ✅ detected (end)
- "I need a code review for this" → ❌ NOT detected (middle)

## Solution

### 1. Voice Keyword Recording UI

Update `VoiceKeywordInput.swift` to add a microphone button:

```
┌─────────────────────────────────────────────┐
│ Existing keywords:                          │
│ ┌─────────────────────┐                     │
│ │ 🗨 "code review"  ✕ │                     │
│ └─────────────────────┘                     │
│                                             │
│ ┌──────────────────┐ ┌─────┐ ┌─────┐       │
│ │ Add keyword      │ │ 🎤  │ │ Add │       │
│ └──────────────────┘ └─────┘ └─────┘       │
│                                             │
│ Type or record a keyword                    │
└─────────────────────────────────────────────┘
```

**Recording flow:**
1. User clicks mic button
2. Button shows pulsing red recording indicator
3. Audio recording starts (using existing `Recorder` class)
4. User speaks the keyword phrase
5. User clicks button again to stop
6. Audio transcribed using active transcription model
7. Result populates text field for review
8. User clicks "Add" to confirm

### 2. Middle-of-Text Detection

Add new detection path in `PromptDetectionService.detectAndStripTriggerWord()`:

**Detection order:**
1. Check trailing (end of text) — existing
2. Check leading (start of text) — existing
3. **Check middle (anywhere in text)** — NEW

**Word boundary rules:**
- Character before keyword must NOT be alphanumeric
- Character after keyword must NOT be alphanumeric
- Prevents "view" matching inside "review"

**Text cleanup after removal:**
- Remove extra whitespace
- Clean up orphaned punctuation
- Capitalize first letter of result

## Files to Modify

### `VoiceInk/Views/AdaptiveAwareness/VoiceKeywordInput.swift`
- Add `@State private var isRecording: Bool = false`
- Add `@State private var isTranscribing: Bool = false`
- Add `@EnvironmentObject var whisperState: WhisperState`
- Add mic button next to text field
- Add recording/transcription logic
- Use `Recorder` for audio capture
- Use transcription service for conversion

### `VoiceInk/Services/PromptDetectionService.swift`
- Add `private func stripMiddleTriggerWord(from:triggerWord:) -> String?`
- Update `detectAndStripTriggerWord()` to call middle detection as fallback
- Handle word boundaries and text cleanup

## No Changes Required

- `PowerModeConfig.swift` — Storage remains `[String]`
- `ActiveWindowService.swift` — Just calls detection service
- `PowerModeManager.swift` — Matching logic unchanged

## Testing

1. **Voice recording:**
   - Record a keyword, verify transcription populates field
   - Add the keyword, verify it appears in list
   - Use keyword in transcription, verify profile activates

2. **Middle detection:**
   - Say keyword at start → should trigger
   - Say keyword at end → should trigger
   - Say keyword in middle → should trigger (NEW)
   - Verify keyword is stripped from final output

3. **Word boundaries:**
   - "activate" should not match in "reactivate"
   - "view" should not match in "review"
