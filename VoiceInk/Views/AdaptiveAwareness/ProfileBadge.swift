import SwiftUI

/// Reusable badge component for displaying active profile status
/// Configurable size for different contexts (tiny for notch, small for mini, medium for settings)
struct ProfileBadge: View {
    let emoji: String
    let name: String
    let activationSource: ActivationSource?
    let size: BadgeSize
    let showName: Bool

    enum BadgeSize {
        case tiny       // 16pt - for notch recorder
        case small      // 20pt - for mini recorder
        case medium     // 28pt - for settings

        var emojiSize: CGFloat {
            switch self {
            case .tiny: return 10
            case .small: return 13
            case .medium: return 18
            }
        }

        var containerSize: CGFloat {
            switch self {
            case .tiny: return 16
            case .small: return 20
            case .medium: return 28
            }
        }
    }

    init(emoji: String, name: String, activationSource: ActivationSource? = nil, size: BadgeSize = .small, showName: Bool = false) {
        self.emoji = emoji
        self.name = name
        self.activationSource = activationSource
        self.size = size
        self.showName = showName
    }

    private var tooltipText: String {
        var text = name
        if let source = activationSource {
            text += " - \(source.statusString())"
        }
        return text
    }

    var body: some View {
        HStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: size.containerSize, height: size.containerSize)

                Text(emoji)
                    .font(.system(size: size.emojiSize))
            }

            if showName {
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let source = activationSource {
                        Text(source.statusString())
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .help(tooltipText)
    }
}

/// Profile badge specifically for menu bar display
struct MenuBarProfileBadge: View {
    let config: PowerModeConfig?
    let activationSource: ActivationSource?

    var body: some View {
        if let config = config {
            HStack(spacing: 6) {
                Text(config.emoji)
                    .font(.system(size: 12))

                VStack(alignment: .leading, spacing: 1) {
                    Text(config.name)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)

                    if let source = activationSource {
                        Text(source.statusString())
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        } else {
            Text("No Active Profile")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

/// Compact badge for recorder windows with hover tooltip
struct RecorderProfileBadge: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @ObservedObject private var sessionManager = PowerModeSessionManager.shared
    let size: ProfileBadge.BadgeSize

    var body: some View {
        if let config = powerModeManager.activeConfiguration {
            ProfileBadge(
                emoji: config.emoji,
                name: config.name,
                activationSource: sessionManager.activationSource,
                size: size,
                showName: false
            )
        } else {
            EmptyView()
        }
    }
}
