import SwiftUI

/// Onboarding sheet introducing new users to the Adaptive Awareness feature
/// Explains how to create context-aware transcription profiles
struct AdaptiveAwarenessMigrationSheet: View {
    @Binding var isPresented: Bool
    @State private var contentOpacity: CGFloat = 0
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with icon
                VStack(spacing: 24) {
                    // Animated icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.2),
                                        Color.accentColor.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: "sparkles.square.fill.on.square")
                            .font(.system(size: 48, weight: .regular))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor,
                                        Color.accentColor.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(iconScale)
                    .padding(.top, 32)

                    // Title
                    Text("Adaptive Awareness")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    // Subtitle
                    Text("Your transcriptions adapt to what you're doing, automatically.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .opacity(contentOpacity)

                Spacer()
                    .frame(height: 40)

                // Feature cards
                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "square.stack.3d.up",
                        title: "Create Your First Profile",
                        description: "Set up profiles for different situations like writing emails, coding, or taking notes. Each one can use a different transcription model, language, or AI enhancement."
                    )

                    FeatureCard(
                        icon: "slider.horizontal.3",
                        title: "Profiles Switch Automatically",
                        description: "Your profiles adapt based on what you're doing. Open your email app, and your Email profile kicks in. Switch to your browser, and a different profile takes over. You can also speak a keyword to instantly switch profiles with your voice."
                    )

                    FeatureCard(
                        icon: "lightbulb",
                        title: "Customize Every Detail",
                        description: "Choose which transcription model to use, set the language, add AI enhancement prompts, and control whether transcriptions auto-send. Each profile remembers your preferences so you don't have to adjust settings every time."
                    )
                }
                .padding(.horizontal, 16)
                .opacity(contentOpacity)

                Spacer()
                    .frame(height: 32)

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                        // Mark as seen (used for both migration and onboarding)
                        UserDefaults.standard.set(true, forKey: "hasSeenAdaptiveAwarenessMigration")
                    }) {
                        Text("Got It")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 300)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut(.defaultAction)

                    Button(action: {
                        // Open documentation
                        if let url = URL(string: "https://vjh.io/embr-echo-help") {
                            NSWorkspace.shared.open(url)
                        }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                        UserDefaults.standard.set(true, forKey: "hasSeenAdaptiveAwarenessMigration")
                    }) {
                        Text("Learn More")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .opacity(contentOpacity)
                .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
        }
        .frame(width: 540, height: 640)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Icon scale animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale = 1.0
        }

        // Content fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            contentOpacity = 1.0
        }
    }
}

// MARK: - Supporting Views

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.accentColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    AdaptiveAwarenessMigrationSheet(isPresented: .constant(true))
}
