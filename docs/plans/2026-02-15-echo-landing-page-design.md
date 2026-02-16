# Echo Landing Page — Design Document

## Overview

A single-page marketing site for Echo, a free macOS voice-to-text application. The page has one job: get visitors to download the app. Everything on the page supports that goal.

**Product:** Echo — free, native macOS voice-to-text app
**Distribution:** Direct download (DMG)
**Tech stack:** Next.js / React
**Design direction:** Clean & minimal, Apple-style — whitespace-driven, restrained palette, typography-focused

---

## Page Structure

### 1. Hero

The entire above-the-fold experience. No navigation bar competing for attention — just the core message and the action.

**Elements:**
- **Headline:** A single bold statement that lands the value proposition. Something in the territory of *"The most powerful voice tool for Mac"* or *"Everything you need to turn voice into text."* Final copy TBD.
- **Subheadline:** One sentence that unpacks what "all-in-one" means — local AI models, cloud services, AI enhancement, and context-aware profiles, all in one app.
- **Download button:** Primary CTA. Prominent, high-contrast. Links to the DMG. Label: "Download for Mac" or "Download Free for Mac."
- **Hero image:** Dashboard screenshot (`Lightmode-dashboard.png` or `Darkmode-dashboard.png`). The "4.5x faster" stat and usage metrics immediately communicate a mature, data-driven product. Consider showing the light mode version against the warm gradient background for maximum contrast, or offering a dark/light toggle interaction.

**Notes:**
- No navigation links above the fold. If nav is needed at all, it should be minimal and unobtrusive (perhaps a subtle floating header that appears on scroll).
- The hero should communicate: what it is, why it matters, and how to get it — in under 5 seconds.

---

### 2. Four Pillars

Four cards or columns, each with an icon and a short description. These are Echo's core capabilities, presented as scannable highlights.

| Pillar | Headline | Description |
|--------|----------|-------------|
| **Local AI** | Transcribe offline | On-device models (Whisper, Parakeet). Your voice never leaves your Mac. No internet required. |
| **Cloud Power** | Maximum accuracy | Connect to Deepgram, Groq, ElevenLabs, or other cloud services when you need the best results. |
| **AI Enhancement** | Smart formatting | Automatically clean up, format, and transform transcriptions with custom AI prompts. |
| **Adaptive Awareness** | Context that adapts | Profiles that auto-activate based on the app you're using, the URL you're visiting, or a voice trigger. |

**Design:** Equal-width cards in a horizontal row (stacking vertically on mobile). Each card has an icon (simple line or glyph), a short headline, and 1-2 sentences. No paragraphs.

---

### 3. How It Works

A 3-step visual flow that grounds the product in a real workflow.

1. **Press your hotkey** — Start recording from anywhere on your Mac with a global keyboard shortcut.
2. **Speak naturally** — Echo transcribes using your chosen engine — local or cloud.
3. **Text appears** — Automatically pasted at your cursor, copied to clipboard, or enhanced by AI.

**Design:** Horizontal step indicators with icons or illustrations. Numbered steps. Clean, minimal connecting lines or arrows between them.

---

### 4. Feature Showcase

A deeper dive into each pillar. Alternating left-right layout — text on one side, screenshot/mockup on the other.

**Local AI section:**
- Emphasis on privacy: everything stays on your Mac
- Multiple model options (different sizes for different hardware)
- Works without internet

**Cloud section:**
- Multiple providers supported
- Choose based on language, accuracy, or speed
- API keys stay local

**AI Enhancement section:**
- Custom prompts for different use cases
- Format emails, clean up meeting notes, extract action items
- Works with any transcription source

**Adaptive Awareness section:**
- Visual showing how profiles switch automatically
- Example: writing mode in VS Code, email mode in Mail, casual in Messages
- Voice triggers, URL matching, app detection
- **Screenshot:** `lightmode-Adaptive-awareness.png` / `Darkmode-Adaptive-awareness.png` — the profile detail view with activation triggers is the clearest visual for this feature

**Vocabulary / Smart Corrections section (optional extra):**
- Custom word replacements and personal vocabulary
- Teach Echo your terminology
- **Screenshot:** `lightmode-vocab.png` / `Darkmode-vocab.png`

**Advanced Settings section (optional extra):**
- Type-Out Mode, Auto-Send, media pause, clipboard control
- Fine-grained control over how transcriptions are delivered
- **Screenshot:** `Advanced Settings lightmode.png` / `Advanced Settings.png`

**Design:** Each block has generous whitespace. Screenshots sit in subtle device frames or drop shadows. Text is short — a headline, 2-3 bullet points or a short paragraph, and optionally a small detail link. All screenshots are available in both dark and light mode — consider showing one mode consistently, or using a toggle/hover effect to reveal the alternate theme.

---

### 5. Testimonials / Social Proof

User quotes, review scores, or usage statistics.

