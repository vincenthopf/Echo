import SwiftUI
import SwiftData
import KeyboardShortcuts

// ViewType enum with all cases (settings-related items moved to Settings window)
enum ViewType: String, CaseIterable {
    case metrics = "Dashboard"
    case transcribeAudio = "Transcribe Files"
    case powerMode = "Adaptive Awareness"
    case vocabulary = "Vocabulary"
    case history = "History"
    case settings = "Settings"
    case about = "About"

    var icon: String {
        switch self {
        case .metrics: return "gauge.medium"
        case .transcribeAudio: return "waveform.circle.fill"
        case .powerMode: return "sparkles.square.fill.on.square"
        case .vocabulary: return "text.book.closed.fill"
        case .history: return "doc.text.fill"
        case .settings: return "gear"
        case .about: return "info.circle.fill"
        }
    }
}

struct DynamicSidebar: View {
    @Binding var selectedView: ViewType
    @Binding var hoveredView: ViewType?
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = true
    @Namespace private var buttonAnimation
    
    private var visibleViewTypes: [ViewType] {
        // Always show all view types (Adaptive Awareness is now primary UI)
        return ViewType.allCases
    }

    var body: some View {
        VStack(spacing: 15) {
            // App Header
            HStack(spacing: 6) {
                if let appIcon = NSImage(named: "AppIcon") {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .cornerRadius(8)
                }
                
                Text("Echo")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Navigation Items
            ForEach(visibleViewTypes, id: \.self) { viewType in
                DynamicSidebarButton(
                    title: viewType.rawValue,
                    systemImage: viewType.icon,
                    isSelected: selectedView == viewType,
                    isHovered: hoveredView == viewType,
                    namespace: buttonAnimation
                ) {
                    selectedView = viewType
                }
                .onHover { isHovered in
                    hoveredView = isHovered ? viewType : nil
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ParallelDesignTokens.Colors.background(for: colorScheme))
    }
}

struct DynamicSidebarButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let isHovered: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Text/icon color based on selection and color scheme
    private var foregroundColor: Color {
        if isSelected {
            return colorScheme == .dark ? .white : ParallelDesignTokens.Colors.primaryOrange
        } else if isHovered {
            return ParallelDesignTokens.Colors.primaryOrange
        } else {
            return ParallelDesignTokens.Colors.primaryText(for: colorScheme)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Left vertical accent bar for selected state
                RoundedRectangle(cornerRadius: 2)
                    .fill(isSelected ? ParallelDesignTokens.Colors.primaryOrange : Color.clear)
                    .frame(width: 4)
                    .padding(.vertical, 8)

                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 24, height: 24)

                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, 12)
            }
            .foregroundColor(foregroundColor)
            .frame(height: 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Group {
                    if isHovered && !isSelected {
                        RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.medium)
                            .fill(ParallelDesignTokens.Colors.hoverBackground(for: colorScheme))
                    }
                }
            )
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = true
    @State private var selectedView: ViewType = .metrics
    @State private var hoveredView: ViewType?
    @State private var hasLoadedData = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"


    private var isSetupComplete: Bool {
        hasLoadedData &&
        whisperState.currentTranscriptionModel != nil &&
        hotkeyManager.selectedHotkey1 != .none &&
        AXIsProcessTrusted() &&
        CGPreflightScreenCaptureAccess()
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            DynamicSidebar(
                selectedView: $selectedView,
                hoveredView: $hoveredView
            )
            .frame(width: 240)
            .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 300)
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("")
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1100, minHeight: 850)
        .onAppear {
            hasLoadedData = true
        }
        // inside ContentView body:
        .onReceive(NotificationCenter.default.publisher(for: .toggleSidebar)) { _ in
            columnVisibility = columnVisibility == .all ? .detailOnly : .all
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToDestination)) { notification in
            if let destination = notification.userInfo?["destination"] as? String {
                switch destination {
                case "History":
                    selectedView = .history
                case "Transcribe Files", "Transcribe Audio":
                    selectedView = .transcribeAudio
                case "Power Mode", "Adaptive Awareness":
                    selectedView = .powerMode
                case "Vocabulary", "Dictionary", "Smart Corrections":
                    selectedView = .vocabulary
                case "Settings":
                    selectedView = .settings
                default:
                    break
                }
            }
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedView {
        case .metrics:
            if isSetupComplete {
                MetricsView(skipSetupCheck: true)
            } else {
                MetricsSetupView()
                    .environmentObject(hotkeyManager)
            }
        case .transcribeAudio:
            AudioTranscribeView()
        case .history:
            TranscriptionHistoryView()
        case .powerMode:
            AdaptiveAwarenessView()
        case .vocabulary:
            VocabularyPane()
        case .settings:
            SettingsWindowView()
        case .about:
            AboutView()
        }
    }
}

 
