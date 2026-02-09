import XCTest
@testable import Echo

final class PowerModeManagerInvariantTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var manager: PowerModeManager!

    override func setUp() {
        super.setUp()
        suiteName = "PowerModeManagerInvariantTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        manager = PowerModeManager(userDefaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        manager = nil
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testMultipleDefaultsNormalizeToOne() {
        let first = makeConfig(name: "First", isEnabled: false, isDefault: true)
        let second = makeConfig(name: "Second", isEnabled: true, isDefault: true)

        manager.replaceConfigurations([first, second])

        XCTAssertEqual(manager.configurations.count, 2)
        XCTAssertEqual(manager.configurations.filter(\.isDefault).count, 1)
        XCTAssertTrue(manager.configurations[0].isDefault)
        XCTAssertTrue(manager.configurations[0].isEnabled)
    }

    func testNoDefaultNormalizesToFirst() {
        let first = makeConfig(name: "First", isEnabled: true, isDefault: false)
        let second = makeConfig(name: "Second", isEnabled: true, isDefault: false)

        manager.replaceConfigurations([first, second])

        XCTAssertTrue(manager.configurations[0].isDefault)
        XCTAssertFalse(manager.configurations[1].isDefault)
    }

    func testDefaultAlwaysEnabled() {
        let defaultConfig = makeConfig(name: "Default", isEnabled: false, isDefault: true)
        manager.replaceConfigurations([defaultConfig])

        XCTAssertTrue(manager.configurations[0].isDefault)
        XCTAssertTrue(manager.configurations[0].isEnabled)

        manager.disableConfiguration(with: defaultConfig.id)
        XCTAssertTrue(manager.configurations[0].isDefault)
        XCTAssertTrue(manager.configurations[0].isEnabled)
    }

    func testDeleteDefaultReassignsDefault() {
        let first = makeConfig(name: "First", isEnabled: true, isDefault: true)
        let second = makeConfig(name: "Second", isEnabled: true, isDefault: false)

        manager.replaceConfigurations([first, second])
        manager.removeConfiguration(with: first.id)

        XCTAssertEqual(manager.configurations.count, 1)
        XCTAssertEqual(manager.configurations[0].id, second.id)
        XCTAssertTrue(manager.configurations[0].isDefault)
    }

    func testReplaceConfigurationsNormalizesImportedData() {
        let first = makeConfig(name: "One", isEnabled: true, isDefault: false)
        let second = makeConfig(name: "Two", isEnabled: true, isDefault: true)
        let third = makeConfig(name: "Three", isEnabled: true, isDefault: true)

        manager.replaceConfigurations([first, second, third])

        XCTAssertEqual(manager.configurations.filter(\.isDefault).count, 1)
        XCTAssertEqual(manager.configurations.first(where: { $0.isDefault })?.id, second.id)
    }

    func testReplacingConfigurationsClearsMissingActiveConfiguration() {
        let first = makeConfig(name: "First", isEnabled: true, isDefault: true)
        let second = makeConfig(name: "Second", isEnabled: true, isDefault: false)

        manager.replaceConfigurations([first, second])
        manager.setActiveConfiguration(second)

        manager.replaceConfigurations([first])

        XCTAssertNil(manager.activeConfiguration)
        XCTAssertNil(defaults.string(forKey: "activeConfigurationId"))
    }

    private func makeConfig(name: String, isEnabled: Bool, isDefault: Bool) -> PowerModeConfig {
        PowerModeConfig(
            id: UUID(),
            name: name,
            emoji: "sparkles",
            isAIEnhancementEnabled: false,
            isEnabled: isEnabled,
            isDefault: isDefault
        )
    }
}
