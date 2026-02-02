import SwiftUI

struct ExperimentalFeaturesSection: View {
    @AppStorage("isExperimentalFeaturesEnabled") private var isExperimentalFeaturesEnabled = false
    @ObservedObject private var playbackController = PlaybackController.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "Experimental Features",
                subtitle: "Features that might be unstable or buggy"
            )

            VStack(spacing: 0) {
                // Enable experimental features row
                FormRow(label: "Enable") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: $isExperimentalFeaturesEnabled)
                            .toggleStyle(.switch)
                            .tint(Tokens.Colors.orange)
                            .labelsHidden()
                            .onChange(of: isExperimentalFeaturesEnabled) { _, newValue in
                                if !newValue {
                                    playbackController.isPauseMediaEnabled = false
                                }
                            }

                        Text("Enable experimental features")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        Spacer()
                    }
                }

                if isExperimentalFeaturesEnabled {
                    FormDivider()
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    // Pause media row
                    FormRow(label: "Media") {
                        HStack(spacing: Tokens.Spacing.sm) {
                            Toggle("", isOn: $playbackController.isPauseMediaEnabled)
                                .toggleStyle(.switch)
                                .tint(Tokens.Colors.orange)
                                .labelsHidden()

                            Text("Pause media during recording")
                                .font(Tokens.Typography.bodySmall)
                                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                            Spacer()
                        }
                    }
                    .help("Automatically pause active media playback during recordings and resume afterward.")
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.3), value: isExperimentalFeaturesEnabled)
    }
}
