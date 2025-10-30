import SwiftUI

/// One-time migration notice shown after updating to the unified Adaptive Awareness system
/// Explains the consolidation of Power Modes and Prompts into a single feature
struct AdaptiveAwarenessMigrationSheet: View {
    @Binding var isPresented: Bool
    @State private var contentOpacity: CGFloat = 0
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

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
                    .padding(.top, 48)

                    // Title
                    Text("Introducing Unified Adaptive Awareness")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    // Subtitle
                    Text("Smarter. Simpler. More Powerful.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .opacity(contentOpacity)

                Spacer()
                    .frame(height: 40)

                // Feature cards
                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "square.stack.3d.up",
                        title: "Everything in One Place",
                        description: "Power Modes and Prompts with Trigger Words are now unified under Adaptive Awareness"
                    )

                    FeatureCard(
                        icon: "slider.horizontal.3",
                        title: "Flexible Triggers",
                        description: "Configure apps, websites, AND voice keywords in a single profile"
                    )

                    FeatureCard(
                        icon: "checkmark.shield",
                        title: "Nothing Lost",
                        description: "All your existing settings have been preserved and migrated automatically"
                    )
                }
                .padding(.horizontal, 48)
                .opacity(contentOpacity)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                        // Mark as seen
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
                .padding(.bottom, 32)
            }
            .frame(width: 540, height: 640)
        }
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
    }
}

// MARK: - Preview

#Preview {
    AdaptiveAwarenessMigrationSheet(isPresented: .constant(true))
}
