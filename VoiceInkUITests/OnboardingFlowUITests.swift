import XCTest

final class OnboardingFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testQuickSetupContinueEnabledWhenOnlyRequiredAreComplete() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launchArguments += ["-hasCompletedOnboarding", "NO"]
        app.launchArguments += ["-uiTestMode"]
        app.launchArguments += ["-uiTestSkipOnboardingIntro"]
        app.launchArguments += ["-uiTestStartQuickSetup"]
        app.launchArguments += ["-uiTestChecklistRequiredComplete"]
        app.launchArguments += ["-uiTestChecklistOptionalIncomplete"]
        app.launch()

        let continueButton = app.buttons["onboarding.quickSetup.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 8))
        XCTAssertTrue(continueButton.isEnabled)

        XCTAssertTrue(app.otherElements["onboarding.checklist.accessibility"].exists)
        XCTAssertTrue(app.otherElements["onboarding.checklist.screenRecording"].exists)
    }

    @MainActor
    func testOnboardingParakeetDownloadShowsNumericEstimatedPercentage() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launchArguments += ["-hasCompletedOnboarding", "NO"]
        app.launchArguments += ["-uiTestMode"]
        app.launchArguments += ["-uiTestSkipOnboardingIntro"]
        app.launchArguments += ["-uiTestStartQuickSetup"]
        app.launchArguments += ["-uiTestChecklistRequiredComplete"]
        app.launchArguments += ["-uiTestChecklistOptionalIncomplete"]
        app.launchArguments += ["-uiTestForceModelSelection"]
        app.launchArguments += ["-uiTestMockParakeetProgress"]
        app.launchEnvironment["VOICEINK_ONBOARDING_MODEL_OVERRIDE"] = "parakeet-tdt-0.6b-v3"
        app.launch()

        let continueQuickSetup = app.buttons["onboarding.quickSetup.continue"]
        XCTAssertTrue(continueQuickSetup.waitForExistence(timeout: 8))
        continueQuickSetup.tap()

        let continueModelSelection = app.buttons["onboarding.modelSelection.continue"]
        XCTAssertTrue(continueModelSelection.waitForExistence(timeout: 8))
        continueModelSelection.tap()

        let progressText = app.staticTexts["model.download.progressText"]
        XCTAssertTrue(progressText.waitForExistence(timeout: 8))
        XCTAssertTrue(progressText.label.contains("%"))
        XCTAssertTrue(app.staticTexts["Estimated"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testOnboardingLocalDownloadShowsNumericPercentage() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launchArguments += ["-hasCompletedOnboarding", "NO"]
        app.launchArguments += ["-uiTestMode"]
        app.launchArguments += ["-uiTestSkipOnboardingIntro"]
        app.launchArguments += ["-uiTestStartQuickSetup"]
        app.launchArguments += ["-uiTestChecklistRequiredComplete"]
        app.launchArguments += ["-uiTestChecklistOptionalIncomplete"]
        app.launchArguments += ["-uiTestForceModelSelection"]
        app.launchArguments += ["-uiTestMockLocalProgress"]
        app.launchEnvironment["VOICEINK_ONBOARDING_MODEL_OVERRIDE"] = "ggml-base.en"
        app.launch()

        let continueQuickSetup = app.buttons["onboarding.quickSetup.continue"]
        XCTAssertTrue(continueQuickSetup.waitForExistence(timeout: 8))
        continueQuickSetup.tap()

        let continueModelSelection = app.buttons["onboarding.modelSelection.continue"]
        XCTAssertTrue(continueModelSelection.waitForExistence(timeout: 8))
        continueModelSelection.tap()

        let progressText = app.staticTexts["model.download.progressText"]
        XCTAssertTrue(progressText.waitForExistence(timeout: 8))
        XCTAssertTrue(progressText.label.contains("%"))
    }
}
