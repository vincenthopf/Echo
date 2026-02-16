# Documentation Agent Prompt

Copy everything below the line and give it to the agent.

---

## Task

You are building comprehensive user-facing documentation for **Echo**, a macOS voice-to-text app. The documentation will be built with **Fumadocs** integrated into the same Next.js codebase as the landing page, served at `echo.vjh.io/docs`.

## Critical: Read These Files First

Before writing ANY code or documentation, read these files in this exact order:

1. `docs/plans/2026-02-16-documentation-plan.md` — The complete documentation plan with page structure, source file mappings, and writing guidelines
2. `docs/plans/2026-02-16-documentation-tool-research.md` — Research on doc tools, AI doc generation techniques, writing style for non-technical users
3. `CLAUDE.md` — Full app architecture, features, services, and terminology

These are your source of truth. Do not deviate from them.

## Project Structure

The landing page Next.js project lives at `website/` (or will be created there). Fumadocs is integrated into this project — one codebase, one deploy. The structure should be:

```
website/
├── app/
│   ├── layout.tsx              — Root layout with RootProvider from fumadocs-ui
│   ├── page.tsx                — Landing page (home)
│   ├── docs/
│   │   ├── layout.tsx          — DocsLayout with sidebar tree
│   │   └── [[...slug]]/
│   │       └── page.tsx        — Dynamic docs page renderer
│   └── ...                     — Other landing page routes
├── content/
│   └── docs/                   — All MDX documentation files live here
│       ├── getting-started/
│       │   ├── index.mdx
│       │   ├── installation.mdx
│       │   ├── permissions.mdx
│       │   ├── quickstart.mdx
│       │   └── meta.json       — Sidebar ordering
│       ├── transcription/
│       │   ├── index.mdx
│       │   ├── local-models.mdx
│       │   ├── cloud-services.mdx
│       │   ├── apple-speech.mdx
│       │   ├── language-selection.mdx
│       │   ├── audio-file.mdx
│       │   └── meta.json
│       ├── ai-enhancement/
│       │   ├── index.mdx
│       │   ├── setup.mdx
│       │   ├── prompts.mdx
│       │   ├── screen-context.mdx
│       │   ├── selected-text.mdx
│       │   └── meta.json
│       ├── adaptive-awareness/
│       │   ├── index.mdx
│       │   ├── profiles.mdx
│       │   ├── triggers.mdx
│       │   ├── advanced.mdx
│       │   └── meta.json
│       ├── vocabulary/
│       │   ├── index.mdx
│       │   ├── smart-corrections.mdx
│       │   ├── personal-vocabulary.mdx
│       │   ├── filler-words.mdx
│       │   └── meta.json
│       ├── settings/
│       │   ├── index.mdx
│       │   ├── recording.mdx
│       │   ├── output.mdx
│       │   ├── keyboard-shortcuts.mdx
│       │   ├── appearance.mdx
│       │   ├── general.mdx
│       │   └── meta.json
│       ├── history/
│       │   ├── index.mdx
│       │   ├── auto-cleanup.mdx
│       │   └── meta.json
│       ├── dashboard/
│       │   ├── index.mdx
│       │   └── meta.json
│       ├── integrations/
│       │   ├── index.mdx
│       │   ├── siri-shortcuts.mdx
│       │   ├── custom-models.mdx
│       │   └── meta.json
│       ├── troubleshooting/
│       │   ├── index.mdx
│       │   ├── permissions.mdx
│       │   ├── audio-issues.mdx
│       │   ├── transcription-quality.mdx
│       │   └── meta.json
│       ├── privacy/
│       │   ├── index.mdx
│       │   └── meta.json
│       └── meta.json            — Top-level sidebar ordering
├── lib/
│   └── source.ts               — Fumadocs source loader
├── source.config.ts             — Fumadocs MDX config
├── next.config.mjs              — Next.js config with fumadocs-mdx plugin
├── tailwind.config.ts
├── package.json
└── tsconfig.json
```

## Execution Strategy: Use Subagents

You MUST use subagents to parallelize the documentation writing. Here's the approach:

### Phase 1: Setup (you do this directly)

1. **Create the Next.js + Fumadocs project** at `website/`
   - `npx create-fumadocs-app@latest` or manually set up
   - Install dependencies: `fumadocs-ui`, `fumadocs-core`, `fumadocs-mdx`
   - Configure `source.config.ts`:
     ```ts
     import { defineDocs, defineConfig } from 'fumadocs-mdx/config';
     export const docs = defineDocs({ dir: 'content/docs' });
     export default defineConfig();
     ```
   - Configure `lib/source.ts`:
     ```ts
     import { docs } from 'fumadocs-mdx:collections/server';
     import { loader } from 'fumadocs-core/source';
     export const source = loader({
       baseUrl: '/docs',
       source: docs.toFumadocsSource(),
     });
     ```
   - Configure `next.config.mjs` with `createMDX` wrapper
   - Set up `app/docs/layout.tsx` with `DocsLayout` and sidebar
   - Set up `app/docs/[[...slug]]/page.tsx` for dynamic rendering
   - Create all `meta.json` files for sidebar navigation ordering
   - Verify the project builds: `npm run dev`

2. **Create the top-level `meta.json`** for sidebar section ordering:
   ```json
   {
     "title": "Echo Documentation",
     "pages": [
       "getting-started",
       "transcription",
       "ai-enhancement",
       "adaptive-awareness",
       "vocabulary",
       "settings",
       "history",
       "dashboard",
       "integrations",
       "troubleshooting",
       "privacy"
     ]
   }
   ```

