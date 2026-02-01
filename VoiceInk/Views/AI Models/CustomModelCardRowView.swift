import SwiftUI
import AppKit

// MARK: - Custom Model Card View
struct CustomModelCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let model: CustomCloudModel
    let isCurrent: Bool
    var setDefaultAction: () -> Void
    var deleteAction: () -> Void
    var editAction: (CustomCloudModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content
            HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                    headerSection
                    metadataSection
                    descriptionSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                actionSection
            }
            .padding(Tokens.Spacing.lg)
        }
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
                Text("Custom")
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
            // Provider
            Label("Custom Provider", systemImage: "cloud")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Language
            Label(model.language, systemImage: "globe")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // OpenAI Compatible
            Label("OpenAI Compatible", systemImage: "checkmark.seal")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)
        }
        .lineLimit(1)
    }

    private var descriptionSection: some View {
        Text(model.description)
            .font(Tokens.Typography.caption)
            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, Tokens.Spacing.xs)
    }

    private var actionSection: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            if isCurrent {
                Text("Default Model")
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
            }

            Menu {
                Button {
                    editAction(model)
                } label: {
                    Label("Edit Model", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    deleteAction()
                } label: {
                    Label("Delete Model", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 20, height: 20)
        }
    }
}
