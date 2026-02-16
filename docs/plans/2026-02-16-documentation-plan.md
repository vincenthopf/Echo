# Echo Documentation Plan

## Goal

Create comprehensive user-facing documentation for Echo, served at `echo.vjh.io/docs` using Fumadocs (Next.js). An agent will read the entire codebase and generate the documentation end-to-end.

---

## Platform: Fumadocs

**Why Fumadocs:**
- Next.js native (same ecosystem as the landing page)
- Premium default design with dark/light mode
- MDX support for interactive content
- Built-in search
- Free, open source
- Subpath deployment via `basePath: '/docs'` in `next.config.js`

**Deployment:**
- Fumadocs is integrated into the same Next.js codebase as the landing page (one project, one deploy)
- Docs live under the `/docs` route within the Next.js app
- Single Vercel deployment serves both landing page and docs at `echo.vjh.io`

---

## Pre-Reading Requirements

Before writing ANY documentation, the agent MUST read these files in order:

1. **This plan** — Structure, pages, writing guidelines
2. **`/CLAUDE.md`** — Full app architecture, features, services, and terminology
3. **`docs/plans/2026-02-16-documentation-tool-research.md`** — AI doc generation techniques, writing style guidelines, verification steps
4. **Key source files** (listed per page below) — To understand each feature's actual implementation

---

## Information Architecture

The docs use a shallow nested hierarchy (max 2 levels deep) organized by user tasks, not internal architecture. Navigation: left sidebar + Cmd+K search.

```
docs/
├── getting-started/
│   ├── index.mdx              — Welcome + what Echo does
│   ├── installation.mdx       — Download, install, system requirements
│   ├── permissions.mdx        — macOS permissions (Accessibility, Microphone, Screen Recording)
│   └── quickstart.mdx         — First transcription in 60 seconds
│
├── transcription/
│   ├── index.mdx              — How transcription works (overview)
│   ├── local-models.mdx       — Whisper & Parakeet: downloading, selecting, performance
│   ├── cloud-services.mdx     — Deepgram, Groq, ElevenLabs, Gemini, Mistral, Soniox setup
│   ├── apple-speech.mdx       — Native Apple transcription
│   ├── language-selection.mdx — Choosing transcription language
│   └── audio-file.mdx         — Transcribing audio/video files (drag & drop)
│
├── ai-enhancement/
│   ├── index.mdx              — What AI Enhancement does
│   ├── setup.mdx              — API keys (OpenAI, Anthropic, Ollama)
│   ├── prompts.mdx            — Using and creating custom prompts
│   ├── screen-context.mdx     — Screen capture for context-aware enhancement
│   └── selected-text.mdx      — Using selected text as context
│
├── adaptive-awareness/
│   ├── index.mdx              — What Adaptive Awareness is and why it matters
│   ├── profiles.mdx           — Creating and managing profiles
│   ├── triggers.mdx           — Voice triggers, URL patterns, app matching
│   └── advanced.mdx           — Auto-send, screen capture per profile, type-out mode
│
├── vocabulary/
│   ├── index.mdx              — Overview of vocabulary features
│   ├── smart-corrections.mdx  — Word replacement rules
│   ├── personal-vocabulary.mdx — Custom words and terminology
│   └── filler-words.mdx       — Filler word removal
│
├── settings/
│   ├── index.mdx              — Settings overview
│   ├── recording.mdx          — Audio input, device selection, media pause, mute
│   ├── output.mdx             — Type-out mode, auto-send, clipboard, paste behavior
│   ├── keyboard-shortcuts.mdx — Global hotkeys and enhancement shortcuts
│   ├── appearance.mdx         — Recorder style (mini/notch), sounds, notifications
│   └── general.mdx            — Launch at login, auto-updates, diagnostics
│
├── history/
│   ├── index.mdx              — Transcription history and search
│   └── auto-cleanup.mdx       — Auto-cleanup settings and data management
│
├── dashboard/
│   └── index.mdx              — Metrics, speed comparison, usage statistics
│
├── integrations/
│   ├── index.mdx              — Overview of integrations
│   ├── siri-shortcuts.mdx     — App Intents / Siri Shortcuts
│   └── custom-models.mdx      — Adding custom cloud transcription models
│
├── troubleshooting/
│   ├── index.mdx              — Common issues and solutions
│   ├── permissions.mdx        — Permission troubleshooting
│   ├── audio-issues.mdx       — Microphone not detected, poor quality
│   └── transcription-quality.mdx — Improving accuracy, model selection tips
│
└── privacy/
    └── index.mdx              — Privacy, data handling, what stays local
```