### Phase 2: Documentation Writing (use subagents in parallel)

Spawn **one subagent per documentation section**. Each subagent:
1. Reads the documentation plan (`docs/plans/2026-02-16-documentation-plan.md`) for writing guidelines and page template
2. Reads the specific Swift source files mapped to their section (listed in the plan under "Source Files to Read Per Documentation Page")
3. Writes all MDX files for their section
4. Writes the `meta.json` for sidebar ordering within their section

**Spawn these subagents in parallel:**

| Subagent | Section | Pages | Key Source Files to Read |
|----------|---------|-------|--------------------------|
| getting-started-docs | Getting Started | 4 pages | `VoiceInk.swift`, `Views/PermissionsView.swift`, `Views/Onboarding/*.swift`, `WhisperState.swift` |
| transcription-docs | Transcription | 6 pages | `Services/LocalTranscriptionService.swift`, `Services/ParakeetTranscriptionService.swift`, `Services/CloudTranscription/*.swift`, `Services/NativeAppleTranscriptionService.swift`, `Models/PredefinedModels.swift`, `Views/AI Models/*.swift` |
| ai-enhancement-docs | AI Enhancement | 5 pages | `Services/AIEnhancementService.swift`, `Services/AIService.swift`, `Services/APIKeyManager.swift`, `Models/PredefinedPrompts.swift`, `Services/ScreenCaptureService.swift`, `Services/SelectedTextService.swift`, `Views/PromptEditorView.swift` |
| adaptive-awareness-docs | Adaptive Awareness | 4 pages | `PowerMode/*.swift`, `Views/AdaptiveAwareness/*.swift` |
| vocabulary-docs | Vocabulary | 4 pages | `Services/WordReplacementService.swift`, `Services/CustomVocabularyService.swift`, `Services/DictionaryContextService.swift`, `Services/FillerWordManager.swift`, `Views/Dictionary/*.swift` |
| settings-docs | Settings | 6 pages | `Views/Settings/*.swift`, `Services/AudioDeviceManager.swift`, `HotkeyManager.swift`, `Views/KeyboardShortcutView.swift`, `Views/Recorder/MiniWindowManager.swift`, `Views/Recorder/NotchWindowManager.swift` |
| history-dashboard-docs | History + Dashboard | 3 pages | `Views/TranscriptionHistoryView.swift`, `Services/TranscriptionAutoCleanupService.swift`, `Views/MetricsView.swift`, `Views/Metrics/*.swift` |
| integrations-docs | Integrations | 3 pages | `AppIntents/` directory, `Services/CloudTranscription/CustomModelManager.swift`, `Views/AI Models/AddCustomModelView.swift` |
| troubleshooting-docs | Troubleshooting + Privacy | 5 pages | All permission-related files, `VoiceInk.entitlements`, common error patterns across services |

**Each subagent prompt should include:**

```
You are writing user-facing documentation for Echo, a macOS voice-to-text app.

FIRST: Read these files:
1. docs/plans/2026-02-16-documentation-plan.md — for writing guidelines, page template, and your section's source file mapping
2. CLAUDE.md — for app architecture context

YOUR SECTION: [section name]
YOUR OUTPUT DIRECTORY: website/content/docs/[section]/

Read the Swift source files listed for your section in the documentation plan under "Source Files to Read Per Documentation Page". These are at VoiceInk/[path].

For each page, follow the writing template from the plan:
- Title and description in frontmatter
- 1-2 sentence overview
- Numbered steps with exact UI labels from the source code
- Tips section
- Related links to other doc pages
- Screenshot placeholders as comments: {/* Screenshot: [description] */}

TERMINOLOGY RULES:
- Use "Echo" (never "VoiceInk", "Embr Voice", or internal names)
- Use "Adaptive Awareness" (never "PowerMode")
- Use macOS terminology ("menu bar" not "system tray")
- Write for non-technical users — no code, no jargon

Write the meta.json for your section with proper page ordering.
Write ALL pages for your section. Do not skip any.
```

### Phase 3: Polish (you do this directly, after all subagents complete)

1. Verify all MDX files exist and follow the template
2. Add cross-links between related pages across sections
3. Run `npm run build` to verify no broken links or build errors
4. Verify sidebar navigation ordering is correct
5. Verify search works
6. Test dark/light mode

## Key Technical Details

### Fumadocs MDX Frontmatter
Each `.mdx` file needs:
```mdx
---
title: Page Title
description: One sentence description
---
```

### meta.json Format
Each section directory needs a `meta.json` for sidebar ordering:
```json
{
  "title": "Section Title",
  "pages": ["index", "page-one", "page-two"]
}
```

### Screenshot Placeholders
Since the agent can't take screenshots, insert placeholders:
```mdx
{/* Screenshot: The Adaptive Awareness profile list showing Default and Custom profiles */}
```

## Git Workflow

Before starting, ask about branching. Suggested branch name: `feature/documentation`.

## Success Criteria

- All 35 documentation pages written
- Every page follows the writing template
- No internal code names (PowerMode, WhisperState, VoiceInk)
- All UI labels match the actual app source code
- Cross-links between related pages
- Fumadocs project builds without errors
- Sidebar navigation works correctly
- Dark/light mode works
- Search indexes all pages
