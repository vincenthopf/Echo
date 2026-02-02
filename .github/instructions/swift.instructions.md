---
applyTo: "**/*.swift"
excludeAgent: "coding-agent"
---

# Swift Code Review Guidelines - Embr Voice

## Memory Safety

### Retain Cycles
- Flag closures that capture `self` without `[weak self]` or `[unowned self]`
- Especially in: Combine publishers, NotificationCenter observers, completion handlers, Timer callbacks

**Bad:**
```swift
NotificationCenter.default.addObserver(forName: .someNotification, object: nil, queue: .main) { _ in
    self.handleNotification() // Retain cycle!
}
```

**Good:**
```swift
NotificationCenter.default.addObserver(forName: .someNotification, object: nil, queue: .main) { [weak self] _ in
    self?.handleNotification()
}
```

### Force Unwrapping
- Flag force unwraps (`!`) except in IBOutlets or clearly justified cases
- Prefer `guard let`, `if let`, or nil-coalescing (`??`)

**Bad:**
```swift
let value = dictionary["key"]!
```

**Good:**
```swift
guard let value = dictionary["key"] else { return }
```

## Concurrency

### Main Thread Safety
- UI updates must be on `@MainActor` or wrapped in `DispatchQueue.main.async`
- Flag `@Published` property updates from background contexts without `@MainActor`

**Bad:**
```swift
func fetchData() async {
    let data = await api.fetch()
    self.items = data // May not be on main thread!
}
```

**Good:**
```swift
@MainActor
func fetchData() async {
    let data = await api.fetch()
    self.items = data
}
```

### Actor Isolation
- Ensure proper actor isolation when accessing actor-protected state
- Flag `nonisolated` usage that could cause data races

### Task Cancellation
- Check for proper handling of `Task.isCancelled` in long-running operations
- Ensure tasks are cancelled when views disappear or objects deinit

## SwiftUI Specifics

### View Performance
- Flag expensive computations in view `body` - move to view model
- Check for unnecessary `@State` when `let` suffices
- Flag missing `@StateObject` vs `@ObservedObject` issues (ownership)

### Environment Objects
- Ensure `@EnvironmentObject` dependencies are provided in the view hierarchy
- Flag force unwrapping of optional environment values

## AppKit Integration (macOS)

### NSHostingController
- Verify layer backgrounds are cleared for transparent windows
- Check `wantsLayer = true` is set before layer configuration

### NSPanel/NSWindow
- Verify proper cleanup in `deinit` (remove observers, close windows)
- Check for proper `isOpaque`, `backgroundColor` settings for transparency

## Error Handling

### Async/Throws
- Flag `try?` that silently swallows important errors
- Ensure proper error propagation with `throws` or `Result`

**Bad:**
```swift
let data = try? await fetchData() // Error silently ignored
```

**Good:**
```swift
do {
    let data = try await fetchData()
} catch {
    logger.error("Fetch failed: \(error)")
    throw error
}
```

### Optional Chaining
- Flag long optional chains that could hide nil issues
- Prefer early `guard` statements for clarity

## Logging & Debugging

### OSLog Usage
- Flag `print()` statements - use OSLog instead
- Ensure sensitive data is not logged (transcription content, API keys)
- Use appropriate log levels: `.debug`, `.info`, `.error`, `.fault`

**Bad:**
```swift
print("API Key: \(apiKey)")
```

**Good:**
```swift
Logger.api.debug("Request initiated")
```

## Resource Management

### Audio Sessions
- Verify audio sessions are properly activated/deactivated
- Check for proper cleanup when recording stops

### File Handles
- Ensure file handles are closed (use `defer` or structured concurrency)
- Flag potential file descriptor leaks

## API Patterns (Project-Specific)

### Service Layer
- API calls should go through appropriate service classes
- Flag direct URLSession usage outside of service layer

### State Management
- State changes in WhisperState should follow the state machine pattern
- Recording state: `idle → recording → transcribing → enhancing → idle`

### Adaptive Awareness (PowerMode)
- Profile activation should follow precedence: Voice Triggers > URL > App Bundle > Default
- Flag changes that could break activation logic
