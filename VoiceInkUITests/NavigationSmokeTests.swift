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
        app.launchArguments += ["-selectedSettingsTab", "Intelligence"]
        addUIInterruptionMonitor(withDescription: "System Dialogs") { alert in
            if alert.buttons["Don’t Allow"].exists { alert.buttons["Don’t Allow"].tap(); return true }
            if alert.buttons["OK"].exists { alert.buttons["OK"].tap(); return true }
            if alert.buttons["Allow"].exists { alert.buttons["Allow"].tap(); return true }
            return false
        }
        app.launch()
        app.activate()

        let settingsNavButton = app.buttons["sidebar.Settings"]
        XCTAssertTrue(settingsNavButton.waitForExistence(timeout: 10))
        tapSafely(settingsNavButton, in: app)

        let manageProfilesButton = app.buttons["intelligence.manageProfiles"]
        XCTAssertTrue(manageProfilesButton.waitForExistence(timeout: 8))
        tapSafely(manageProfilesButton, in: app)

        let openGlobalSettingsButton = app.buttons["adaptive.openIntelligenceSettings"]
        XCTAssertTrue(openGlobalSettingsButton.waitForExistence(timeout: 5))
        tapSafely(openGlobalSettingsButton, in: app)
        app.activate()

        XCTAssertTrue(manageProfilesButton.waitForExistence(timeout: 5))
    }

    @MainActor
    private func tapSafely(_ element: XCUIElement, in app: XCUIApplication) {
        app.activate()
        if element.isHittable {
            element.tap()
            return
        }

        let center = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
    }
}
