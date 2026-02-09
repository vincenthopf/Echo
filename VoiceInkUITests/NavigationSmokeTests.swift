import XCTest

final class NavigationSmokeTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSettingsIntelligenceAdaptiveRoundTrip() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-hasCompletedOnboarding", "YES"]
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launch()

        let settingsNavButton = app.buttons["sidebar.Settings"]
        XCTAssertTrue(settingsNavButton.waitForExistence(timeout: 10))
        settingsNavButton.tap()

        // Tab controls can surface as either radio buttons or regular buttons on macOS.
        let intelligenceRadioTab = app.radioButtons["Intelligence"]
        let intelligenceButtonTab = app.buttons["Intelligence"]

        let manageProfilesButton = app.buttons["intelligence.manageProfiles"]
        if !manageProfilesButton.waitForExistence(timeout: 3) {
            if intelligenceRadioTab.waitForExistence(timeout: 3) {
                intelligenceRadioTab.tap()
            } else if intelligenceButtonTab.waitForExistence(timeout: 3) {
                intelligenceButtonTab.tap()
            }
        }

        XCTAssertTrue(manageProfilesButton.waitForExistence(timeout: 8))
        manageProfilesButton.tap()

        let openGlobalSettingsButton = app.buttons["adaptive.openIntelligenceSettings"]
        XCTAssertTrue(openGlobalSettingsButton.waitForExistence(timeout: 5))
        openGlobalSettingsButton.tap()

        XCTAssertTrue(intelligenceRadioTab.waitForExistence(timeout: 5) || intelligenceButtonTab.waitForExistence(timeout: 5))
        XCTAssertTrue(manageProfilesButton.waitForExistence(timeout: 5))
    }
}
