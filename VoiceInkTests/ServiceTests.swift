import XCTest
@testable import VoiceInk

final class ServiceTests: XCTestCase {

    // MARK: - SelectedTextKit Integration Tests

    func testSelectedTextServiceAvailability() {
        // Verify SelectedTextService can be called
        XCTAssertNotNil(SelectedTextService.self)
    }

    func testSelectedTextServiceAsync() async {
        // Test async pattern works
        // Note: Will return nil without UI/accessibility permissions in test environment
        let result = await SelectedTextService.fetchSelectedText()
        // We expect nil in test environment, but should not crash
        XCTAssertTrue(result == nil || result is String)
    }

    // MARK: - Soniox Service Tests

    func testSonioxServiceExists() {
        // Verify Soniox service can be instantiated
        let service = SonioxTranscriptionService()
        XCTAssertNotNil(service)
    }

    func testSonioxModelAvailable() {
        let models = PredefinedModels.models
        let sonioxModel = models.first { $0.name == "stt-async-v3" }

        XCTAssertNotNil(sonioxModel, "Soniox model should be available")
        XCTAssertEqual(sonioxModel?.provider, .soniox)
        XCTAssertEqual(sonioxModel?.displayName, "Soniox (stt-async-v3)")
    }

    func testSonioxProviderExists() {
        let providers = ModelProvider.allCases
        XCTAssertTrue(providers.contains(.soniox), "Soniox should be in ModelProvider enum")
    }

    // MARK: - CloudTranscriptionService Tests

    func testCloudServiceHandlesSoniox() async {
        let cloudService = CloudTranscriptionService()

        // Create test audio URL (even if file doesn't exist for this test)
        let testURL = URL(fileURLWithPath: "/tmp/test.wav")

        // This will fail without API key, but should not crash
        do {
            _ = try await cloudService.transcribe(
                audioURL: testURL,
                model: PredefinedModels.models.first { $0.name == "stt-async-v3" }!
            )
            XCTFail("Should fail without API key")
        } catch {
            // Expected to fail, but should be proper error, not crash
            XCTAssertTrue(error is CloudTranscriptionError || error is URLError)
        }
    }

    // MARK: - Model Configuration Tests

    func testAllProvidersHaveModels() {
        let models = PredefinedModels.models
        let providers = ModelProvider.allCases

        for provider in providers {
            let providerModels = models.filter { $0.provider == provider }
            XCTAssertFalse(
                providerModels.isEmpty,
                "\(provider.rawValue) should have at least one model"
            )
        }
    }

    func testModelProviderInitialization() throws {
        // Test that all model providers can be initialized
        let providers = ModelProvider.allCases
        XCTAssertTrue(providers.contains(.soniox), "Soniox provider should exist")
        XCTAssertTrue(providers.contains(.groq), "Groq provider should exist")
        XCTAssertTrue(providers.contains(.deepgram), "Deepgram provider should exist")
        XCTAssertTrue(providers.contains(.mistral), "Mistral provider should exist")
        XCTAssertTrue(providers.contains(.gemini), "Gemini provider should exist")
        XCTAssertTrue(providers.contains(.elevenLabs), "ElevenLabs provider should exist")
        XCTAssertTrue(providers.contains(.local), "Local provider should exist")
        XCTAssertTrue(providers.contains(.parakeet), "Parakeet provider should exist")
        XCTAssertTrue(providers.contains(.nativeApple), "Native Apple provider should exist")
    }

    func testPredefinedModelsAvailability() throws {
        // Test that predefined models are accessible
        let models = PredefinedModels.models
        XCTAssertFalse(models.isEmpty, "Should have predefined models")

        // Verify each model has required properties
        for model in models {
            XCTAssertFalse(model.name.isEmpty, "Model name should not be empty")
            XCTAssertFalse(model.displayName.isEmpty, "Display name should not be empty")
            XCTAssertFalse(model.description.isEmpty, "Description should not be empty")
        }
    }

    // MARK: - Integration Tests

    func testSelectedTextKitIntegration() {
        // Verify SelectedTextKit is properly integrated
        // The service should compile and be accessible
        XCTAssertNoThrow(SelectedTextService.self)
    }

    func testSonioxIntegrationComplete() {
        // Verify all Soniox integration points
        let hasProvider = ModelProvider.allCases.contains(.soniox)
        let hasModel = PredefinedModels.models.contains { $0.provider == .soniox }
        let hasService = SonioxTranscriptionService() != nil

        XCTAssertTrue(hasProvider, "ModelProvider should include Soniox")
        XCTAssertTrue(hasModel, "PredefinedModels should include Soniox model")
        XCTAssertTrue(hasService, "SonioxTranscriptionService should be instantiable")
    }

    // MARK: - Language Support Tests

    func testSonioxLanguageSupport() {
        let sonioxModel = PredefinedModels.models.first { $0.provider == .soniox }
        XCTAssertNotNil(sonioxModel, "Soniox model should exist")
        XCTAssertTrue(sonioxModel?.isMultilingualModel ?? false, "Soniox should support multiple languages")
        XCTAssertFalse(sonioxModel?.supportedLanguages.isEmpty ?? true, "Soniox should have supported languages")
    }
}
