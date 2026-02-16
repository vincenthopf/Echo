# Documentation Fix & Verification Agent Prompt

## Your Task

You are fixing and verifying the user-facing documentation for **Echo**, a macOS voice-to-text app. The documentation lives at `/Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/website/content/docs/` as 40 MDX files across 11 sections.

You have two phases:
1. **Fix** all known documentation issues (listed below)
2. **Verify** every single documentation page against the actual source code by deploying one subagent per MDX file

---

## Phase 1: Fix Known Issues

### CRITICAL FIX 1: macOS Version Requirement

**File:** `getting-started/installation.mdx`

Change "macOS 14 (Sonoma) or later" to "macOS 15 (Sequoia) or later". The actual deployment target in `VoiceInk.xcodeproj/project.pbxproj` is `MACOSX_DEPLOYMENT_TARGET = 15.0`.

Also update the system requirements text — "Apple Silicon recommended" and Intel notes should still be correct, but verify.

### CRITICAL FIX 2: AI Enhancement Is Configured Through Adaptive Awareness, Not Settings

This is the most important architectural change. **AI Enhancement (Intelligent Transformation) is entirely managed through Adaptive Awareness profiles.** There is no separate toggle or configuration in Settings for enabling AI enhancement on recordings. The user:

1. Goes to **Settings > Intelligence** tab ONLY to add their API key and select a provider/model
2. Then goes to **Adaptive Awareness** and configures AI enhancement per-profile (including the **Default** profile for general use)
3. The Default profile acts as the fallback — whatever you configure there is your "general" AI enhancement behavior

This means the following docs need updating:

**`ai-enhancement/index.mdx`** — The "Enabling AI Enhancement" section currently says to "go to Settings, select the Intelligence tab" and configure everything there. This is wrong. The correct flow is:
- Set up your API key in **Settings > Intelligence** (one-time setup)
- Then configure AI Enhancement in **Adaptive Awareness** profiles — specifically the **Default** profile for your general behavior
- Each profile independently controls: whether enhancement is on, which provider/model, which prompt, screen capture, clipboard context
- The recorder's enhancement popover lets you toggle and switch prompts on the fly, but the persistent configuration lives in profiles

**`ai-enhancement/setup.mdx`** — This page is mostly correct since it's about API key setup, which IS in Settings > Intelligence. But verify the flow text doesn't imply that adding an API key enables enhancement globally — it just makes it available. You still need to enable it per-profile.

**`ai-enhancement/prompts.mdx`** — The "Selecting a Prompt" section describes selecting from the recorder popover and from the main window grid. Verify both of these are still accurate. The key point: prompt selection in the recorder is temporary (for the current session), while the persistent prompt is set in the Adaptive Awareness profile.

**`ai-enhancement/screen-context.mdx`** — The "Enabling Screen Context" section says "The screen capture context toggle is managed through Echo's enhancement settings." This is vague. Clarify that screen capture is enabled per-profile in Adaptive Awareness (in the Intelligent Transformation section of each profile). There is no global toggle for screen capture.

**`ai-enhancement/selected-text.mdx`** — Says "There's nothing to configure. Selected text context is always active when AI Enhancement is enabled." Verify this is accurate.

**`settings/index.mdx`** — The overview should accurately describe what each Settings tab does:
- **General**: Appearance (Dock icon), startup, updates, permissions, privacy controls, backup/restore, reset
- **Recording**: Hotkeys, audio input mode, microphone sensitivity, sound feedback, paste compatibility
- **Transcription**: Model selection, language, output format settings (space after paste, text formatting, VAD)
- **Intelligence**: API key setup for AI providers, model selection per provider, Ollama config, transformation shortcuts
- Make clear that Intelligence is for SETUP (API keys, provider connection) — the actual enhancement behavior is configured through Adaptive Awareness profiles

**`settings/output.mdx`** — Type-out mode, auto-send, and clipboard behavior are ALL per-profile settings in Adaptive Awareness. This page should be rewritten to explain that output format settings (space after paste, text formatting, VAD) are in Settings > Transcription, while delivery behavior (type-out, auto-send, clipboard preservation) is per-profile in Adaptive Awareness. Currently the page mixes these up.

