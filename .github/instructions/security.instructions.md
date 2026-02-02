---
applyTo: "**/*.swift"
excludeAgent: "coding-agent"
---

# Security Review Guidelines - Embr Voice

## API Keys & Secrets

### Detection Patterns
Flag any of these patterns in code:
- `sk-` (OpenAI keys)
- `api_key`, `apiKey`, `API_KEY`
- `secret`, `password`, `credential`
- `bearer`, `token` (when hardcoded)
- Base64-encoded strings that look like keys

**Bad:**
```swift
let apiKey = "sk-abc123..."
```

**Good:**
```swift
let apiKey = KeychainService.shared.getAPIKey()
```

### Secure Storage
- API keys must use Keychain or secure environment
- Flag keys stored in UserDefaults, plist, or hardcoded

## User Data Protection

### Transcription Content
- Transcription text should not be logged in production
- Flag OSLog statements that include transcription content
- Ensure transcription data is cleared when appropriate

### Audio Recordings
- Verify recordings are stored in app-specific directory
- Check for proper cleanup of temporary audio files
- Flag any external sharing of raw audio without consent

## Network Security

### HTTPS Enforcement
- All API calls must use HTTPS
- Flag `http://` URLs (except localhost for debugging)

### Certificate Validation
- Do not disable SSL certificate validation
- Flag `URLSessionDelegate` methods that bypass validation

**Bad:**
```swift
func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) {
    completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
}
```

### Request/Response Handling
- Sanitize user input before including in URLs
- Validate API responses before processing
- Flag JSON parsing without error handling

## Accessibility & Permissions

### Permission Requests
- Microphone access must be requested before use
- Accessibility permissions must be checked before simulating input
- Flag code that assumes permissions are granted

### AppleScript Execution
- Validate URLs extracted via AppleScript
- Flag dynamic AppleScript construction with user input

## Input Validation

### External Data
- Validate data from:
  - API responses
  - File imports
  - Clipboard content
  - URL schemes
  - AppleScript results

### Path Traversal
- Validate file paths don't escape app sandbox
- Use `URL.standardizedFileURL` for path normalization

## License & Obfuscation

### License Validation
- License checks should be tamper-resistant
- Flag license bypass patterns
- Obfuscator.swift changes require extra scrutiny

## Logging Security

### Sensitive Data
Never log:
- API keys or tokens
- User transcriptions
- License keys
- Personal identifiers

**Bad:**
```swift
Logger.api.info("Request with key: \(apiKey)")
Logger.transcription.debug("Text: \(transcribedText)")
```

**Good:**
```swift
Logger.api.info("Request initiated")
Logger.transcription.debug("Transcription completed, length: \(text.count)")
```
