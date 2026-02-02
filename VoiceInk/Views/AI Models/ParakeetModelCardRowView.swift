import SwiftUI
import Combine
import AppKit

struct ParakeetModelCardRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let model: ParakeetModel
    @ObservedObject var whisperState: WhisperState

    var isCurrent: Bool {
        whisperState.currentTranscriptionModel?.name == model.name
    }

    var isDownloaded: Bool {
        whisperState.isParakeetModelDownloaded(model)
    }

    var isDownloading: Bool {
        whisperState.isParakeetModelDownloading(model)
    }

    var body: some View {
        HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                headerSection
                metadataSection
                descriptionSection
                progressSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)

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
            } else if isDownloaded {
                Text("Downloaded")
                    .font(Tokens.Typography.labelSmall)
                    .padding(.horizontal, Tokens.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Tokens.Colors.border(for: colorScheme)))
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            }
        }
    }

    private var metadataSection: some View {
        HStack(spacing: Tokens.Spacing.md) {
            Label(model.language, systemImage: "globe")
            Label(model.size, systemImage: "internaldrive")
            HStack(spacing: 3) {
                Text("Speed")
                progressDotsWithNumber(value: model.speed * 10)
            }
            .fixedSize(horizontal: true, vertical: false)
            HStack(spacing: 3) {
                Text("Accuracy")
                progressDotsWithNumber(value: model.accuracy * 10)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .font(Tokens.Typography.caption)
        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
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

    private var progressSection: some View {
        Group {
            if isDownloading {
                let progress = whisperState.downloadProgress[model.name] ?? 0.0
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(Tokens.Colors.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Tokens.Spacing.sm)
            }
        }
    }

    private var actionSection: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            if isCurrent {
                Text("Default Model")
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
            } else if isDownloaded {
                Button(action: {
                    Task {
                        await whisperState.setDefaultTranscriptionModel(model)
                    }
                }) {
                    Text("Set as Default")
                        .font(Tokens.Typography.label)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(Tokens.Colors.orange)
            } else {
                Button(action: {
                    Task {
                        await whisperState.downloadParakeetModel(model)
                    }
                }) {
                    HStack(spacing: Tokens.Spacing.xs) {
                        Text(isDownloading ? "Downloading..." : "Download")
                        Image(systemName: "arrow.down.circle")
                    }
                    .font(Tokens.Typography.label)
                    .foregroundColor(.white)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(Capsule().fill(Tokens.Colors.orange))
                }
                .buttonStyle(.plain)
                .disabled(isDownloading)
            }

            if isDownloaded {
                Menu {
                    Button(action: {
                         whisperState.deleteParakeetModel(model)
                    }) {
                        Label("Delete Model", systemImage: "trash")
                    }

                    Button {
                        whisperState.showParakeetModelInFinder(model)
                    } label: {
                        Label("Show in Finder", systemImage: "folder")
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
}
