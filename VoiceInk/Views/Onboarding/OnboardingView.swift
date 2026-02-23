import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var hasCompletedOnboarding: Bool
    @State private var textOpacity: CGFloat = 0
    @State private var showSecondaryElements = false
    @State private var showPermissions = false
    private let launchArguments = ProcessInfo.processInfo.arguments

    // Animation timing
    private let animationDelay = 0.2
    private let textAnimationDuration = 0.6

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // Clean solid background using design tokens
                    ParallelDesignTokens.Colors.background(for: colorScheme)
                        .ignoresSafeArea()

                    // Content container
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Content Area
                            VStack(spacing: 60) {
                                Spacer()
                                    .frame(height: 40)

                                // Title and subtitle
                                VStack(spacing: 16) {
                                    Text("Welcome to the Future of Typing")
                                        .font(.system(size: min(geometry.size.width * 0.055, 42), weight: .bold, design: .rounded))
                                        .foregroundColor(ParallelDesignTokens.Colors.primaryText(for: colorScheme))
                                        .opacity(textOpacity)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)

                                    Text("A New Way to Type")
                                        .font(.system(size: min(geometry.size.width * 0.032, 24), weight: .medium, design: .rounded))
                                        .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme))
                                        .opacity(textOpacity)
                                        .multilineTextAlignment(.center)
                                }

                                if showSecondaryElements {
                                    // Typewriter roles animation
                                    TypewriterRoles(colorScheme: colorScheme)
                                        .frame(height: 160)
                                        .transition(.scale.combined(with: .opacity))
                                        .padding(.horizontal, 40)
                                }
                            }
                            .padding(.top, geometry.size.height * 0.15)

                            Spacer(minLength: geometry.size.height * 0.2)

                            // Bottom navigation
                            if showSecondaryElements {
                                VStack(spacing: 20) {
                                    Button(action: {
                                        AnalyticsService.shared.track("onboarding_started")
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            showPermissions = true
                                        }
                                    }) {
                                        Text("Start Quick Setup")
                                            .font(ParallelDesignTokens.Typography.heading3)
                                            .foregroundColor(.white)
                                            .frame(width: min(geometry.size.width * 0.3, 200), height: 50)
                                            .background(
                                                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.large)
                                                    .fill(ParallelDesignTokens.Colors.primaryOrange)
                                            )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                    .accessibilityIdentifier("onboarding.startQuickSetup")

                                    SkipButton(text: "Skip Tour", colorScheme: colorScheme) {
                                        AnalyticsService.shared.track("onboarding_skipped")
                                        hasCompletedOnboarding = true
                                    }
                                }
                                .padding(.bottom, 35)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                }
            }

            if showPermissions {
                OnboardingPermissionsView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        if launchArguments.contains("-uiTestSkipOnboardingIntro") {
            textOpacity = 1
            showSecondaryElements = true
            showPermissions = launchArguments.contains("-uiTestStartQuickSetup")
            return
        }

        // Text fade in
        withAnimation(.easeOut(duration: textAnimationDuration).delay(animationDelay)) {
            textOpacity = 1
        }

        // Show secondary elements
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay * 3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSecondaryElements = true
            }
        }
    }
}

// MARK: - Supporting Views
struct TypewriterRoles: View {
    let colorScheme: ColorScheme

    private let roles = [
        "Your Writing Assistant",
        "Your Vibe-Coding Assistant",
        "Works Everywhere on Mac with a click",
        "100% offline & private",

    ]

    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var showCursor = true
    @State private var isTyping = false
    @State private var isDeleting = false

    // Animation timing
    private let typingSpeed = 0.05  // Time between each character
    private let deleteSpeed = 0.03   // Faster deletion
    private let pauseDuration = 1.0  // How long to show completed text
    private let cursorBlinkSpeed = 0.6

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text(displayedText)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(ParallelDesignTokens.Colors.primaryOrange)

                // Blinking cursor
                Text("|")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(ParallelDesignTokens.Colors.primaryOrange)
                    .opacity(showCursor ? 1 : 0)
                    .animation(.easeInOut(duration: cursorBlinkSpeed).repeatForever(), value: showCursor)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            startTypingAnimation()
            // Start cursor blinking
            withAnimation(.easeInOut(duration: cursorBlinkSpeed).repeatForever()) {
                showCursor.toggle()
            }
        }
    }
    
    private func startTypingAnimation() {
        guard currentIndex < roles.count else { return }
        let targetText = roles[currentIndex]
        isTyping = true
        
        // Type out the text
        var charIndex = 0
        func typeNextCharacter() {
            guard charIndex < targetText.count else {
                // Typing complete, pause then delete
                isTyping = false
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    startDeletingAnimation()
                }
                return
            }
            
            let nextChar = String(targetText[targetText.index(targetText.startIndex, offsetBy: charIndex)])
            displayedText += nextChar
            charIndex += 1
            
            // Schedule next character
            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
                typeNextCharacter()
            }
        }
        
        typeNextCharacter()
    }
    
    private func startDeletingAnimation() {
        isDeleting = true
        
        func deleteNextCharacter() {
            guard !displayedText.isEmpty else {
                isDeleting = false
                currentIndex = (currentIndex + 1) % roles.count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    startTypingAnimation()
                }
                return
            }
            
            displayedText.removeLast()
            
            // Schedule next deletion
            DispatchQueue.main.asyncAfter(deadline: .now() + deleteSpeed) {
                deleteNextCharacter()
            }
        }
        
        deleteNextCharacter()
    }
}

struct SkipButton: View {
    let text: String
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Text(text)
            .font(ParallelDesignTokens.Typography.bodySmall)
            .foregroundColor(ParallelDesignTokens.Colors.secondaryText(for: colorScheme).opacity(0.6))
            .onTapGesture(perform: action)
    }
}

struct OnboardingBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        // Clean solid background - no heavy gradients or particle effects
        ParallelDesignTokens.Colors.background(for: colorScheme)
            .ignoresSafeArea()
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 
