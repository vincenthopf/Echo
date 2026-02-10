import SwiftUI
import AppKit

// MARK: - Native Apple Model Card View
struct NativeAppleModelCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let model: NativeAppleModel
    let isCurrent: Bool
    let isSupported: Bool
    var setDefaultAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
            // Main Content
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                headerSection
                metadataSection
                descriptionSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Action Controls
            actionSection
        }
        .padding(Tokens.Spacing.lg)
        .background(isCurrent ? Tokens.Colors.orangeSoft(for: colorScheme) : Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(isCurrent ? Tokens.Colors.orange.opacity(0.5) : Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }

    private var headerSection: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(model.displayName)
                .font(Tokens.Typography.bodyMedium)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

            statusBadge

            Spacer()
        }
    }

    private var statusBadge: some View {
        Group {
            if isCurrent {
                Text("Default")
                    .font(Tokens.Typography.labelSmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Tokens.Colors.orange))
                    .foregroundColor(.white)
            } else {
                Text("Built-in")
                    .font(Tokens.Typography.labelSmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Tokens.Colors.orangeMedium(for: colorScheme)))
                    .foregroundColor(Tokens.Colors.orange)
            }
        }
    }

    private var metadataSection: some View {
        HStack(spacing: Tokens.Spacing.md) {
            // Native Apple
            Label("Native Apple", systemImage: "apple.logo")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Language
            Label(model.language, systemImage: "globe")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // On-Device
            Label("On-Device", systemImage: "checkmark.shield")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Requires macOS 26+
            Label("macOS 26+", systemImage: "macbook")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)
        }
        .lineLimit(1)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
            Text(model.description)
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if !isSupported {
                Text("Unavailable on this macOS version")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.error)
            }
        }
        .padding(.top, Tokens.Spacing.xs)
    }

    private var actionSection: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            if isCurrent {
                Text("Default Model")
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            } else if !isSupported {
                Text("Not Supported")
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            } else {
                Button(action: setDefaultAction) {
                    Text("Set as Default")
                        .font(Tokens.Typography.label)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(Tokens.Colors.orange)
                .disabled(!isSupported)
            }
        }
    }
} 
