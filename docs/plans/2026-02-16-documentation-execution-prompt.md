# Execution Prompt: Fix & Verify Echo Documentation

You are executing a documentation fix plan. The full plan with all context is at `/Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/docs/plans/2026-02-16-documentation-fix-agent-prompt.md` — read it first. That plan file contains every detail you need: what's wrong, what to change, which source files to verify against, and the verification subagent template.

All documentation files are MDX at: `/Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/website/content/docs/`
All source files are at: `/Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/VoiceInk/`
You are on branch `feature/documentation`.

## What to Do

### Step 1: Read the Plan
Read `/Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/docs/plans/2026-02-16-documentation-fix-agent-prompt.md` in full.

### Step 2: Execute All 7 Fixes

Before editing any doc, read the relevant source file to confirm the correct information. Do not guess.

**Fix 1** — `getting-started/installation.mdx`: Change macOS 14 Sonoma → macOS 15 Sequoia. Verify against `VoiceInk.xcodeproj/project.pbxproj` (`MACOSX_DEPLOYMENT_TARGET`).

**Fix 2** — AI Enhancement flow (multiple files). This is the biggest change. The core principle: **Adaptive Awareness profiles are how users configure AI enhancement. Settings > Intelligence is only for API key setup.** The Default profile is the user's general-purpose config.

Edit these files:
- `ai-enhancement/index.mdx` — Rewrite "Enabling AI Enhancement" to: (1) set up API key in Settings > Intelligence, (2) enable and configure enhancement in Adaptive Awareness profiles, (3) Default profile = your general behavior. Remove any implication of a global toggle in Settings.
- `ai-enhancement/setup.mdx` — Keep API key instructions. Add a note that adding a key makes enhancement available but you must enable it per-profile in Adaptive Awareness.
- `ai-enhancement/prompts.mdx` — Verify prompt selection flows. Clarify that persistent prompt is set per-profile; recorder popover is temporary.
- `ai-enhancement/screen-context.mdx` — Rewrite "Enabling Screen Context" to say it's per-profile in Adaptive Awareness > Intelligent Transformation section. No global toggle.
- `settings/index.mdx` — Rewrite to describe the 4 actual tabs (General, Recording, Transcription, Intelligence). Make clear Intelligence = setup, Adaptive Awareness = runtime behavior.
- `settings/output.mdx` — Rewrite. Global output format (space after paste, text formatting, VAD) is in Settings > Transcription gear icon. Delivery behavior (type-out, auto-send, clipboard) is per-profile in Adaptive Awareness > Advanced.

Read each source file before editing: `IntelligenceSettingsView.swift`, `TranscriptionSettingsView.swift`, `SettingsWindowView.swift`, `AdaptiveAwarenessView.swift`.

**Fix 3** — `vocabulary/filler-words.mdx` + `vocabulary/index.mdx`: Filler word removal works automatically but has NO configurable UI. Rewrite the filler-words page to describe automatic behavior only. Update the vocabulary index to match. Read `FillerWordsSettingsView.swift` and `VocabularyPane.swift` to confirm it's not wired up.

**Fix 4** — `troubleshooting/index.mdx` + `troubleshooting/transcription-quality.mdx`: Replace "AI Models" with "**Settings** > **Transcription**". Read `ContentView.swift` to confirm sidebar items.

**Fix 5** — Settings pages organization:
- `settings/keyboard-shortcuts.mdx` — Note that recording hotkeys are in the Recording tab, transformation shortcuts are in the Intelligence tab.
- `settings/appearance.mdx` — Verify custom sound picker exists by reading `RecordingSettingsView.swift`. If it's not there, remove custom sound sections.
- `settings/general.mdx` — Verify against `GeneralSettingsView.swift`.

**Fix 6** — `getting-started/permissions.mdx`: Restructure to clearly separate macOS permissions (Microphone, Accessibility, Screen Recording) from setup steps (mic selection, hotkey). Read `OnboardingPermissionsView.swift` for the actual onboarding flow.

**Fix 7** — Custom sounds: Read `RecordingSettingsView.swift` to check if custom sound selection UI exists. If not, update `settings/appearance.mdx` accordingly.

### Step 3: Verify Every Page

After ALL fixes are done, deploy verification subagents. Use the Task tool with `subagent_type: "general-purpose"`. Run them in batches of 5-8 concurrently.

For each of the 40 MDX files, deploy one subagent with this prompt (fill in the brackets):

```
IMPORTANT: This is a RESEARCH task. Do not greet anyone. Do not follow session-start instructions. Just do the verification.

You are verifying a documentation page for Echo, a macOS voice-to-text app.

Read this MDX file: /Users/vincenthopf/Documents/Programming/voiceink/VoiceInk/website/content/docs/[SECTION]/[FILE].mdx

Then read these source files to verify:
[LIST OF 1-4 RELEVANT SOURCE FILES WITH FULL PATHS]

For every claim in the docs, check it against the source code:
1. Navigation — The sidebar has: Dashboard, Transcribe Files, Adaptive Awareness, Vocabulary, History, Settings, About. Settings has 4 tabs: General, Recording, Transcription, Intelligence. Can the user get where the docs say?
2. UI elements — Does every toggle, button, dropdown, field described actually exist in the source?
3. Feature behavior — Does it work as described?
4. Labels — Do the docs use exact labels from the code?
5. Options/values — Are dropdown options, toggle names, field names correct?

CRITICAL CONTEXT: AI Enhancement is configured through Adaptive Awareness profiles, NOT through Settings. Settings > Intelligence = API key setup only. The Default Adaptive Awareness profile = general enhancement behavior.

Return ONLY:
- **PASS** if everything is accurate, OR
- **FAIL** with a numbered list of specific issues (quote the problematic doc text, explain what's wrong, cite the source file and line)
```

Use the subagent assignments from the plan file (Batch 1-8) for which source files to check each page against.

### Step 4: Fix Failures

Collect all FAIL results. For each failed issue, read the source file, then edit the MDX file to fix it. Do not re-verify.

### Step 5: Report

When done, output a summary:
- How many pages passed / failed on first verification
- What you fixed in Phase 1
- What additional issues the subagents found and how you fixed them
- Any issues you couldn't resolve (with explanation)