### CRITICAL FIX 3: Filler Words Page

**File:** `vocabulary/filler-words.mdx`

`FillerWordsSettingsView` exists as a SwiftUI component but is NEVER referenced from any parent view. The VocabularyPane (`VoiceInk/Views/VocabularyPane.swift`) only has two sections: Smart Corrections and Personal Vocabulary. No filler words settings are accessible in the UI.

Filler word removal DOES work in the background (enabled by default via `@AppStorage("RemoveFillerWords")`) but users cannot:
- Toggle it on/off
- Add custom filler words
- Remove words from the list

**Action:** Rewrite this page to accurately describe what actually happens: filler words are automatically removed from all transcriptions. The built-in list is: `uh, um, uhm, umm, uhh, uhhh, ah, eh, hmm, hm, mmm, mm, mh, ha, ehh`. This cannot be customized through the UI. Remove all references to toggles, add buttons, and remove buttons.

Also update `vocabulary/index.mdx` — it says you can switch between Smart Corrections and Personal Vocabulary sections. That's correct. But its description of filler words should match the rewritten page (automatic, not configurable).

### CRITICAL FIX 4: "AI Models" Navigation References

**Files:** `troubleshooting/index.mdx`, `troubleshooting/transcription-quality.mdx`

Replace every instance of "Open Echo and go to **AI Models**" with the correct navigation: "Open **Settings** and go to the **Transcription** tab". There is no "AI Models" sidebar item.

The actual sidebar items are: Dashboard, Transcribe Files, Adaptive Awareness, Vocabulary, History, Settings, About.

### MODERATE FIX 5: Settings Pages Organization

The docs have 5 settings pages (Recording, Output, Keyboard Shortcuts, Appearance, General) but the actual Settings has 4 tabs (General, Recording, Transcription, Intelligence).

Consider:
- `settings/recording.mdx` — Currently correct, maps to Recording tab
- `settings/output.mdx` — Needs rewrite (see Fix 2 above). Output format is in Transcription tab; delivery behavior is in Adaptive Awareness
- `settings/keyboard-shortcuts.mdx` — Recording hotkeys are in the Recording tab. Transformation shortcuts (Cmd+E, Cmd+1-0) are in the Intelligence tab. The page should note both locations.
- `settings/appearance.mdx` — "Hide Dock Icon" is in General tab. Sound feedback is in Recording tab. Custom sounds — verify if this UI actually exists. If the custom sound picker is not wired up (similar to filler words), note that.
- `settings/general.mdx` — Maps to General tab, should be mostly correct

### MODERATE FIX 6: Permissions Page

**File:** `getting-started/permissions.mdx`

The "Microphone Selection" and "Keyboard Shortcut" sections are under "Required Permissions" but they're not actually permissions — they're setup steps. The page conflates macOS permissions (Microphone, Accessibility, Screen Recording) with initial configuration (mic selection, hotkey setup). Consider restructuring to separate these clearly.

### MINOR FIX 7: Verify Custom Sound Settings

**File:** `settings/appearance.mdx`

The page describes custom start/stop sound selection with folder icons, play icons, and reset icons. Verify this UI actually exists and is wired up. If not, remove those sections.

---

## Phase 2: Page-by-Page Verification

After completing all fixes, deploy **one subagent per documentation page** (40 subagents total, but run them in parallel batches). Each subagent should:

1. **Read the MDX file** it's assigned to
2. **Read the relevant source files** to verify every claim in the docs
3. **Check that every navigation instruction is correct** (e.g., "Click X in the sidebar" — does X actually exist in the sidebar?)
4. **Check that every UI element described exists** (toggles, buttons, dropdowns, fields)
5. **Check that every setting/option listed is accurate** (correct names, correct values, correct behavior)
6. **Return a PASS or FAIL verdict** with specific line-by-line issues if FAIL

### Subagent Assignment (group by section for parallel execution)

**Batch 1 — Getting Started:**
- `getting-started/index.mdx` → Verify against `ContentView.swift`, sidebar items, feature list
- `getting-started/installation.mdx` → Verify macOS version (15.0), download flow, DMG, updates
- `getting-started/quickstart.mdx` → Verify recording flow, model selection, pipeline description
- `getting-started/permissions.mdx` → Verify permission types, setup flow, status indicators

