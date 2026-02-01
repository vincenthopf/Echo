import SwiftUI
import UniformTypeIdentifiers

/// Adaptive Intelligence settings for context-aware automation and customization
struct AdaptiveIntelligenceSettingsView: View {
    // Adaptive Awareness
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = false
    @AppStorage(PowerModeDefaults.autoRestoreKey) private var powerModeAutoRestoreEnabled = false
    @State private var showDisableAlert = false

    // Transformation Prompts
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @State private var isEditingPrompt = false
    @State private var selectedPromptForEdit: CustomPrompt?

    // Smart Corrections
    @StateObject private var whisperPrompt = WhisperPrompt()
    @State private var selectedDictionarySection: DictionarySection = .replacements

    enum DictionarySection: String, CaseIterable {
        case replacements = "Smart Corrections"
        case spellings = "Personal Vocabulary"

        var description: String {
            switch self {
            case .spellings:
                return "Add words to help Echo recognize them properly"
            case .replacements:
                return "Automatically replace specific words/phrases with custom formatted text"
            }
        }

        var icon: String {
            switch self {
            case .spellings:
                return "character.book.closed.fill"
            case .replacements:
                return "arrow.2.squarepath"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Adaptive Awareness Section
                SettingsSection(
                    icon: "sparkles.square.fill.on.square",
                    title: "Adaptive Awareness",
                    subtitle: "Automatically apply custom configurations based on context"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Main toggle and description
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Adaptive Awareness")
                                    .font(.headline)

                                Text("Automatically apply custom configurations based on the app or website you are using.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Toggle("Enable Adaptive Awareness", isOn: toggleBinding)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }

                        if powerModeUIFlag {
                            Divider()
                                .padding(.vertical, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))

                            HStack(spacing: 8) {
                                Toggle(isOn: $powerModeAutoRestoreEnabled) {
                                    Text("Auto-Restore Preferences")
                                }
                                .toggleStyle(.switch)

                                InfoTip(
                                    title: "Auto-Restore Preferences",
                                    message: "After each recording session, revert enhancement and transcription preferences to whatever was configured before Adaptive Awareness was activated."
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))

                            Divider()
                                .padding(.vertical, 4)

                            // How it Works - Now inside the same card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.accentColor)

                                    Text("How Adaptive Awareness Works")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }

                                Text("Adaptive Awareness monitors your active application and browser URLs to automatically apply pre-configured settings. Create rules to customize transcription models, AI enhancement prompts, and other preferences based on your context.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Examples:")
                                        .font(.caption)
                                        .fontWeight(.semibold)

                                    VStack(alignment: .leading, spacing: 4) {
                                        exampleRow(icon: "doc.text", text: "Use a formal writing prompt when in your word processor")
                                        exampleRow(icon: "envelope", text: "Apply email formatting when composing in Mail")
                                        exampleRow(icon: "safari", text: "Enable coding prompts when on GitHub or Stack Overflow")
                                        exampleRow(icon: "message", text: "Use casual tone when in messaging apps")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            .cornerRadius(8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: powerModeUIFlag)
                }

                // MARK: - Transformation Prompts Section
                SettingsSection(
                    icon: "wand.and.stars",
                    title: "Transformation Prompts",
                    subtitle: "Customize AI enhancement prompts"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Manage your custom transformation prompts for AI enhancement. These prompts can be automatically applied by Adaptive Awareness based on your context.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        // Reorderable prompts grid with drag-and-drop
                        ReorderablePromptGrid(
                            selectedPromptId: enhancementService.selectedPromptId,
                            onPromptSelected: { prompt in
                                enhancementService.setActivePrompt(prompt)
                            },
                            onEditPrompt: { prompt in
                                selectedPromptForEdit = prompt
                            },
                            onDeletePrompt: { prompt in
                                enhancementService.deletePrompt(prompt)
                            },
                            onAddNewPrompt: {
                                isEditingPrompt = true
                            }
                        )
                    }
                }

                // MARK: - Smart Corrections Section
                SettingsSection(
                    icon: "character.book.closed.fill",
                    title: "Smart Corrections",
                    subtitle: "Customize your personal vocabulary and replacements"
                ) {
                    VStack(spacing: 20) {
                        // Section Selector
                        HStack(spacing: 20) {
                            ForEach(DictionarySection.allCases, id: \.self) { section in
                                DictionarySectionCard(
                                    section: section,
                                    isSelected: selectedDictionarySection == section,
                                    action: { selectedDictionarySection = section }
                                )
                            }
                        }

                        Divider()

                        // Selected Section Content
                        switch selectedDictionarySection {
                        case .spellings:
                            DictionaryView(whisperPrompt: whisperPrompt)
                        case .replacements:
                            WordReplacementView()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $isEditingPrompt) {
            PromptEditorView(mode: .add)
        }
        .sheet(item: $selectedPromptForEdit) { prompt in
            PromptEditorView(mode: .edit(prompt))
        }
        .alert("Adaptive Awareness Still Active", isPresented: $showDisableAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Adaptive Awareness can't be disabled while any configuration is still enabled. Disable or remove your configurations first.")
        }
    }

    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { powerModeUIFlag },
            set: { newValue in
                if newValue {
                    powerModeUIFlag = true
                } else if powerModeManager.configurations.noneEnabled {
                    powerModeUIFlag = false
                } else {
                    showDisableAlert = true
                }
            }
        )
    }

    private func exampleRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 16)
                .font(.caption)
            Text(text)
        }
    }
}

