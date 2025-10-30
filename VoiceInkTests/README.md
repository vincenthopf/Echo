# Embr Echo Test Suite

## Overview
This directory contains unit and UI tests for Embr Echo (formerly VoiceInk), a native macOS voice transcription application.

## Running Tests

### All Tests
```bash
xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInk -destination 'platform=macOS'
```

### Unit Tests Only
```bash
xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInkTests -destination 'platform=macOS'
```

### UI Tests Only
```bash
xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInkUITests -destination 'platform=macOS'
```

### In Xcode
- **⌘+U**: Run all tests
- Click diamond icon next to test: Run single test
- Right-click test class: Run all tests in class

## Test Organization

### Unit Tests (`VoiceInkTests/`)
- `VoiceInkTests.swift` - Basic functionality tests
- `ServiceTests.swift` - Service layer integration tests for SelectedTextKit and Soniox

#### ServiceTests Coverage
- **SelectedTextKit Integration**: Async pattern validation, service availability
- **Soniox Service**: Model availability, provider enum verification, API integration
- **CloudTranscriptionService**: Routing logic, error handling
- **Model Configuration**: Provider initialization, predefined models validation
- **Language Support**: Multilingual capability verification

### UI Tests (`VoiceInkUITests/`)
- `VoiceInkUITests.swift` - UI interaction tests
- `VoiceInkUITestsLaunchTests.swift` - App launch and screenshot tests

## Writing New Tests

### Unit Test Template
```swift
func testFeatureName() throws {
    // Arrange
    let expectedValue = "test"

    // Act
    let result = serviceUnderTest.method()

    // Assert
    XCTAssertEqual(result, expectedValue)
}
```

### Async Test Template
```swift
func testAsyncFeature() async throws {
    let result = await asyncService.method()
    XCTAssertNotNil(result)
}
```

### Testing Principles
1. **Independence**: Tests should not depend on each other
2. **Isolation**: Use dependency injection and mocks when needed
3. **Clarity**: Test names should describe what is being tested
4. **Focus**: Test one thing at a time
5. **Setup/Teardown**: Use `setUp()` and `tearDown()` for common initialization

## Test Environment Notes

### Accessibility Permissions
Some tests (like `testSelectedTextServiceAsync`) require accessibility permissions which are not available in the test environment. These tests verify the code doesn't crash rather than testing actual functionality.

### API Keys
Cloud service tests will fail without valid API keys. This is expected behavior - tests verify error handling rather than successful API calls.

### File Paths
Tests use temporary file paths (`/tmp/test.wav`) for testing. Actual transcription functionality requires valid audio files and is tested separately.

## Test Coverage

Enable test coverage to measure code coverage:
1. **Edit Scheme** → **Test** → **Options**
2. Check **Code Coverage**
3. Select target: VoiceInk

View coverage reports:
- **Product** → **Show Result Navigator** (⌘+9)
- Select test run
- Click **Coverage** tab

## CI/CD Integration

Test schemes are shared in `xcshareddata/xcschemes/` for continuous integration:
- GitHub Actions can use these schemes
- Automated test runs on pull requests
- Build verification on commits

## Troubleshooting

### Tests Won't Run
- Verify test target has correct dependencies
- Check `@testable import VoiceInk` is present
- Ensure host application is set correctly
- Clean build folder: ⇧⌘K

### Async Test Timeouts
- Increase test timeout in scheme settings
- Check for unstructured tasks causing hangs
- Verify async/await usage is correct

### UI Test Failures
- Ensure app launches successfully
- Check for UI element accessibility identifiers
- Verify timing and wait conditions

## Best Practices

### DO
✅ Test public APIs and interfaces
✅ Test error conditions and edge cases
✅ Use descriptive test names
✅ Keep tests fast and focused
✅ Mock external dependencies
✅ Test async code with proper async/await

### DON'T
❌ Test implementation details
❌ Create dependent tests
❌ Write slow integration tests as unit tests
❌ Ignore flaky tests
❌ Test external services directly
❌ Mix async patterns (expectations vs async/await)

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing with Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/)
- [Swift Async/Await Testing](https://www.swiftbysundell.com/articles/unit-testing-code-that-uses-async-await/)
- [Apple's Testing Guide](https://developer.apple.com/documentation/xctest/asynchronous-tests-and-expectations)

## Contributing

When adding new features:
1. Write tests first (TDD approach recommended)
2. Ensure all tests pass before committing
3. Update this README if adding new test categories
4. Maintain test coverage above 70%

---

**Last Updated**: 2025-10-30
**Test Framework**: XCTest
**Minimum macOS**: 14.0