**Total: ~35 pages**

---

## Source Files to Read Per Documentation Page

The agent must read the relevant source files to write accurate documentation. Here's the mapping:

### Getting Started
| Page | Source Files |
|------|-------------|
| installation | `VoiceInk.swift`, `VoiceInk.entitlements` |
| permissions | `Views/PermissionsView.swift`, `Views/Onboarding/OnboardingPermissionsView.swift` |
| quickstart | `Views/Onboarding/OnboardingTutorialView.swift`, `Whisper/WhisperState.swift` |

### Transcription
| Page | Source Files |
|------|-------------|
| local-models | `Services/LocalTranscriptionService.swift`, `Services/ParakeetTranscriptionService.swift`, `Models/PredefinedModels.swift`, `Views/AI Models/ModelManagementView.swift` |
| cloud-services | `Services/CloudTranscription/CloudTranscriptionService.swift`, `Services/CloudTranscription/DeepgramTranscriptionService.swift`, `Services/CloudTranscription/GroqTranscriptionService.swift`, `Services/CloudTranscription/ElevenLabsTranscriptionService.swift`, `Services/CloudTranscription/GeminiTranscriptionService.swift`, `Services/CloudTranscription/MistralTranscriptionService.swift`, `Services/CloudTranscription/SonioxTranscriptionService.swift`, `Views/AI Models/APIKeyManagementView.swift` |
| apple-speech | `Services/NativeAppleTranscriptionService.swift` |
| language-selection | `Views/AI Models/LanguageSelectionView.swift` |
| audio-file | `Services/AudioFileTranscriptionService.swift`, `Services/AudioFileTranscriptionManager.swift`, `Views/AudioTranscribeView.swift` |

### AI Enhancement
| Page | Source Files |
|------|-------------|
| setup | `Services/AIService.swift`, `Services/APIKeyManager.swift`, `Services/OllamaService.swift` |
| prompts | `Models/PredefinedPrompts.swift`, `Views/PromptEditorView.swift`, `Views/Components/PromptSelectionGrid.swift` |
| screen-context | `Services/ScreenCaptureService.swift` |
| selected-text | `Services/SelectedTextService.swift` |

### Adaptive Awareness
| Page | Source Files |
|------|-------------|
| profiles | `PowerMode/PowerModeConfig.swift`, `PowerMode/PowerModeDefaults.swift`, `Views/AdaptiveAwareness/ProfileListView.swift`, `Views/AdaptiveAwareness/ProfileDetailView.swift` |
| triggers | `PowerMode/ActiveWindowService.swift`, `PowerMode/BrowserURLService.swift`, `Views/AdaptiveAwareness/ActivationTriggersSection.swift`, `Views/AdaptiveAwareness/URLPatternInput.swift`, `Views/AdaptiveAwareness/VoiceKeywordInput.swift`, `PowerMode/AppPicker.swift` |
| advanced | `Views/AdaptiveAwareness/AdvancedSection.swift`, `Views/AdaptiveAwareness/AIEnhancementSection.swift`, `PowerMode/PowerModeSessionManager.swift` |

### Vocabulary
| Page | Source Files |
|------|-------------|
| smart-corrections | `Services/WordReplacementService.swift`, `Views/Dictionary/WordReplacementView.swift` |
| personal-vocabulary | `Services/CustomVocabularyService.swift`, `Services/DictionaryContextService.swift`, `Views/Dictionary/DictionaryView.swift` |
| filler-words | `Services/FillerWordManager.swift`, `Views/Components/FillerWordsSettingsView.swift` |

### Settings
| Page | Source Files |
|------|-------------|
| recording | `Views/Settings/AudioInputSettingsView.swift`, `Views/Settings/RecordingSettingsView.swift`, `Services/AudioDeviceManager.swift` |
| output | `Views/Settings/TranscriptionSettingsView.swift`, `Services/TranscriptionOutputFilter.swift`, `Services/PasteEligibilityService.swift` |
| keyboard-shortcuts | `Views/KeyboardShortcutView.swift`, `HotkeyManager.swift`, `Views/Settings/EnhancementShortcutsView.swift` |
| appearance | `Views/Settings/CustomSoundSettingsView.swift`, `Views/Recorder/MiniWindowManager.swift`, `Views/Recorder/NotchWindowManager.swift` |
| general | `Views/Settings/GeneralSettingsView.swift`, `Views/Settings/DiagnosticsSettingsView.swift` |

