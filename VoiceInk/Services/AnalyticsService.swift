import Foundation
import PostHog
import OSLog
import SwiftUI

/// Thin analytics wrapper around PostHog. The rest of the app talks to
/// AnalyticsService, never to PostHog directly — keeps the dependency swappable.
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let logger = Logger(subsystem: "com.VincentHopf.embrvoice", category: "Analytics")

    /// User-facing opt-out preference. Persisted across launches.
    @AppStorage("analyticsEnabled") private(set) var isEnabled: Bool = true

    private init() {}

    // MARK: - Lifecycle

    /// Call once at app startup, after all other services are initialized.
    func configure() {
        guard isEnabled else {
            logger.info("Analytics disabled by user — skipping PostHog setup")
            return
        }

        let config = PostHogConfig(apiKey: "phc_ud21dhqQ5xprhud7S8XJ8wfuIaSl2B3zUQuIb9POpbW", host: "https://us.i.posthog.com")
        config.captureApplicationLifecycleEvents = true
        config.flushAt = 10
        config.flushIntervalSeconds = 30

        PostHogSDK.shared.setup(config)

        PostHogSDK.shared.register([
            "platform": "macOS",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        ])

        logger.info("PostHog analytics configured")
    }

    // MARK: - Tracking

    func track(_ event: String, properties: [String: Any]? = nil) {
        guard isEnabled else { return }
        PostHogSDK.shared.capture(event, properties: properties)
    }

    func screen(_ name: String, properties: [String: Any]? = nil) {
        guard isEnabled else { return }
        PostHogSDK.shared.screen(name, properties: properties)
    }

    // MARK: - Identity

    func identify(_ userId: String, properties: [String: Any]? = nil) {
        guard isEnabled else { return }
        PostHogSDK.shared.identify(userId, userProperties: properties)
    }

    func reset() {
        PostHogSDK.shared.reset()
    }

    // MARK: - Privacy

    func optIn() {
        isEnabled = true
        configure()
        logger.info("Analytics opted in")
    }

    func optOut() {
        isEnabled = false
        PostHogSDK.shared.optOut()
        PostHogSDK.shared.reset()
        logger.info("Analytics opted out and data cleared")
    }
}
