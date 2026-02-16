import SwiftUI

/// About page showcasing Echo's philosophy and capabilities
struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme
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
        .background(Tokens.Colors.background(for: colorScheme))
    }

    private var heroSection: some View {
        VStack(spacing: Tokens.Spacing.xl) {
            // App icon
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(26)
            }

            VStack(spacing: Tokens.Spacing.sm) {
                Text("Echo")
                    .font(Tokens.Typography.displayMedium)
                    .fontWeight(.bold)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Text("Version \(appVersion)")
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Tokens.Spacing.xxxl)
        .background(Tokens.Colors.elevated(for: colorScheme))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Tokens.Colors.border(for: colorScheme)),
            alignment: .bottom
        )
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xxl) {
            // What You Can Do
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                Text("Speak naturally. Work faster.")
                    .font(Tokens.Typography.heading1)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                    Text("Turn your voice into text instantly. Echo transcribes everything you say with remarkable accuracy. Right on your Mac.")
                        .font(Tokens.Typography.bodyLarge)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Your words stay private. No servers, cloud processing, or sneaky companies listening. Unless you choose otherwise.")
                        .font(Tokens.Typography.bodyLarge)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider()
                .background(Tokens.Colors.border(for: colorScheme))

            // What Makes Echo Different
            VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                Text("What you can do with Echo")
                    .font(Tokens.Typography.heading2)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                    FeatureComparison(
                        title: "Keep your voice private",
                        description: "Choose local transcription and your audio never leaves your Mac. No servers or cloud processing. Or select cloud services when you need them. It's always your choice.",
                        icon: "lock.shield.fill",
                        accentColor: .blue
                    )

                    FeatureComparison(
                        title: "Adapt to any task",
                        description: "Echo knows what you're working on and adapts accordingly. Writing code? Get technical accuracy. Drafting an email? Natural language flows in. Context aware transcription that thinks ahead.",
                        icon: "sparkles.square.fill.on.square",
                        accentColor: Tokens.Colors.orange
                    )

                    FeatureComparison(
                        title: "Work anywhere on your Mac",
                        description: "Native macOS design that feels right at home. Quick access from your menu bar, global hotkeys that work everywhere, and interface elements that follow your system's appearance. It's part of your Mac.",
                        icon: "apple.logo",
                        accentColor: .blue
                    )

                    FeatureComparison(
                        title: "Refine with AI",
                        description: "Go beyond basic transcription. Polish your words into professional emails, clean up technical documentation, or transform rough thoughts into clear writing. Configured by you!",
                        icon: "wand.and.stars",
                        accentColor: Tokens.Colors.orange
                    )

                    FeatureComparison(
                        title: "Pay only for what you use",
                        description: "Download local models for free or connect your own API keys for cloud services. No extra subscriptions, monthly fees or nastry surprises.",
                        icon: "dollarsign.circle.fill",
                        accentColor: .blue
                    )
                }
            }

            // Links and info
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                Text("Learn More")
                    .font(Tokens.Typography.heading2)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                    LinkButton(title: "support", url: "https://echo.vjh.io/docs/troubleshooting", icon: "book.fill")
                    LinkButton(title: "Tutorial Guide", url: "https://echo.vjh.io/docs", icon: "graduationcap.fill")
                }
            }

            // Footer
            VStack(spacing: Tokens.Spacing.md) {
                Text("Made with love by Vince.")
                    .font(Tokens.Typography.bodySmall)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text("2025 Echo")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Tokens.Spacing.xxl)
        }
        .padding(.horizontal, 60)
        .padding(.vertical, Tokens.Spacing.xxl)
    }
}

// MARK: - Feature Comparison Component
struct FeatureComparison: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let description: String
    let icon: String
    let accentColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(accentColor)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                        .fill(accentColor.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                Text(title)
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Text(description)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
        }
    }
}

// MARK: - Link Button Component
struct LinkButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let url: String
    let icon: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        }) {
            HStack(spacing: Tokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.orange)
                    .frame(width: 20)

                Text(title)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
            .padding(.horizontal, Tokens.Spacing.md)
            .padding(.vertical, Tokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .fill(Tokens.Colors.elevated(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AboutView()
        .frame(width: 800, height: 700)
}

#Preview("Compact Size") {
    AboutView()
        .frame(width: 600, height: 500)
}

#Preview("Dark Mode") {
    AboutView()
        .frame(width: 800, height: 700)
        .preferredColorScheme(.dark)
}