### History & Dashboard
| Page | Source Files |
|------|-------------|
| history | `Views/TranscriptionHistoryView.swift`, `Views/TranscriptionCard.swift`, `Services/TranscriptionAutoCleanupService.swift` |
| dashboard | `Views/MetricsView.swift`, `Views/Metrics/MetricsContent.swift`, `Views/Metrics/TimeEfficiencyView.swift`, `Views/Metrics/PerformanceAnalysisView.swift` |

### Integrations
| Page | Source Files |
|------|-------------|
| siri-shortcuts | `AppIntents/` directory |
| custom-models | `Services/CloudTranscription/CustomModelManager.swift`, `Views/AI Models/AddCustomModelView.swift` |

---

## Writing Guidelines

### Voice and Tone
- Friendly, clear, non-technical
- Lead with what the user can DO, not how the code works
- Use the exact UI labels from the app (button names, menu items, setting labels)
- Second person ("you") throughout

### Structure Per Page
Each documentation page should follow this template:

```mdx
---
title: [Feature Name]
description: [One sentence explaining what this page covers]
---

# [Feature Name]

[1-2 sentence overview: what it is and why you'd use it]

## [Main Task / How to Use It]

[Numbered steps with exact UI labels]

1. Open Echo and go to **[exact menu/tab name]**
2. Click **[exact button label]**
3. ...

## [Configuration / Options] (if applicable)

[Describe available settings, what each does]

## Tips

[2-3 practical tips or shortcuts]

## Related

- [Link to related page]
- [Link to related page]
```

### Key Principles
- **One canonical page per feature** — don't duplicate content across pages, cross-link instead
- **Screenshots:** Insert placeholder comments (`{/* Screenshot: [description of what to capture] */}`) where screenshots should go. Vince will add these later.
- **Terminology:** Use "Adaptive Awareness" (not "PowerMode"), "Echo" (not "VoiceInk" or "Embr Voice")
- **macOS conventions:** Use proper macOS terminology (e.g., "menu bar", not "system tray")
- **Scannable:** Use headings, numbered steps, bullet points. No walls of text.

---

## Agent Execution Plan

### Phase 1: Project Setup
1. Create a new Fumadocs project (separate from the landing page)
2. Configure `basePath: '/docs'` in `next.config.js`
3. Set up the sidebar navigation matching the information architecture above
4. Configure dark/light mode to match Echo's warm palette (peach/coral/rose accent colors)
5. Verify the project builds and runs locally

### Phase 2: Core Documentation (Getting Started)
6. Read the source files listed for Getting Started pages
7. Write: `getting-started/index.mdx`
8. Write: `getting-started/installation.mdx`
9. Write: `getting-started/permissions.mdx`
10. Write: `getting-started/quickstart.mdx`

### Phase 3: Feature Documentation
11. Read source files for Transcription section → write all 6 pages
12. Read source files for AI Enhancement section → write all 5 pages
13. Read source files for Adaptive Awareness section → write all 4 pages
14. Read source files for Vocabulary section → write all 4 pages

### Phase 4: Settings & Supporting Pages
15. Read source files for Settings section → write all 6 pages
16. Write History pages (2 pages)
17. Write Dashboard page (1 page)
18. Write Integrations pages (3 pages)

### Phase 5: Troubleshooting & Privacy
19. Write Troubleshooting pages (4 pages) — synthesize from common patterns across all source files
20. Write Privacy page — based on entitlements, data storage locations, and what stays local

### Phase 6: Polish & Cross-linking
21. Add cross-links between related pages (e.g., settings pages link to feature pages)
22. Verify all sidebar navigation works
23. Verify search indexes correctly
24. Final build check — no broken links, no build errors

---

## Verification Checklist

After documentation is generated, verify:

- [ ] Every page follows the writing template
- [ ] All UI labels match the actual app (check against View source files)
- [ ] No internal code names leak through (no "PowerMode", "WhisperState", "VoiceInk")
- [ ] Cross-links between related pages work
- [ ] Screenshot placeholders are present for key UI elements
- [ ] Dark/light mode works on the docs site
- [ ] Search returns relevant results
- [ ] Sidebar navigation matches the information architecture
- [ ] `basePath: '/docs'` is configured correctly
- [ ] Build succeeds with no errors

---

## Files Referenced

- **App architecture:** `/CLAUDE.md`
- **Doc tool research:** `docs/plans/2026-02-16-documentation-tool-research.md`
- **Landing page design:** `docs/plans/2026-02-15-echo-landing-page-design.md`
