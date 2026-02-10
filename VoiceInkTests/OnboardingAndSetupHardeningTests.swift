import XCTest
@testable import Echo

final class OnboardingAndSetupHardeningTests: XCTestCase {
    func testSetupReadinessRequiredCompleteWhenOnlyRequiredSatisfied() {
        let readiness = SetupReadinessEvaluator.evaluate(
            microphoneAuthorized: true,
            hotkeyConfigured: true,
            hasUsableDefaultModel: true,
            accessibilityEnabled: false,
            screenRecordingEnabled: false
        )

        XCTAssertTrue(readiness.requiredComplete)
        XCTAssertEqual(readiness.accessibility, .incomplete)
        XCTAssertEqual(readiness.screenRecording, .incomplete)
    }

    func testSetupReadinessFailsWithoutUsableModel() {
        let readiness = SetupReadinessEvaluator.evaluate(
            microphoneAuthorized: true,
            hotkeyConfigured: true,
            hasUsableDefaultModel: false,
            accessibilityEnabled: true,
            screenRecordingEnabled: true
        )

        XCTAssertFalse(readiness.requiredComplete)
        XCTAssertEqual(readiness.defaultModel, .incomplete)
    }

    func testOnboardingModelPickerAppleSiliconRecommendation() {
        let model = OnboardingModelPicker.recommendedModel(isAppleSilicon: true, isIntel: false)
        XCTAssertEqual(model?.name, "parakeet-tdt-0.6b-v3")
    }

    func testOnboardingModelPickerIntelRecommendation() {
        let model = OnboardingModelPicker.recommendedModel(isAppleSilicon: false, isIntel: true)
        XCTAssertEqual(model?.name, "ggml-base.en")
    }

    func testOnboardingModelPickerFallbackRecommendation() {
        let model = OnboardingModelPicker.recommendedModel(isAppleSilicon: false, isIntel: false)
        XCTAssertNotNil(model)
    }

    @MainActor
    func testLocalProgressResolverWeightedMainAndCoreML() {
        let state = WhisperState.resolveLocalProgressState(
            modelName: "ggml-base.en",
            downloadProgress: [
                "ggml-base.en_main": 0.8,
                "ggml-base.en_coreml": 0.4
            ]
        )
        guard let state else {
            XCTFail("Expected local progress state")
            return
        }
        XCTAssertEqual(state.fraction, 0.6, accuracy: 0.0001)
        XCTAssertEqual(state.isEstimated, false)
    }

    @MainActor
    func testParakeetProgressResolverUsesEstimatedFlag() {
        let state = WhisperState.resolveParakeetProgressState(
            modelName: "parakeet-tdt-0.6b-v3",
            downloadProgress: ["parakeet-tdt-0.6b-v3": 0.42],
            isDownloading: true
        )
        guard let state else {
            XCTFail("Expected parakeet progress state")
            return
        }
        XCTAssertEqual(state.fraction, 0.42, accuracy: 0.0001)
        XCTAssertEqual(state.isEstimated, true)
    }
}