**Possible elements:**
- Pull quotes from users (with name/avatar if available)
- App rating if published on any review platform
- Usage stats (e.g., "X transcriptions processed" or "Used by Y people") if meaningful numbers exist
- Press mentions or notable user endorsements

**Design:** A light background section to visually break from the feature showcase. Centered quotes with attribution. If multiple testimonials, a simple horizontal scroll or 2-3 static cards.

**Note:** This section needs real content. Placeholder structure should be built, with clear slots for quotes, names, and avatars that can be populated later.

---

### 6. Comparison Table

Echo vs. Wispr Flow vs. [TBD second competitor].

**Comparison dimensions (suggested):**

| Feature | Echo | Wispr Flow | Competitor 2 |
|---------|------|------------|---------------|
| Price | Free | Paid subscription | TBD |
| Offline transcription | Yes | TBD | TBD |
| Multiple AI models | Yes | TBD | TBD |
| Cloud providers | Multiple | TBD | TBD |
| AI enhancement/formatting | Yes | TBD | TBD |
| Context-aware profiles | Yes | TBD | TBD |
| Open/local processing | Yes | TBD | TBD |

**Note:** Competitor details need research before finalizing. The comparison should be factual — no straw-manning. If a competitor does something well, acknowledge it. Credibility matters more than making Echo look perfect in every row.

**Design:** Clean table with checkmarks/crosses or feature descriptions. Echo's column is subtly highlighted. Mobile-friendly (horizontally scrollable or restructured as stacked cards).

---

### 7. Download CTA (Repeated)

A second, prominent call-to-action near the bottom of the page.

**Elements:**
- Short reinforcement line: *"Free. Offline. No account required."* or similar.
- Download button (same style as hero).
- Optional: system requirements note (macOS version).

**Design:** Full-width section with centered content. Slightly different background shade to distinguish from surrounding sections.

---

### 8. Footer

Minimal.

**Elements:**
- Links: GitHub/source (if applicable), support/contact, changelog, privacy policy
- Attribution: "Made by Vincent Hopf" or similar
- Copyright

**Design:** Dark or muted footer. Small text. No unnecessary links.

---

## Design Specifications

### Visual Direction

- **Style:** Apple-inspired. Clean, spacious, typography-driven.
- **Whitespace:** Generous. Sections breathe. Nothing feels cramped.
- **Palette:** Drawn from the app's existing warm gradient — peach, coral, and rose tones visible in all screenshots. The gradient background from the screenshots (warm orange-pink-rose) can be used as a hero background or accent element. Neutral base (white/near-white) for content sections, with the warm accent color (the copper/brown tone used for toggles, icons, and sidebar highlights in the app) as the primary action color.
- **Typography:** A clean sans-serif. System font stack or a web font like Inter, SF Pro (if licensing allows), or similar. Large headlines, readable body text.
- **Imagery:** App screenshots in device frames. Simple icons for the pillars. No stock photos.

### Responsive Behavior

- **Desktop:** Full layout as described — horizontal card grids, alternating image/text blocks.
- **Tablet:** Cards stack to 2-column grids, feature showcase maintains alternating layout.
- **Mobile:** Single column throughout. Cards stack vertically. Comparison table becomes scrollable or restructured.

### Theme Support

The site supports both dark and light modes, matching the app's own dual-theme UI. An animated theme toggler (Magic UI `animated-theme-toggler`) lets visitors switch modes. All screenshots swap to their corresponding dark/light version when the theme changes. Default theme follows system preference.

### Magic UI Components

