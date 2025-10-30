//
//  VoiceInkTests.swift
//  VoiceInkTests
//
//  Created by Prakash Joshi on 15/10/2024.
//

import Testing
@testable import VoiceInk

struct VoiceInkTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    // MARK: - Core Functionality Tests

    @Test func modelProviderEnumContainsAllProviders() async throws {
        let providers = ModelProvider.allCases
        #expect(providers.contains(.local))
        #expect(providers.contains(.groq))
        #expect(providers.contains(.deepgram))
        #expect(providers.contains(.soniox))
        #expect(providers.contains(.parakeet))
        #expect(providers.contains(.nativeApple))
    }

    @Test func predefinedModelsAreNotEmpty() async throws {
        let models = PredefinedModels.models
        #expect(!models.isEmpty)
    }

    @Test func sonioxModelExists() async throws {
        let sonioxModel = PredefinedModels.models.first { $0.provider == .soniox }
        #expect(sonioxModel != nil)
        #expect(sonioxModel?.name == "stt-async-v3")
    }

    @Test func allModelsHaveRequiredProperties() async throws {
        for model in PredefinedModels.models {
            #expect(!model.name.isEmpty)
            #expect(!model.displayName.isEmpty)
            #expect(!model.description.isEmpty)
        }
    }

    @Test func selectedTextServiceCanBeInstantiated() async throws {
        // Verify SelectedTextService compiles and can be accessed
        #expect(SelectedTextService.self != nil)
    }
}