**Batch 2 — Transcription:**
- `transcription/index.mdx` → Verify three approaches, model tabs, choosing a model flow
- `transcription/local-models.mdx` → Verify against `PredefinedModels.swift` (model names, sizes, languages)
- `transcription/cloud-services.mdx` → Verify providers, API key flow, Soniox vocabulary feature
- `transcription/apple-speech.mdx` → Verify macOS 26 requirement, language list against `appleNativeLanguages`
- `transcription/language-selection.mdx` → Verify language behavior per model type, menu bar language change
- `transcription/audio-file.mdx` → Verify against `AudioTranscribeView.swift`, supported formats, flow

**Batch 3 — AI Enhancement:**
- `ai-enhancement/index.mdx` → Verify enabling flow (MUST go through Adaptive Awareness), context sources
- `ai-enhancement/setup.mdx` → Verify against `AIService.swift` providers, API key flow in Intelligence tab
- `ai-enhancement/prompts.mdx` → Verify against `PredefinedPrompts.swift`, `PromptTemplates.swift`, editor flow
- `ai-enhancement/screen-context.mdx` → Verify capture behavior, vision mode, per-profile toggle
- `ai-enhancement/selected-text.mdx` → Verify selected text strategies, always-on behavior

**Batch 4 — Adaptive Awareness:**
- `adaptive-awareness/index.mdx` → Verify against `AdaptiveAwarenessView.swift`, precedence rules
- `adaptive-awareness/profiles.mdx` → Verify profile CRUD, default profile behavior, editor sections
- `adaptive-awareness/triggers.mdx` → Verify trigger types, browser list against `BrowserURLService.swift`, Any/All logic
- `adaptive-awareness/advanced.mdx` → Verify per-profile settings against `PowerModeConfig` fields

**Batch 5 — Vocabulary:**
- `vocabulary/index.mdx` → Verify two-section layout, filler words description (automatic, not configurable)
- `vocabulary/smart-corrections.mdx` → Verify against `WordReplacementView.swift`, add/edit/delete flow
- `vocabulary/personal-vocabulary.mdx` → Verify against `DictionaryView.swift`, add/manage flow
- `vocabulary/filler-words.mdx` → Verify rewritten content is accurate (automatic removal, no UI)

**Batch 6 — Settings:**
- `settings/index.mdx` → Verify 4-tab structure description matches `SettingsWindowView.swift`
- `settings/recording.mdx` → Verify against `RecordingSettingsView.swift`
- `settings/output.mdx` → Verify rewritten content accurately maps settings to correct locations
- `settings/keyboard-shortcuts.mdx` → Verify hotkey options against `HotkeyManager.swift`, shortcuts locations
- `settings/appearance.mdx` → Verify Dock icon toggle, sound settings, custom sounds
- `settings/general.mdx` → Verify against `GeneralSettingsView.swift`

**Batch 7 — History, Dashboard, Integrations:**
- `history/index.mdx` → Verify against `TranscriptionHistoryView.swift`, search, selection, export
- `history/auto-cleanup.mdx` → Verify retention options, cleanup behavior
- `dashboard/index.mdx` → Verify against `MetricsView.swift`, stats, trend chart
- `integrations/index.mdx` → Verify overview accuracy
- `integrations/siri-shortcuts.mdx` → Verify against `AppShortcuts.swift`, Siri phrases
- `integrations/custom-models.mdx` → Verify against `AddCustomModelCardView.swift`, form fields

**Batch 8 — Troubleshooting & Privacy:**
- `troubleshooting/index.mdx` → Verify navigation references, common issues
- `troubleshooting/permissions.mdx` → Verify fix steps, permission types
- `troubleshooting/audio-issues.mdx` → Verify audio input modes, troubleshooting steps
- `troubleshooting/transcription-quality.mdx` → Verify model recommendations, navigation references
- `privacy/index.mdx` → Verify data storage claims, no-telemetry claims, permission table

### Subagent Prompt Template

For each subagent, use this prompt structure:

```
You are verifying a documentation page for Echo, a macOS voice-to-text app.

**Your MDX file:** [path to MDX file]
**Source files to check against:** [list of relevant source files]

Read the MDX file, then read each source file. For every claim in the documentation, verify it against the source code.

Check:
1. Navigation instructions — can the user actually get to where the docs say? The sidebar has: Dashboard, Transcribe Files, Adaptive Awareness, Vocabulary, History, Settings, About. Settings has 4 tabs: General, Recording, Transcription, Intelligence.
2. UI elements — does every toggle, button, dropdown, and field described in the docs actually exist?
3. Feature behavior — does the feature work as described?
4. Names and labels — do the docs use the exact UI labels from the code?
5. Options and values — are dropdown options, toggle names, and field names correct?

IMPORTANT CONTEXT: AI Enhancement is configured through Adaptive Awareness profiles, NOT through a global toggle in Settings. The Settings > Intelligence tab is only for API key setup and provider connection. The Default Adaptive Awareness profile is how users set their general AI enhancement behavior.

Return:
- **PASS** if everything is accurate
- **FAIL** with a list of specific issues (quote the problematic text and explain what's wrong)
```

### After Verification

Collect all FAIL results. Fix each issue. Do NOT re-verify — just fix what the subagents flagged.

---

## Important Context

### App Structure
- **Sidebar:** Dashboard, Transcribe Files, Adaptive Awareness, Vocabulary, History, Settings, About
- **Settings tabs:** General, Recording, Transcription, Intelligence
- **Deployment target:** macOS 15.0 (Sequoia)
- **App display name:** Echo (bundle display name, product name)
- **Internal code name:** VoiceInk / Embr Voice (never shown to users)

### Key Architecture Decision
Adaptive Awareness is the CORE UI for configuring transcription behavior. The Default profile is the user's general-purpose configuration. Every feature — AI enhancement, type-out mode, auto-send, screen capture, clipboard behavior, model override, language override — is per-profile. Settings is for setup (API keys, hotkeys, model downloads, app preferences), not for runtime behavior.

### Browser Support for URL Triggers
Safari, Arc, Chrome, Edge, Brave, Opera, Vivaldi, Orion, Yandex Browser. NOT Firefox. NOT Zen Browser. (These are defined in code but excluded from `BrowserURLService.allCases`.)

### Source File Locations
All Swift source files are under: `/Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/VoiceInk/`

Key files for verification:
- `Views/ContentView.swift` — Sidebar items, view routing
- `Views/Settings/SettingsWindowView.swift` — Settings tabs
- `Views/Settings/GeneralSettingsView.swift`
- `Views/Settings/RecordingSettingsView.swift`
- `Views/Settings/TranscriptionSettingsView.swift`
- `Views/Settings/IntelligenceSettingsView.swift`
- `Views/VocabularyPane.swift` — Vocabulary sections
- `Views/Dictionary/WordReplacementView.swift`
- `Views/Dictionary/DictionaryView.swift`
- `Views/Components/FillerWordsSettingsView.swift` — EXISTS but NOT wired up
- `Views/AdaptiveAwareness/` — Profile management
- `Views/AI Models/ModelManagementView.swift` — Model list, filters
- `Views/Recorder/MiniRecorderView.swift`, `NotchRecorderView.swift`
- `Views/TranscriptionHistoryView.swift`
- `Views/MetricsView.swift`, `MetricsContent.swift`
- `Views/AudioTranscribeView.swift`
- `Views/MenuBarView.swift`
- `Models/PredefinedModels.swift` — All transcription models
- `Models/PredefinedPrompts.swift` — Default + Assistant prompts
- `Models/PromptTemplates.swift` — 5 templates
- `PowerMode/BrowserURLService.swift` — Browser list
- `PowerMode/ActiveWindowService.swift` — Trigger matching
- `PowerMode/PowerModeConfig.swift` — Profile fields
- `Services/AIService.swift` — AI provider enum
- `Services/AIEnhancementService.swift`
- `Services/FillerWordManager.swift` — Filler word logic
- `HotkeyManager.swift` — Hotkey config
- `AppIntents/AppShortcuts.swift` — Siri Shortcuts
- `VoiceInk.xcodeproj/project.pbxproj` — Deployment target

### Git Context
You are on branch `feature/documentation`. All documentation changes should be made on this branch.
