# VoiceInk UI Redesign V2 - Grid-Based Design

## Design Direction
Based on parallel.ai style with native macOS feel:
- **No cards** - use 1px border grids instead
- **Original orange `#CC785C`** restored
- **System fonts** (SF Pro)
- **Thin borders** create structure, not shadows
- **Left accent bars** on section headers
- **Generous whitespace**

## Color Palette

### Light Mode
- Background: `#FAFAF8` (warm off-white)
- Elevated/Card BG: `#FFFFFF`
- Border: `#E8E6E1`
- Border Strong: `#D4D2CD`
- Text Primary: `#1A1A18`
- Text Secondary: `#7A7A72`
- Text Tertiary: `#A8A8A0`
- Orange: `#CC785C`
- Orange Soft: `rgba(204, 120, 92, 0.08)`
- Orange Medium: `rgba(204, 120, 92, 0.15)`
- Success: `#4A9D5B`

### Dark Mode
- Background: `#141413`
- Elevated/Card BG: `#1E1E1C`
- Border: `#2A2A28`
- Border Strong: `#3A3A38`
- Text Primary: `#F5F5F3`
- Text Secondary: `#9A9A92`
- Text Tertiary: `#6A6A62`

## Files to Update

### Phase 1: Design System Foundation
1. `DesignSystem.swift` - New color tokens, remove card modifiers, add grid helpers

### Phase 2: Dashboard (MetricsView)
2. `MetricCard.swift` - Grid cell style, no card background
3. `MetricsContent.swift` - Grid layout for metrics
4. `TimeEfficiencyView.swift` - Hero stats with border grid

### Phase 3: Adaptive Awareness
5. `ProfileListView.swift` - Clean list with left accent selection
6. `ProfileDetailView.swift` - Remove sectionCard, use dividers
7. `GeneralSection.swift` - Form grid style
8. `ActivationTriggersSection.swift` - 3-column trigger grid
9. `TranscriptionSection.swift` - Form grid style
10. `AIEnhancementSection.swift` - Form grid style
11. `AdvancedSection.swift` - Form grid style

### Phase 4: Sidebar
12. `ContentView.swift` - Update sidebar styling

## Key Patterns

### Grid Container (replaces cards)
```swift
// Border grid container
VStack(spacing: 0) {
    content
}
.background(Colors.elevated(for: colorScheme))
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(Colors.border(for: colorScheme), lineWidth: 1)
)
```

### Grid Row with Label
```swift
HStack(spacing: 0) {
    // Label column
    Text("LABEL")
        .font(.system(size: 10, weight: .medium))
        .tracking(0.5)
        .foregroundColor(Colors.textTertiary(for: colorScheme))
        .frame(width: 140, alignment: .leading)
        .padding(14)
        .background(Colors.background(for: colorScheme))

    // Value column
    content
        .padding(14)
}
.background(Colors.elevated(for: colorScheme))
```

### Section Header
```swift
HStack(alignment: .top, spacing: 12) {
    RoundedRectangle(cornerRadius: 2)
        .fill(Colors.orange)
        .frame(width: 3, height: 24)

    VStack(alignment: .leading, spacing: 2) {
        Text(title)
            .font(.system(size: 16, weight: .medium))
        Text(subtitle)
            .font(.system(size: 12))
            .foregroundColor(Colors.textTertiary(for: colorScheme))
    }
}
```
