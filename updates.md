# UI/UX Naming Update Task

In this document you will find a list of potential future changes we will want to make. Your goal is to methodically work through these 1 by 1. Starting at the top most unchecked task. Before tackling any of them you need to make sure you do the following:

* Systematically Work through the codebase to find the correct files that need editing. Once you are 90% sure you will deploy a subagent with no context of this and ask them to do the same task with no techincal details provided to it. This subagent will need to respond back with what files need to be changed, which you can cross reference with what you already chose. If the subagents respective suggested changes are different to yours you should work out why, and who is actually correct from the perspective of a senior iOS Developer.
* Once the correct files have been identified you should do appropriate web searches and use the context7 MCP server to find appropriate documentation. When searching, mention the language we are using, the current achitecture, and the issue or question you have.

Update all user-facing text in the Embr Echo application to reflect our refined naming scheme. This includes UI labels, menu items, settings headers, tooltips, button text, and any in-app documentation or help text.

## Application-Wide Changes

**Primary branding:**

* "VoiceInk" or "Embr Voice" → "Embr Echo" (everywhere in UI)
* Update all references in: window titles, menu bar, About section, settings headers

## Feature Naming Updates by Section

### Recording & Transcription Section

| Old Name               | New Name            | Status |
| :--------------------- | :------------------ | :----- |
| Recording Modes        | Smart Recording     | ✓ Done |
| Recorder Styles        | Recording Interface | ✓ Done |
| Audio Input Settings   | Input Routing       | ✓ Done |
| Transcribe Audio Files | Keep as is          | N/A    |

### AI Enhancement Section

| Old Name            | New Name                   |
| :------------------ | :------------------------- |
| AI Enhancement      | Intelligent Transformation |
| Enhancement Prompts | Transformation Prompts     |
| Custom Prompts      | Keep as is                 |
| AI Provider Setup   | Keep as is                 |

**Important:** Remove all instances of "enhance/enhancement/enhancing" in user-facing text. Replace with "transform/transforming" or "process/processing" depending on context.

### Adaptive Awareness Section (formerly Power Mode)

| Old Name                   | New Name              |
| :------------------------- | :-------------------- |
| Power Mode                 | Adaptive Awareness    |
| Creating Power Modes       | Configuring Awareness |
| URL-Based Power Modes      | Site Recognition      |
| Screen Context Integration | Visual Context        |

### Models & Languages Section

No changes required in this section. Keep all existing naming.

### Customisation Section

| Old Name            | New Name            |
| :------------------ | :------------------ |
| Keyboard Shortcuts  | Keep as is          |
| Custom Dictionary   | Personal Vocabulary |
| Word Replacements   | Smart Corrections   |
| Output Preferences  | Output Behaviour    |
| Appearance Settings | Keep as is          |

**Note:** Use British spelling for "Customisation" and "Behaviour" in all UI text.

### Advanced Features Section

| Old Name                 | New Name         |
| :----------------------- | :--------------- |
| Data Privacy & Cleanup   | Privacy Controls |
| Transcription History    | Keep as is       |
| Import & Export Settings | Backup & Restore |
| Middle-Click Recording   | Mouse Activation |
| System Integration       | Audio Management |

## Additional Requirements

1. **Consistency check:** Search the entire codebase for any remaining instances of old naming and update them in:
   * Menu items
   * Button labels
   * Dialog titles
   * Settings headers and subheaders
   * Tooltips
   * Help text
   * Error messages
   * Success notifications
   * Placeholder text

2. **Navigation paths:** Update any settings navigation breadcrumbs that reference old names

3. **Keyboard shortcut references:** Update "VoiceInk Shortcuts" to "Embr Echo Shortcuts" in Settings → General

## Testing Checklist

After implementing changes, verify:

* [ ] All settings menus display new names
* [ ] Menu bar items reflect new naming
* [ ] Tooltips use updated terminology
* [ ] No instances of "VoiceInk" remain (except in legacy code comments if needed)
* [ ] No instances of "Power Mode" remain in UI
* [ ] No instances of "Enhancement" remain in user-facing text
* [ ] British spelling is consistent throughout
* [ ] All dialog boxes and alerts use new naming