Component library: [Magic UI](https://magicui.design). Installed via shadcn CLI (`npx shadcn@latest add "https://magicui.design/r/<component>.json"`).

**Hero:**
| Component | Purpose |
|-----------|---------|
| `blur-fade` | Staggered entrance animation for headline, subheadline, and CTA |
| `text-animate` (blurInUp) | Word-by-word reveal on the headline |
| `shimmer-button` | Download CTA with warm copper/peach shimmer traveling the perimeter |
| `safari` | Frame dashboard screenshot in a Safari browser mockup |
| `border-beam` | Subtle animated light beam on the Safari frame edge |

**Four Pillars:**
| Component | Purpose |
|-----------|---------|
| `magic-card` | Spotlight hover effect following cursor on each card (gradient: warm palette) |
| `blur-fade` | Staggered entrance as section scrolls into view |

**How It Works:**
| Component | Purpose |
|-----------|---------|
| `animated-beam` | Light beams connecting the three steps (hotkey → speak → text) |
| `blur-fade` | Staggered entrance for each step |

**Feature Showcase:**
| Component | Purpose |
|-----------|---------|
| `safari` | Frame all app screenshots in Safari mockup |
| `blur-fade` | Fade in as each section enters viewport |
| `lens` | Optional interactive zoom on screenshots for inspecting UI detail |

**Testimonials:**
| Component | Purpose |
|-----------|---------|
| `marquee` | Auto-scrolling horizontal testimonial cards |

**Comparison Table:**
| Component | Purpose |
|-----------|---------|
| `magic-card` | Hover highlight on Echo column |
| `number-ticker` | Animate numeric stats (price: "$0", features count, etc.) |

**Download CTA (bottom):**
| Component | Purpose |
|-----------|---------|
| `shimmer-button` | Same as hero for consistency |
| `confetti` | Burst on click when someone hits download |

**Global / Page-wide:**
| Component | Purpose |
|-----------|---------|
| `scroll-progress` | Thin progress bar at top of page |
| `animated-theme-toggler` | Dark/light mode toggle (swaps all screenshots) |
| `dot-pattern` | Very subtle background texture in content sections |
| `particles` | Optional faint warm-colored particles in hero background |

**Deliberately excluded** (too loud for Apple-style minimal): `warp-background`, `meteors`, `retro-grid`, `neon-gradient-card`, `rainbow-button`, `flickering-grid`.

### Animations

- All section entrances use `blur-fade` for consistent, subtle scroll-triggered reveals
- No autoplay video, no heavy animations
- Download button shimmer is the most prominent motion element
- Confetti on download click is a one-time delight moment
- `animated-beam` in How It Works is the only continuous animation in a content section
- Keep it fast — performance over polish

---

## Technical Notes

### Next.js Setup

- Static export (`output: 'export'`) since this is a single marketing page with no dynamic content
- Tailwind CSS for styling (aligns with clean/minimal direction, fast to iterate)
- Component structure: one page, section components for each block
- Image optimization via Next.js `<Image>` component
- Hosting: Vercel (natural fit for Next.js) or any static host

### Available Assets (`webassets/`)

Screenshots ready to use (all in dark + light mode pairs):

| Asset | Dark | Light | Suggested Use |
|-------|------|-------|---------------|
| Dashboard | `Darkmode-dashboard.png` | `Lightmode-dashboard.png` | Hero image, social proof (4.5x faster stat) |
| Adaptive Awareness | `Darkmode-Adaptive-awareness.png` | `lightmode-Adaptive-awareness.png` | Feature showcase — Adaptive Awareness section |
| Vocabulary | `Darkmode-vocab.png` | `lightmode-vocab.png` | Feature showcase — Smart Corrections section |
| Advanced Settings | `Advanced Settings.png` | `Advanced Settings lightmode.png` | Feature showcase — Advanced Settings section |

### Still Needed

- [ ] App icon (high-res, for hero and favicon)
- [ ] Testimonial quotes + attribution
- [ ] Competitor research for comparison table
- [ ] Download link (DMG URL)
- [ ] Demo video (optional, can add later)

---

## Open Questions

1. **Domain:** What domain will this live on?
2. **Analytics:** Do you want analytics (e.g., Plausible, Simple Analytics) to track downloads?
3. **SEO:** Any target keywords beyond the obvious (voice to text mac, dictation app mac)?
4. **Legal:** Privacy policy / terms needed at launch?
5. **Second competitor:** Need to research and decide who to compare against alongside Wispr Flow.

---

## Copywriting Reference

**IMPORTANT:** Before writing any copy for this landing page, the implementing agent MUST read the full copy research document:

→ **`docs/plans/2026-02-16-landing-page-copy-research.md`**

This document contains researched copywriting tactics, headline formulas, CTA microcopy patterns, and real examples from top Mac app landing pages (Arc, Raycast, Linear, CleanShot X, Superhuman, etc.). It covers:

1. **Headline formulas** that drive downloads (not signups)
2. **Copy structure patterns** from the best Mac app landing pages
3. **Benefit-driven vs feature-driven** copy and when to use each
4. **CTA microcopy** that converts — button labels, trust signals, friction reducers
5. **Ethical comparison copy** — how to position against competitors without being negative

All copy written for this landing page — headlines, subheadlines, feature descriptions, CTA labels, comparison section — should be grounded in the tactics and frameworks from that research. Do not guess at copy; use the research.

---

## Implementation Notes for Agents

When implementing this landing page, read these documents in order:

1. **This file** (`2026-02-15-echo-landing-page-design.md`) — Page structure, components, design specs
2. **Copy research** (`2026-02-16-landing-page-copy-research.md`) — Copywriting tactics and frameworks
3. **Project CLAUDE.md** (`/CLAUDE.md`) — Architecture context for Echo's features and terminology

The copy research is the source of truth for how to write landing page text. The design doc is the source of truth for layout, components, and visual direction. Read both fully before writing any code or copy.

---

## Summary

A focused, clean landing page with one goal: download Echo. Eight sections, each serving that goal. Apple-style design, Next.js + Tailwind, static export. Content-first — the design is the vehicle, not the destination.
