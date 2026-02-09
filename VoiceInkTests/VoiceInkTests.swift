import XCTest
@testable import Echo

final class VoiceInkCoreTests: XCTestCase {
    func testModelProviderEnumContainsAllProviders() {
        let providers = Set(ModelProvider.allCases)
        let expected: Set<ModelProvider> = [
            .local, .parakeet, .groq, .elevenLabs, .deepgram, .mistral, .gemini, .soniox, .custom, .nativeApple
        ]

        XCTAssertEqual(providers, expected)
    }

    func testPredefinedModelsAreNotEmpty() {
        XCTAssertFalse(PredefinedModels.models.isEmpty)
    }

    func testSonioxModelExists() {
        XCTAssertNotNil(PredefinedModels.models.first { $0.name == "stt-async-v3" })
    }

    func testAllModelsHaveRequiredProperties() {
        for model in PredefinedModels.models {
            XCTAssertFalse(model.name.isEmpty)
            XCTAssertFalse(model.displayName.isEmpty)
            XCTAssertFalse(model.description.isEmpty)
        }
    }

    func testSelectedTextServiceCanBeInstantiated() {
        XCTAssertNotNil(SelectedTextService.self)
    }
}