// MARK: - Dictionary Section Card
private struct DictionarySectionCard: View {
    let section: AdaptiveIntelligenceSettingsView.DictionarySection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.headline)

                    Text(section.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(CardBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Drag & Drop Reorderable Grid
private struct ReorderablePromptGrid: View {
    @EnvironmentObject private var enhancementService: AIEnhancementService

    let selectedPromptId: UUID?
    let onPromptSelected: (CustomPrompt) -> Void
    let onEditPrompt: ((CustomPrompt) -> Void)?
    let onDeletePrompt: ((CustomPrompt) -> Void)?
    let onAddNewPrompt: (() -> Void)?

    @State private var draggingItem: CustomPrompt?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if enhancementService.customPrompts.isEmpty {
                Text("No prompts available")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                let columns = [
                    GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 36)
                ]

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(enhancementService.customPrompts) { prompt in
                        prompt.promptIcon(
                            isSelected: selectedPromptId == prompt.id,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    onPromptSelected(prompt)
                                }
                            },
                            onEdit: onEditPrompt,
                            onDelete: onDeletePrompt
                        )
                        .opacity(draggingItem?.id == prompt.id ? 0.3 : 1.0)
                        .scaleEffect(draggingItem?.id == prompt.id ? 1.05 : 1.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    draggingItem != nil && draggingItem?.id != prompt.id
                                    ? Color.accentColor.opacity(0.25)
                                    : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .animation(.easeInOut(duration: 0.15), value: draggingItem?.id == prompt.id)
                        .onDrag {
                            draggingItem = prompt
                            return NSItemProvider(object: prompt.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [UTType.text],
                            delegate: PromptDropDelegate(
                                item: prompt,
                                prompts: $enhancementService.customPrompts,
                                draggingItem: $draggingItem
                            )
                        )
                    }

                    if let onAddNewPrompt = onAddNewPrompt {
                        CustomPrompt.addNewButton {
                            onAddNewPrompt()
                        }
                        .help("Add new prompt")
                        .onDrop(
                            of: [UTType.text],
                            delegate: PromptEndDropDelegate(
                                prompts: $enhancementService.customPrompts,
                                draggingItem: $draggingItem
                            )
                        )
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)

                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Double-click to edit • Right-click for more options")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Drop Delegates
private struct PromptDropDelegate: DropDelegate {
    let item: CustomPrompt
    @Binding var prompts: [CustomPrompt]
    @Binding var draggingItem: CustomPrompt?

    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem, draggingItem != item else { return }
        guard let fromIndex = prompts.firstIndex(of: draggingItem),
              let toIndex = prompts.firstIndex(of: item) else { return }

        // Move item as you hover for immediate visual update
        if prompts[toIndex].id != draggingItem.id {
            withAnimation(.easeInOut(duration: 0.12)) {
                let from = fromIndex
                let to = toIndex
                prompts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }
}

private struct PromptEndDropDelegate: DropDelegate {
    @Binding var prompts: [CustomPrompt]
    @Binding var draggingItem: CustomPrompt?

    func validateDrop(info: DropInfo) -> Bool { true }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggingItem = draggingItem,
              let currentIndex = prompts.firstIndex(of: draggingItem) else {
            self.draggingItem = nil
            return false
        }

        // Move to end if dropped on the trailing "Add New" tile
        withAnimation(.easeInOut(duration: 0.12)) {
            prompts.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: prompts.endIndex)
        }
        self.draggingItem = nil
        return true
    }
}

private extension Array where Element == PowerModeConfig {
    var noneEnabled: Bool {
        allSatisfy { !$0.isEnabled }
    }
}
