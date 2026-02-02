import SwiftUI
import AppKit
// MARK: - Local Model Card View
struct LocalModelCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let model: LocalModel
    let isDownloaded: Bool
    let isCurrent: Bool
    let downloadProgress: [String: Double]
    let modelURL: URL?
    let isWarming: Bool

    // Actions
    var deleteAction: () -> Void
    var setDefaultAction: () -> Void
    var downloadAction: () -> Void
    private var isDownloading: Bool {
        downloadProgress.keys.contains(model.name + "_main") ||
        downloadProgress.keys.contains(model.name + "_coreml")
    }

    var body: some View {
        HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
            // Main Content
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                headerSection
                metadataSection
                descriptionSection
                progressSection
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
            // Language
            Label(model.language, systemImage: "globe")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Size
            Label(model.size, systemImage: "internaldrive")
                .font(Tokens.Typography.caption)
                .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                .lineLimit(1)

            // Speed
            HStack(spacing: 3) {
                Text("Speed")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                progressDotsWithNumber(value: model.speed * 10)
            }
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)

            // Accuracy
            HStack(spacing: 3) {
                Text("Accuracy")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                progressDotsWithNumber(value: model.accuracy * 10)
            }
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
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
    
    private var progressSection: some View {
        Group {
            if isDownloading {
                DownloadProgressView(
                    modelName: model.name,
                    downloadProgress: downloadProgress
                )
                .padding(.top, Tokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                if isWarming {
                    HStack(spacing: Tokens.Spacing.sm) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Optimizing model for your device...")
                            .font(Tokens.Typography.label)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }
                } else {
                    Button(action: setDefaultAction) {
                        Text("Set as Default")
                            .font(Tokens.Typography.label)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(Tokens.Colors.orange)
                }
            } else {
                Button(action: downloadAction) {
                    HStack(spacing: Tokens.Spacing.xs) {
                        Text(isDownloading ? "Downloading..." : "Download")
                            .font(Tokens.Typography.label)
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Tokens.Colors.orange)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isDownloading)
            }

            if isDownloaded {
                Menu {
                    Button(action: deleteAction) {
                        Label("Delete Model", systemImage: "trash")
                    }

                    Button {
                        if let modelURL = modelURL {
                            NSWorkspace.shared.selectFile(modelURL.path, inFileViewerRootedAtPath: "")
                        }
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

// MARK: - Imported Local Model (minimal UI)
struct ImportedLocalModelCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let model: ImportedLocalModel
    let isDownloaded: Bool
    let isCurrent: Bool
    let modelURL: URL?

    var deleteAction: () -> Void
    var setDefaultAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Tokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.displayName)
                        .font(Tokens.Typography.bodyMedium)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                    if isCurrent {
                        Text("Default")
                            .font(Tokens.Typography.labelSmall)
                            .padding(.horizontal, Tokens.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Tokens.Colors.orange))
                            .foregroundColor(.white)
                    } else if isDownloaded {
                        Text("Imported")
                            .font(Tokens.Typography.labelSmall)
                            .padding(.horizontal, Tokens.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Tokens.Colors.border(for: colorScheme)))
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    }
                    Spacer()
                }

                Text("Imported local model")
                    .font(Tokens.Typography.caption)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Tokens.Spacing.xs)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Tokens.Spacing.sm) {
                if isCurrent {
                    Text("Default Model")
                        .font(Tokens.Typography.label)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                } else if isDownloaded {
                    Button(action: setDefaultAction) {
                        Text("Set as Default")
                            .font(Tokens.Typography.label)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(Tokens.Colors.orange)
                }

                if isDownloaded {
                    Menu {
                        Button(action: deleteAction) {
                            Label("Delete Model", systemImage: "trash")
                        }
                        Button {
                            if let modelURL = modelURL {
                                NSWorkspace.shared.selectFile(modelURL.path, inFileViewerRootedAtPath: "")
                            }
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
        .padding(Tokens.Spacing.lg)
        .background(isCurrent ? Tokens.Colors.orangeSoft(for: colorScheme) : Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(isCurrent ? Tokens.Colors.orange.opacity(0.5) : Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
    }
}


// MARK: - Helper Views and Functions

func progressDotsWithNumber(value: Double) -> some View {
    HStack(spacing: Tokens.Spacing.xs) {
        progressDots(value: value)
        Text(String(format: "%.1f", value))
            .font(Tokens.Typography.labelMono)
            .foregroundColor(Tokens.Colors.textSecondaryLight)
    }
}

func progressDots(value: Double) -> some View {
    HStack(spacing: 2) {
        ForEach(0..<5) { index in
            Circle()
                .fill(index < Int(value / 2) ? performanceColor(value: value / 10) : Tokens.Colors.borderLight)
                .frame(width: 6, height: 6)
        }
    }
}

func performanceColor(value: Double) -> Color {
    switch value {
    case 0.8...1.0: return Tokens.Colors.success
    case 0.6..<0.8: return Color(.systemYellow)
    case 0.4..<0.6: return Tokens.Colors.orange
    default: return Tokens.Colors.error
    }
}
