import SwiftUI

/// About page showcasing Echo's philosophy and capabilities
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
                Text("Echo")
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
            // What You Can Do
            VStack(alignment: .leading, spacing: 16) {
                Text("Speak naturally. Work faster.")
                    .font(.system(size: 24, weight: .bold))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Turn your voice into text instantly. Echo transcribes everything you say with remarkable accuracy—right on your Mac.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Work in any app. Write emails, draft documents, or capture ideas without touching your keyboard. Just press your hotkey and start speaking.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Your words stay private. Everything runs on your Mac—no servers, no cloud processing, no one listening. Unless you choose otherwise.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider()

            // What Makes Echo Different
            VStack(alignment: .leading, spacing: 20) {
                Text("What you can do with Echo")
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 20) {
                    FeatureComparison(
                        title: "Keep your voice private",
                        description: "Choose local transcription and your audio never leaves your Mac. No servers. No cloud processing. No compromise. Or select cloud services when you need them—it's always your choice.",
                        icon: "lock.shield.fill",
                        accentColor: .green
                    )

                    FeatureComparison(
                        title: "Adapt to any task",
                        description: "Echo knows what you're working on and adjusts automatically. Writing code? You'll get technical accuracy. Drafting an email? Natural language flows in. Context-aware transcription that thinks ahead.",
                        icon: "sparkles.square.fill.on.square",
                        accentColor: .purple
                    )

                    FeatureComparison(
                        title: "Work anywhere on your Mac",
                        description: "Native macOS design that feels right at home. Quick access from your menu bar, global hotkeys that work everywhere, and interface elements that follow your system's appearance. It's part of your Mac.",
                        icon: "apple.logo",
                        accentColor: .blue
                    )

                    FeatureComparison(
                        title: "Refine with AI",
                        description: "Go beyond basic transcription. Polish your words into professional emails, clean up technical documentation, or transform rough thoughts into clear writing—all with AI prompts you customize.",
                        icon: "wand.and.stars",
                        accentColor: .orange
                    )

                    FeatureComparison(
                        title: "Pay only for what you use",
                        description: "Download local models for free. Connect your own API keys for cloud services. No subscriptions. No monthly fees. No surprises.",
                        icon: "dollarsign.circle.fill",
                        accentColor: .red
                    )
                }
            }

            Divider()

            // How It Works
            VStack(alignment: .leading, spacing: 16) {
                Text("Built for how you work")
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Press your hotkey. Start speaking. See your words appear.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Text("Echo runs advanced AI models right on your Mac—no internet required. Choose from multiple transcription engines, each optimized for different needs. Switch between them anytime.")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Set it up once and forget about it. Echo learns your workflow, remembers your preferences, and stays out of your way until you need it.")
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
                    LinkButton(title: "Documentation", url: "https://vjh.io/embr-echo-docs", icon: "book.fill")
                    LinkButton(title: "Tutorial Guide", url: "https://vjh.io/embr-echo-docs", icon: "graduationcap.fill")
                }
            }

            // Footer
            VStack(spacing: 12) {
                Text("Designed for privacy. Built for speed. Made for macOS.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("© 2025 Echo")
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
