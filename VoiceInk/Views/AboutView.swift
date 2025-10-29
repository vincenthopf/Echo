import SwiftUI

/// About page showcasing Embr Echo's philosophy and capabilities
struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero section
                heroSection

                // Main content
                mainContent
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var heroSection: some View {
        VStack(spacing: 24) {
            // App icon
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(26)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, y: 8)
            }

            VStack(spacing: 8) {
                Text("Embr Echo")
                    .font(.system(size: 36, weight: .bold))

                Text("Version \(appVersion)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.05),
                    Color(NSColor.controlBackgroundColor)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 40) {
            // The Manifesto
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Voice, Unfiltered")
                    .font(.system(size: 24, weight: .bold))

                VStack(alignment: .leading, spacing: 14) {
                    Text("In a world where every word you speak could be someone else's data, Embr Echo takes a different path.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("We believe your thoughts, your ideas, your voice—they're yours. Not training data. Not metadata. Not a product.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("That's why everything happens on your Mac. Your voice never leaves your machine unless you explicitly choose otherwise. No cloud roundtrips. No mysterious servers. No corporate surveillance masquerading as 'improvement.'")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider()

            // Why Embr Echo is Different
            VStack(alignment: .leading, spacing: 20) {
                Text("Beyond the Competition")
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 20) {
                    FeatureComparison(
                        title: "Privacy First, Not Privacy Theater",
                        description: "While Whisper Flow and others process your voice in the cloud 'for better accuracy,' we give you the choice. Local models run entirely offline. When you do choose cloud processing, it's transparent, explicit, and in your control.",
                        icon: "lock.shield.fill",
                        accentColor: .green
                    )

                    FeatureComparison(
                        title: "Power Mode: Context-Aware Intelligence",
                        description: "Unlike basic transcription tools, Embr Echo adapts to where you are and what you're doing. Writing code? It uses technical models and syntax-aware prompts. Composing email? It switches to natural language. Automatic, seamless, intelligent.",
                        icon: "sparkles.square.fill.on.square",
                        accentColor: .purple
                    )

                    FeatureComparison(
                        title: "True Native macOS",
                        description: "Built with SwiftUI from the ground up. Not an Electron wrapper. Not a web app in disguise. Real menu bar integration. Real keyboard shortcuts. Real macOS design. It feels like it belongs because it does.",
                        icon: "apple.logo",
                        accentColor: .blue
                    )

                    FeatureComparison(
                        title: "AI Enhancement on Your Terms",
                        description: "Basic transcription is just the beginning. Transform your raw speech into polished prose, professional emails, or technical documentation—all with customizable AI prompts you control. Your voice, refined exactly how you want it.",
                        icon: "wand.and.stars",
                        accentColor: .orange
                    )

                    FeatureComparison(
                        title: "No Subscription Trap",
                        description: "Local models? Completely free after download. Cloud services? You bring your own API keys and pay only for what you use. No artificial limits. No monthly ransom. No surprise price hikes.",
                        icon: "dollarsign.circle.fill",
                        accentColor: .red
                    )
                }
            }

            Divider()

            // Philosophy
            VStack(alignment: .leading, spacing: 16) {
                Text("The Philosophy")
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Software should serve you, not surveil you.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Text("Tools should be powerful without being complex. Private without being paranoid. Beautiful without sacrificing function.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Embr Echo is for creators, thinkers, and builders who refuse to compromise. Who believe that convenience shouldn't cost privacy. Who want their tools to amplify their voice, not capture it.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider()

            // Links and info
            VStack(alignment: .leading, spacing: 16) {
                Text("Learn More")
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 12) {
                    LinkButton(title: "Documentation", url: "https://embr.sh/docs", icon: "book.fill")
                    LinkButton(title: "Tutorial Guide", url: "https://embr.sh/tutorial", icon: "graduationcap.fill")
                    LinkButton(title: "GitHub Repository", url: "https://github.com/vincenthopf/Voice", icon: "chevron.left.forwardslash.chevron.right")
                    LinkButton(title: "Report an Issue", url: "https://github.com/vincenthopf/Voice/issues", icon: "exclamationmark.triangle.fill")
                }
            }

            // Footer
            VStack(spacing: 12) {
                Text("Made with care for those who care about their privacy.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("© 2025 Embr Echo. Built with 🔥 on macOS.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 40)
    }
}

// MARK: - Feature Comparison Component
struct FeatureComparison: View {
    let title: String
    let description: String
    let icon: String
    let accentColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(accentColor)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
        }
    }
}

// MARK: - Link Button Component
struct LinkButton: View {
    let title: String
    let url: String
    let icon: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AboutView()
        .frame(width: 800, height: 700)
}
