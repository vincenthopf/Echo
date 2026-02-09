import XCTest
@testable import Echo

final class AppDestinationRoutingTests: XCTestCase {
    func testEveryAppDestinationMapsToExpectedViewType() {
        XCTAssertEqual(ViewType.from(destination: .dashboard), .metrics)
        XCTAssertEqual(ViewType.from(destination: .transcribeFiles), .transcribeAudio)
        XCTAssertEqual(ViewType.from(destination: .adaptiveAwareness), .powerMode)
        XCTAssertEqual(ViewType.from(destination: .vocabulary), .vocabulary)
        XCTAssertEqual(ViewType.from(destination: .history), .history)
        XCTAssertEqual(ViewType.from(destination: .settings), .settings)
        XCTAssertEqual(ViewType.from(destination: .about), .about)
    }

    func testDestinationUserInfoRoundTrips() {
        let payload = Notification.destinationUserInfo(.settings)
        XCTAssertEqual(payload.appDestination, .settings)
    }

    func testSettingsDeepLinkSelectionUsesIntelligenceTab() {
        UserDefaults.standard.removeObject(forKey: "selectedSettingsTab")
        UserDefaults.standard.set(SettingsTab.intelligence.rawValue, forKey: "selectedSettingsTab")

        XCTAssertEqual(
            UserDefaults.standard.string(forKey: "selectedSettingsTab"),
            SettingsTab.intelligence.rawValue
        )
    }
}
