# Adaptive Awareness Integration Plan

## Overview

This plan outlines the merger of two distinct features—Power Mode (context-aware automatic configurations) and Prompts with Trigger Words (voice-activated manual configurations)—into a single, unified "Adaptive Awareness" system. The goal is to eliminate user confusion, reduce feature duplication, and provide a cohesive, Apple HIG-compliant interface for managing intelligent transcription behaviors.

## Design Decisions

Based on user research and UX analysis, the following architectural decisions were made:

- **Mental Model**: Adaptive Awareness (scenario-based awareness profiles that align with existing "Adaptive Awareness" branding)
- **Trigger Flexibility**: All trigger types (apps, URLs, voice keywords) unified within each awareness profile
- **Implementation Strategy**: **Backend-stable, UI-first approach** (keep `PowerModeConfig` internally, only change user-facing labels)
- **Primary Pain Points Addressed**:
  - Duplicate concepts (Power Mode vs Prompts confusion)
  - Hidden relationships (can't see which profiles use which prompts)
  - Too many navigation points (scattered across multiple settings sections)
- **UI Pattern**: Master-detail layout with clean scannable list and comprehensive detail panel

### Summary: Backend-Stable Approach

**This is primarily a UX consolidation, not a backend refactor:**

✅ **Keep unchanged:**
- All class names: `PowerModeConfig`, `PowerModeManager`, `PowerModeSessionManager`, `ActiveWindowService`
- UserDefaults keys: `powerModeConfigurationsV2`
- Existing detection and state management logic
- All integration points with `WhisperState` and other services

✅ **Only change:**
- Add one property: `var triggerWords: [String] = []` to `PowerModeConfig`
- Create new UI views with "Adaptive Awareness" terminology
- Update settings labels to say "Adaptive Awareness"
- Extend existing services with voice trigger detection

✅ **Benefits:**
- Much lower implementation risk
- Faster development (focus on UI/UX)
- Easier testing and debugging
- Simple rollback if needed
- Backend refactor can happen later once UI is proven

## Current State Analysis

### Existing Architecture

**Power Mode System:**
- `PowerModeConfig`: Contains app/URL triggers, transcription settings, AI settings, selected prompt reference
- `PowerModeManager`: Singleton managing CRUD operations, stored in UserDefaults
- `ActiveWindowService`: Detects app switches and URL changes, applies matching configurations
- `PowerModeSessionManager`: Manages state transitions and restoration
- UI: `PowerModeView` (list), `PowerModeConfigView` (editor)

**Prompts System:**
- `CustomPrompt`: Contains prompt text, icon, description, trigger words, system instruction toggle
- `AIEnhancementService`: Manages custom prompts collection, stores in UserDefaults
- `PromptDetectionService`: Analyzes transcribed text for trigger words, strips them, activates prompts
- UI: `PromptEditorView`, `PromptSelectionGrid`, `EnhancementPromptPopover`

### Key Integration Points

Both systems interact with:
- `WhisperState`: Central orchestrator for transcription pipeline
- `AIEnhancementService`: Applies AI transformations using prompts
- `TranscriptionService` implementations: Model selection and language settings
- Settings UI: Multiple sections for configuration

### Current User Pain Points

1. **Conceptual Duplication**: Users don't understand why there are two separate features when Power Modes already reference prompts
2. **Hidden Dependencies**: No visibility into which Power Modes use which prompts; deleting prompts breaks configurations silently
3. **Fragmented Workflow**: Must navigate between "Power Mode" and "Prompts" sections to set up a complete scenario
4. **Unclear Priority**: Confusion when both automatic (app-based) and manual (voice) triggers could apply simultaneously

## Proposed Architecture

### Important: Backend-Stable Approach

This is primarily a **UI/UX consolidation**, not a backend refactor. To minimize risk and implementation complexity:

- **Keep all backend class names unchanged**: `PowerModeConfig`, `PowerModeManager`, `PowerModeSessionManager`, etc.
- **Only change user-facing elements**: UI strings, view names, settings labels
- **Minimal backend modifications**: Just extend existing classes with new functionality
- **Future refactor**: Backend naming can be aligned later if desired

### Data Model Extension (Not Renaming)

**PowerModeConfig (extend existing class):**

```swift
struct PowerModeConfig: Codable, Identifiable {
    // Existing properties (unchanged)
    let id: UUID
    var name: String
    var emoji: String
    var isEnabled: Bool
    var isDefault: Bool
    var appConfigs: [AppConfig]
    var urlConfigs: [URLConfig]
    var selectedTranscriptionModelName: String
    var selectedLanguage: String
    var isAIEnhancementEnabled: Bool
    var selectedPrompt: UUID?
    var selectedAIProvider: String
    var selectedAIModel: String
    var useScreenCapture: Bool
    var isAutoSendEnabled: Bool

    // NEW: Add voice trigger support
    var triggerWords: [String] = []       // Voice keywords (defaults to empty)
}
```

**CustomPrompt (remains separate, becomes shared library):**

- Keep existing structure completely unchanged
- Add computed properties for relationship tracking:
  - `usageCount: Int` - How many PowerModeConfigs reference this prompt
  - `usedByConfigs() -> [PowerModeConfig]` - Which configs use it
- Keep `triggerWords` property but deprecate standalone usage (migrate to PowerModeConfig)
- Keep `isPredefined` flag for built-in vs custom prompts

**Migration Strategy:**

1. Existing `PowerModeConfig` objects → Add empty `triggerWords: []` array (backward compatible)
2. Existing `CustomPrompt` objects with `triggerWords` → Create new `PowerModeConfig` instances with:
   - Only `triggerWords` populated from prompt (no app/URL triggers)
   - Prompt settings applied
   - Name derived from prompt title: "{promptTitle} (Voice)"
3. UserDefaults keys → **NO CHANGES** (keep `powerModeConfigurationsV2` for stability)
4. Mark standalone prompt trigger words as migrated to prevent duplication

### Extended Detection & Activation (Backend-Stable)

**Keep Existing Services, Extend Functionality:**

Instead of creating new services, extend the existing ones:

**ActiveWindowService (extend existing):**
- Keep all existing app/URL detection logic unchanged
- Add method: `detectVoiceTrigger(in text: String) -> (config: PowerModeConfig?, strippedText: String)`
- Coordinate with PromptDetectionService for voice trigger matching
- No class rename, no major refactoring

**PowerModeManager (extend existing):**
- Add voice trigger matching methods
- Keep all existing CRUD operations unchanged
- Add helper: `findConfigByTriggerWord(_ word: String) -> PowerModeConfig?`

**PowerModeSessionManager (keep unchanged):**
- Continue managing state transitions
- No modifications needed
- Already handles activation source tracking

**Activation Precedence:**

1. **Voice Triggers** (highest priority - manual override)
   - User spoke a trigger word during transcription
   - Locks profile until next voice command or manual change
   - Indicated as "Voice: 'keyword'"

2. **URL Patterns** (medium priority - specific context)
   - Current browser URL matches pattern
   - Auto-switches when URL changes
   - Indicated as "Auto: example.com"

3. **App Bundles** (lower priority - general context)
   - Frontmost app bundle ID matches
   - Auto-switches when app changes
   - Indicated as "Auto: App Name"

4. **Default Profile** (fallback)
   - Profile marked as `isDefault: true`
   - Applied when no other triggers match

**Conflict Resolution:**

- If user speaks voice trigger while automatic profile is active → Switch to voice-activated profile immediately
- Voice-activated profiles persist across app switches until explicitly changed
- Multiple app/URL matches → First enabled profile in user's ordered list wins
- Empty trigger arrays → Profile can only be activated manually from settings

**Integration with Existing Components:**

- `WhisperState.toggleRecord()` → After transcription, call `ActiveWindowService.detectVoiceTrigger(in: text)`
- `WhisperState.transcriptionSettings` → Derived from `PowerModeManager.activeConfiguration`
- `AIEnhancementService` → References `activeConfig.selectedPrompt` for enhancement
- Menu bar manager → Displays active configuration name (shown to user as "awareness profile") and activation source

### UI Architecture Redesign

**Single Unified Settings Pane:**

Replace existing fragmented UI with `AdaptiveAwarenessView` using master-detail pattern:

**Left Panel - Profile List (Master):**
- Scrollable list of all profiles
- Each item shows:
  - Emoji + Name
  - Enable toggle (inline)
  - Trigger count badge: "5 triggers" (sum of apps + URLs + voice keywords)
  - Visual indicator: Filled circle (enabled), empty circle (disabled)
  - Active profile highlighted with accent color
- Search/filter bar at top
- "Add New Profile" button at bottom
- Drag-to-reorder for priority
- Context menu: Edit, Duplicate, Delete, Set as Default

**Right Panel - Profile Detail (Detail):**

Organized into collapsible sections:

1. **General**
   - Name text field
   - Emoji picker button
   - Enable toggle
   - "Set as Default" toggle

2. **Activation Triggers**
   - Subtitle: "This profile activates when:"
   - **Applications** subsection
     - Grid of selected app icons with names
     - "Add Application" picker button
     - Remove button on hover
   - **Websites** subsection
     - Tag-style list of URL patterns
     - Text field to add new pattern
     - Validation for URL format
   - **Voice Keywords** subsection
     - Tag-style list of trigger words
     - Text field to add new keyword
     - Duplicate prevention

3. **Transcription**
   - Model dropdown (with availability indicators)
   - Language dropdown (conditional based on model)
   - Preview of model capabilities

4. **AI Enhancement**
   - Enable toggle
   - Provider dropdown
   - Model dropdown (provider-specific)
   - **Prompt Selector** (enhanced):
     - Dropdown showing all available prompts
     - Each option shows: Icon + Title + Usage count ("Used in 3 profiles")
     - Preview of selected prompt text (first 100 chars)
     - "Edit Prompt" button → Opens `PromptEditorView` sheet
     - "Create New Prompt" option → Opens blank editor
   - Visual context (screen capture) toggle

5. **Advanced**
   - Auto-send toggle
   - Future settings can be added here

**Save/Cancel behavior:**
- Changes auto-save on field blur (macOS System Settings pattern)
- Validation errors shown inline with red text
- "Delete Profile" button (destructive action, red, requires confirmation)

**Navigation:**
- Settings window has single tab: "Adaptive Awareness"
- Removes: "Power Mode" section
- Removes: Standalone "Prompts" section from main settings
- Prompts managed inline within awareness profile editor

### Prompt Library Management

**Background Prompt Repository:**

`CustomPrompt` objects remain in separate collection managed by `AIEnhancementService`, but:

- Not exposed as separate settings section
- Accessed only through profile editor's prompt selector
- CRUD operations available via inline editors
- Shared across all profiles (library pattern)

**Enhanced Prompt Selector UI:**

When selecting a prompt in profile editor:

```
┌─────────────────────────────────────────────┐
│ Enhancement Prompt                          │
│ ┌─────────────────────────────────────────┐ │
│ │ 📧 Professional Email  (Used in 3)    ▾ │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Preview:                                    │
│ "Transform casual speech into polished,    │
│  professional email format with proper..." │
│                                             │
│ [Edit Prompt...] [Create New...]           │
└─────────────────────────────────────────────┘
```

**Dropdown options:**
- Lists all prompts (predefined + custom)
- Shows usage count: "(Used in N)" for each
- Grouped: "Predefined" and "Custom"
- Search/filter for large lists

**Relationship Visibility:**

When editing a prompt via inline editor:
- Show header: "Editing: Professional Email"
- Show usage indicator: "⚠️ Used by 3 profiles: Email Writer, Meeting Notes, Chat Mode"
- Deletion protection: "Cannot delete - used by profiles. Remove from profiles first."
- Changes propagate to all profiles using this prompt

**Orphaned Prompt Cleanup:**

- Prompts not referenced by any profile show: "(Not in use)"
- "Clean Up" action in prompt library removes unused custom prompts
- Predefined prompts always remain available

## Implementation Stages

### Stage 1: Data Model Extension (Minimal Backend Changes)

**Objectives:**
- Extend existing `PowerModeConfig` with voice trigger support
- Implement migration from standalone prompts
- Maintain 100% backward compatibility

**Key Changes:**

1. **Extend PowerModeConfig (NO RENAMING):**
   - Add single property: `var triggerWords: [String] = []` with default empty array
   - Ensure backward compatibility (existing configs decode without error)
   - No other structural changes
   - Keep `PowerModeConfig.swift` filename and class name unchanged

2. **Extend PowerModeManager (NO RENAMING):**
   - Add method: `findByTriggerWord(_ word: String) -> PowerModeConfig?`
   - Add helper: `allTriggerWords() -> [String: PowerModeConfig]` for efficient lookup
   - Keep singleton name and all existing methods unchanged
   - No file rename

3. **Simple Migration Logic:**
   - Create `AdaptiveAwarenessMigration` utility (user-facing name, not class rename)
   - On first launch after update:
     - Load existing `PowerModeConfig` objects (auto-add empty `triggerWords`)
     - Find `CustomPrompt` objects with non-empty `triggerWords`
     - For each: Create new `PowerModeConfig` with only voice triggers, mark prompt as migrated
   - Set migration flag in UserDefaults: `"didMigrateToAdaptiveAwareness": true`
   - Preserve all user data, no data structure changes

**Integration Points:**
- `WhisperState`: No changes needed (uses `PowerModeManager`)
- `AIEnhancementService`: Add computed property for prompt usage tracking
- Settings views: Prepare new UI files (no changes to existing backend references)

**Testing Priorities:**
- Backward compatibility (old configs load without issue)
- Migration creates correct PowerModeConfigs from standalone prompts
- No UserDefaults key changes (stability)

### Stage 2: Extended Detection Logic (No New Services)

**Objectives:**
- Add voice trigger detection to existing services
- Implement clear precedence rules
- Track activation source (already supported)

**Key Changes:**

1. **Extend ActiveWindowService (NO NEW CLASS):**
   - Add method: `detectVoiceTrigger(in text: String) -> (config: PowerModeConfig?, strippedText: String)`
   - Use `PowerModeManager.findByTriggerWord()` to find matching config
   - Strip trigger word from text using existing `PromptDetectionService` logic
   - Keep all existing app/URL detection logic unchanged

2. **Reuse ActivationSource Enum (if exists, or add to PowerModeSessionManager):**
   ```swift
   enum ActivationSource {
       case voice(keyword: String)
       case url(pattern: String)
       case app(bundleID: String)
       case manual
       case defaultProfile
   }
   ```

3. **PowerModeSessionManager (NO RENAMING):**
   - Already tracks current active configuration
   - Already manages state transitions
   - Add property: `activationSource: ActivationSource?` if not present
   - Add method: `statusString() -> String` for UI display ("Auto: Gmail" or "Voice: 'email mode'")

**Integration Points:**
- `WhisperState.toggleRecord()`: After transcription, call `ActiveWindowService.detectVoiceTrigger()`
- `WhisperState.transcribeAudio()`: Continue using `PowerModeManager` unchanged
- Menu bar manager: Use `PowerModeSessionManager.statusString()` for display
- Mini recorder UI: Access active config from `PowerModeSessionManager`

**Testing Priorities:**
- Voice trigger detection works correctly
- Precedence rules respected (voice > URL > app > default)
- Text stripping accurate (trigger words removed)
- No regressions in existing app/URL detection

### Stage 3: New UI Layer (Frontend Only)

**Objectives:**
- Create unified settings interface using "Adaptive Awareness" terminology
- Implement master-detail pattern
- Replace fragmented UI sections
- **Work with existing `PowerModeConfig` backend (no backend changes)**

**New View Hierarchy:**

```
AdaptiveAwarenessView (Master-Detail Container)
  // Works with PowerModeManager.configurations
  // Displays them as "awareness profiles" to user
├── ProfileListView (Master - Left Panel)
│   ├── SearchBar
│   ├── ProfileListItem (foreach)
│   │   ├── Emoji + Name
│   │   ├── Enable Toggle
│   │   ├── Trigger Count Badge
│   │   └── Active Indicator
│   └── AddProfileButton
│
└── ProfileDetailView (Detail - Right Panel)
    ├── GeneralSection
    │   ├── NameTextField
    │   ├── EmojiPickerButton (reuse existing)
    │   ├── EnableToggle
    │   └── DefaultToggle
    │
    ├── ActivationTriggersSection
    │   ├── AppTriggerPicker
    │   │   ├── AppIconGrid (selected apps)
    │   │   └── AppPickerButton (NSWorkspace.runningApps)
    │   ├── URLTriggerInput
    │   │   ├── TagList (existing patterns)
    │   │   └── AddTextField with validation
    │   └── VoiceKeywordInput
    │       ├── TagList (existing keywords)
    │       └── AddTextField with duplicate check
    │
    ├── TranscriptionSection
    │   ├── ModelPicker (reuse existing)
    │   └── LanguagePicker (conditional)
    │
    ├── AIEnhancementSection
    │   ├── EnableToggle
    │   ├── ProviderPicker
    │   ├── ModelPicker
    │   ├── EnhancedPromptSelector
    │   │   ├── PromptDropdown (with usage counts)
    │   │   ├── PromptPreview
    │   │   ├── EditPromptButton → Sheet
    │   │   └── CreateNewPromptButton → Sheet
    │   └── ScreenCaptureToggle
    │
    ├── AdvancedSection
    │   └── AutoSendToggle
    │
    └── ActionBar
        ├── DeleteButton (destructive, with confirmation)
        └── SaveButton (or auto-save on change)
```

**Backend Integration:**
- All views work with `PowerModeConfig` objects from `PowerModeManager`
- Use `@ObservedObject var manager = PowerModeManager.shared`
- Edit operations call existing `PowerModeManager` CRUD methods
- No new backend models or managers needed
- User sees "Adaptive Awareness" labels, code uses `PowerModeConfig`

**Reusable Components:**
- `EmojiPickerView` (existing - unchanged)
- `PromptEditorView` (existing - launched from inline button)
- `TriggerWordsEditor` (existing - repurposed for voice keywords in PowerModeConfig)
- Model/language pickers (existing - integrated)

**Settings Window Integration:**
- Replace `PowerModeView` navigation link with `AdaptiveAwarenessView`
- Remove standalone prompts navigation link
- Update settings sidebar label: "Adaptive Awareness" (code still references PowerModeManager)
- Preserve other settings sections (AI Models, Dictionary, etc.)

**Testing Priorities:**
- Master-detail selection works correctly with PowerModeConfig objects
- All form controls update profile state
- Validation prevents invalid configurations
- Sheet presentations (prompt editor) work properly
- Responsive layout adapts to window resizing

### Stage 4: Prompt Integration & Relationships

**Objectives:**
- Enhance prompt selector with usage indicators
- Implement relationship tracking
- Add inline prompt editing

**Enhanced Prompt Features:**

1. **Usage Tracking:**
   - Computed property in `CustomPrompt`:
     ```swift
     var usageCount: Int {
         PowerModeManager.shared.configurations
             .filter { $0.selectedPrompt == self.id }
             .count
     }
     ```
   - Display in dropdown: "Professional Email (Used in 3)"

2. **Relationship Navigation:**
   - When editing prompt, show which profiles use it
   - Click profile name → Navigate to that profile
   - Prevent deletion if in use (or require confirmation with warning)

3. **Inline Prompt Editor:**
   - "Edit Prompt" button in profile detail opens sheet
   - Sheet contains full `PromptEditorView`
   - Changes save to shared library
   - All profiles using prompt get updates automatically

4. **Orphan Detection:**
   - Filter prompts with `usageCount == 0`
   - Show "(Not in use)" label in dropdown
   - Offer bulk cleanup action

**Integration Points:**
- `AIEnhancementService`: Add relationship query methods
- `PromptEditorView`: Add usage indicator header
- Profile detail view: Prompt selector with enhanced dropdown

**Testing Priorities:**
- Usage counts accurate and update in real-time
- Prompt edits propagate to all using profiles
- Deletion protection works correctly
- Orphan cleanup doesn't remove in-use prompts

### Stage 5: Status Indication & Feedback

**Objectives:**
- Show active profile throughout app
- Display activation source (auto vs voice)
- Provide clear visual feedback for state changes

**UI Enhancements:**

1. **Menu Bar Indicator:**
   - Show active profile icon + name
   - Subtitle shows source: "Auto: Gmail" or "Voice: 'email mode'"
   - Quick menu to manually switch profiles
   - Visual indicator when profile auto-switches

2. **Mini Recorder Window:**
   - Badge showing active profile emoji
   - Tooltip on hover: Profile name + activation source
   - Subtle highlight when profile switches during recording

3. **Notch Recorder:**
   - Compact profile indicator integrated into design
   - Respects minimal aesthetic

4. **Settings Window:**
   - Active profile highlighted in master list (accent color border)
   - "Currently Active" badge
   - Last activation timestamp shown

5. **State Change Animations:**
   - Smooth spring animation when profile switches
   - Toast notification (optional, user preference): "Switched to Email Writer"
   - Sound effect option for voice trigger activation

**Integration Points:**
- `MenuBarManager`: Update status item with active profile
- `MiniWindowManager` / `NotchWindowManager`: Add profile badge
- `AwarenessSessionManager`: Publish activation events for UI to observe

**Testing Priorities:**
- Status updates in real-time across all UI points
- Animations smooth and non-intrusive
- Performance impact minimal
- Dark mode support for all indicators

### Stage 6: Documentation & Migration UX

**Objectives:**
- Guide users through the transition
- Update all documentation
- Provide onboarding for new unified concept

**User-Facing Updates:**

1. **Migration Notice:**
   - On first launch after update, show sheet:
     - "Power Modes and Prompts are now unified in Adaptive Awareness"
     - Explain unified concept with visuals
     - "All your settings have been preserved"
     - "Learn More" button → Help documentation

2. **Onboarding Tooltips:**
   - First time opening Adaptive Awareness settings:
     - Tooltip pointing to master list: "Your scenarios live here"
     - Tooltip on triggers section: "Add any combination of triggers"
     - Tooltip on prompt selector: "Reusable enhancement instructions"

3. **In-App Help:**
   - Help button in settings → Opens documentation
   - Example profiles for common scenarios (email, coding, chat)
   - Video walkthrough or interactive tutorial

4. **Release Notes:**
   - Clear explanation of what changed
   - Benefits of unified system
   - Migration assurance (no data loss)

**Developer Documentation:**

1. **Update CLAUDE.md:**
   - Replace Power Mode architecture with Adaptive Awareness system
   - Document new unified detection system
   - Update UI structure descriptions
   - Note deprecated classes (keep for reference)

2. **Code Comments:**
   - Migration path documentation
   - Relationship between awareness profiles and prompts
   - Precedence rules clearly commented

3. **Deprecation Warnings:**
   - Mark old classes with `@available(*, deprecated, renamed: "AwarenessProfile")`
   - Keep old code for one version, then remove
   - Migration guide for any third-party extensions

**Testing Priorities:**
- Migration notice shows once and only once
- Tooltips dismissible and non-intrusive
- Help documentation accurate and complete
- No broken links or outdated screenshots

## Apple Human Interface Guidelines Compliance

### Layout & Organization

**Master-Detail Pattern:**
- Follows macOS guidelines for browsing and editing collections
- Clear visual separation between list and detail
- Selection state obvious with highlight
- Detail updates immediately on selection change

**Visual Hierarchy:**
- Section headers use system font styles (headline weight)
- Clear grouping with spacing and dividers
- Primary actions prominent (save, add)
- Destructive actions visually distinct (red delete)

**Spacing & Padding:**
- Use SwiftUI's standard spacing (`.padding()`, `.spacing()`)
- Consistent margins throughout (20pt standard)
- Comfortable touch targets for all interactive elements
- Generous whitespace prevents visual clutter

### Controls & Interactions

**Native Controls:**
- `Toggle` for boolean settings
- `Picker` with appropriate styles for selection
- `TextField` with validation and placeholder text
- `Button` with standard styles (bordered, plain, destructive)
- `List` with native selection behavior

**Keyboard Navigation:**
- Tab order logical and intuitive
- Enter/Return commits edits
- Escape cancels sheets and popovers
- Arrow keys navigate list items
- Cmd+N for new profile, Cmd+Delete for delete

**Mouse/Trackpad:**
- Single click to select in master list
- Double click to enter edit mode (alternative to selection)
- Right-click context menu for common actions
- Hover states for interactive elements

### Color & Typography

**System Colors:**
- `.accentColor` for active profile highlight
- `.red` for destructive delete button
- `.secondary` for dimmed/disabled states
- `.systemBackground` and `.systemFill` for surfaces
- Semantic colors adapt to light/dark mode automatically

**Typography:**
- System fonts throughout (SF Pro, SF Mono for code)
- Text styles: `.headline`, `.body`, `.caption`, `.footnote`
- Consistent font weights (regular for body, medium for emphasis)
- Dynamic Type support for accessibility

**Visual Feedback:**
- Disabled controls show reduced opacity (40%)
- Active/selected states use accent color
- Hover states show subtle background change
- Loading states show progress indicators

### Accessibility

**VoiceOver Support:**
- All controls have accessibility labels
- Hint text explains actions ("Activates profile when this app is frontmost")
- Groups logically related elements
- Announces state changes ("Email Writer profile activated")

**Keyboard Access:**
- All features accessible without mouse
- Focus indicators visible and clear
- Shortcuts for common actions
- Tab order follows visual layout

**Visual Accessibility:**
- Sufficient contrast ratios (WCAG AA minimum)
- Color not sole indicator of state (use shapes, text)
- Supports Increase Contrast mode
- Supports Reduce Motion (disable animations)
- Supports Reduce Transparency

**Text Size:**
- Dynamic Type support for all text
- Layout adapts to larger text sizes
- No fixed heights that break with scaling

## Testing Strategy

### Unit Tests

**Data Model:**
- `AwarenessProfile` encoding/decoding
- Migration from old models to new
- Validation logic (name required, no duplicate trigger words)
- Relationship tracking accuracy

**Detection Logic:**
- Voice trigger matching and text stripping
- URL pattern matching with wildcards
- Bundle ID matching
- Precedence rules (voice > URL > app > default)

**State Management:**
- Profile activation and deactivation
- Session restoration
- Undo/redo for edits

### Integration Tests

**Transcription Pipeline:**
- Voice trigger detection during actual transcription
- Profile settings correctly applied to transcription service
- AI enhancement uses correct prompt from active profile
- State restoration after transcription completes

**UI Workflows:**
- Creating new profile saves correctly
- Editing profile updates in UserDefaults
- Deleting profile removes from list and storage
- Prompt selector shows accurate usage counts

**Cross-Feature:**
- Switching apps triggers profile change
- URL changes in browser detected and matched
- Voice trigger overrides automatic detection
- Menu bar status reflects active profile

### UI Tests

**Master-Detail:**
- Selecting profile in list shows detail
- Editing detail updates list item
- Creating new profile adds to list
- Deleting profile removes from list

**Form Validation:**
- Empty name shows error
- Duplicate trigger words prevented
- Invalid URL patterns rejected
- Save button disabled when invalid

**State Persistence:**
- Profile edits saved and reloaded
- Window state preserved across launches
- Selection state maintained

### Manual Testing Scenarios

**Migration:**
1. Install old version with Power Modes and Prompts
2. Create several of each type
3. Update to new version
4. Verify all configs migrated correctly
5. Confirm no data loss

**User Workflows:**
1. Create profile for Gmail with app + URL + voice triggers
2. Switch to Gmail app → Verify auto-activation
3. Navigate to gmail.com in browser → Verify activation
4. Say "email mode" in other app → Verify voice override
5. Switch away → Verify profile deactivates or persists based on type

**Relationship Management:**
1. Create prompt used in multiple profiles
2. Edit prompt → Verify changes appear in all profiles
3. Try to delete used prompt → Verify warning shown
4. Remove prompt from all profiles → Verify deletion allowed

**Edge Cases:**
1. Voice trigger matches during automatic profile being active
2. Multiple URL patterns match current URL
3. Profile with empty triggers
4. Deleting active profile
5. Rapid app switching
6. Browser with no URL access permission

## Risk Mitigation

### Data Loss Prevention

**Migration Safety:**
- Backup old data before migration
- Validate migration success before deleting old data
- Fallback to old system if migration fails
- User can export/import profiles as JSON

**Save Conflicts:**
- Auto-save debounced to prevent excessive writes
- Conflict detection if multiple windows editing (unlikely but possible)
- UserDefaults atomic writes

### Performance Considerations

**Detection Overhead:**
- App switching detection uses existing NSWorkspace notifications (minimal cost)
- URL polling limited to browsers, 1-second interval (acceptable)
- Voice trigger regex matching optimized (sorted by length, early exit)

**UI Responsiveness:**
- Master list virtualized for 100+ profiles (unlikely but supported)
- Detail view lazy-loads sections
- Prompt dropdown lazy-loads prompt text
- Image assets (emoji, app icons) cached

**Memory Management:**
- Prompts loaded on-demand, not all in memory
- Profile list uses lightweight view models
- Dispose of editors when sheets closed

### Backward Compatibility

**Version Support:**
- Keep old data structures for one minor version
- Deprecated classes marked clearly
- Migration code runs only once, doesn't re-execute

**Rollback Plan:**
- If critical bugs found, can revert to old UI
- Old and new data models compatible
- Feature flag to enable/disable new UI

## Success Criteria

### User Experience

✅ **Discoverability:**
- New users find Adaptive Awareness without guidance
- Obvious where to create first profile
- Examples or templates help users get started

✅ **Clarity:**
- No confusion about concepts (one unified model)
- Relationship between profiles and prompts obvious
- Trigger precedence understandable

✅ **Efficiency:**
- Creating profile faster than old dual-system approach
- No need to navigate multiple sections
- Bulk operations available (duplicate, batch edit)

✅ **Reliability:**
- Profile activation consistent and predictable
- No lost configurations
- Settings persist correctly

### Technical Quality

✅ **Code Maintainability:**
- Clear separation of concerns
- Well-documented architecture
- Minimal duplication

✅ **Performance:**
- No perceptible lag in UI interactions
- Detection happens within 100ms of trigger event
- Memory usage stable over time

✅ **Test Coverage:**
- >80% unit test coverage for core logic
- All critical paths integration tested
- UI tests for main workflows

### Business Goals

✅ **Reduced Support Burden:**
- Fewer confused users asking "what's the difference?"
- Clear documentation reduces support tickets
- Onboarding reduces setup errors

✅ **Feature Adoption:**
- More users configure adaptive behaviors
- Average profiles per user increases
- Positive user feedback and reviews

✅ **Scalability:**
- Easy to add new trigger types (time-based, location, etc.)
- Easy to add new profile settings
- Architecture supports future enhancements

## Future Enhancements

### Post-Launch Considerations

**Additional Trigger Types:**
- Time-based: "Use this profile during work hours"
- Focused mode integration: "When in Do Not Disturb"
- Clipboard content: "When clipboard contains code"
- Selected text: "When transcribing into code editor"

**Smart Suggestions:**
- ML-based profile recommendations
- "You often use this prompt with Gmail - create a profile?"
- Auto-create profiles from usage patterns

**Sharing & Sync:**
- Export/import profiles as JSON or files
- iCloud sync across devices (future macOS + iOS app)
- Community profile marketplace

**Advanced Prompt Features:**
- Prompt variables: `{app}`, `{url}`, `{selected_text}`
- Conditional prompts based on context
- Chained prompts (multi-step enhancement)

**Profile Groups:**
- Organize profiles into folders or categories
- "Work" vs "Personal" groupings
- Quick-switch between profile sets

**Backend Refactoring (Post-Launch):**
- Rename `PowerModeConfig` → `AwarenessProfile` for internal consistency
- Rename `PowerModeManager` → `AwarenessProfileManager`
- Update UserDefaults keys if beneficial
- **Only after UI proven stable and user-tested**
- Low priority - purely internal naming alignment

## Conclusion

This plan unifies Power Mode and Prompts into a cohesive Adaptive Awareness system using a **backend-stable, UI-first approach**:

### Key Benefits:

1. **Eliminates conceptual duplication** - One unified "Adaptive Awareness" feature instead of two separate systems
2. **Surfaces hidden relationships** - Usage indicators and visual connections between profiles and prompts
3. **Simplifies navigation** - Single master-detail interface instead of scattered settings
4. **Provides flexible activation** - Apps, URLs, or voice keywords on same configuration
5. **Follows Apple HIG** - Native macOS patterns for familiarity and polish
6. **Scales for the future** - Extensible architecture supports new trigger types

### Implementation Philosophy:

**Minimize Risk:**
- Keep all backend class names unchanged (`PowerModeConfig`, `PowerModeManager`, etc.)
- Only add one property: `triggerWords: [String]` to existing model
- Extend existing services rather than creating new ones
- Preserve UserDefaults structure for stability

**Focus on UX:**
- New view layer presents everything as "Adaptive Awareness"
- User never sees "Power Mode" terminology
- Clean, consolidated interface hides backend complexity

**Future-Proof:**
- Backend can be refactored later once UI is proven
- Stage-based implementation allows incremental testing
- Clear separation between presentation and data layers

This pragmatic approach delivers maximum user value with minimum technical risk, allowing faster implementation and easier rollback if issues arise. By prioritizing user clarity and Apple's design patterns while maintaining backend stability, this redesign will make intelligent transcription more accessible and powerful for all users.