import SwiftUI
import UniformTypeIdentifiers

struct EnhancementSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService
    @State private var isEditingPrompt = false
    @State private var isSettingsExpanded = true
    @State private var selectedPromptForEdit: CustomPrompt?

    var body: some View {
        ScrollView {
            VStack(spacing: Tokens.Spacing.xxl) {
                // Main Settings Sections
                VStack(spacing: Tokens.Spacing.xl) {
                    // Enable/Disable Toggle Section
                    VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                HStack {
                                    Text("Enable Transformation")
                                        .font(Tokens.Typography.heading3)
                                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                                    InfoTip(
                                        title: "Intelligent Transformation",
                                        message: "Intelligent transformation lets you pass the transcribed audio through LLMs to post-process using different prompts suitable for different use cases like e-mails, summary, writing, etc.",
                                        learnMoreURL: "https://vjh.io/embr-echo-docs"
                                    )
                                }

                                Text("Turn on AI-powered transformation features")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                            }

                            Spacer()

                            Toggle("", isOn: $enhancementService.isEnhancementEnabled)
                                .toggleStyle(SwitchToggleStyle())
                                .tint(Tokens.Colors.orange)
                                .labelsHidden()
                                .scaleEffect(1.2)
                        }

                        HStack(spacing: Tokens.Spacing.xl) {
                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                Toggle("Clipboard Context", isOn: $enhancementService.useClipboardContext)
                                    .toggleStyle(.switch)
                                    .tint(Tokens.Colors.orange)
                                    .disabled(!enhancementService.isEnhancementEnabled)
                                Text("Use text from clipboard to understand the context")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(enhancementService.isEnhancementEnabled ? Tokens.Colors.textSecondary(for: colorScheme) : Tokens.Colors.textTertiary(for: colorScheme))
                            }

                            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                                HStack {
                                    Toggle("Context Awareness", isOn: $enhancementService.useScreenCaptureContext)
                                        .toggleStyle(.switch)
                                        .tint(Tokens.Colors.orange)
                                        .disabled(!enhancementService.isEnhancementEnabled)

                                    if enhancementService.useScreenCaptureContext {
                                        ScreenCaptureModeIndicator(aiService: aiService, colorScheme: colorScheme)
                                    }
                                }
                                Text("Learn what is on the screen to understand the context")
                                    .font(Tokens.Typography.caption)
                                    .foregroundColor(enhancementService.isEnhancementEnabled ? Tokens.Colors.textSecondary(for: colorScheme) : Tokens.Colors.textTertiary(for: colorScheme))
                            }
                        }
                    }
                    .padding(Tokens.Spacing.lg)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )

                    // 1. AI Provider Integration Section
                    VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                        Text("AI Provider Integration")
                            .font(Tokens.Typography.heading3)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                        APIKeyManagementView()
                    }
                    .padding(Tokens.Spacing.lg)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )

                    // 3. Enhancement Modes & Assistant Section
                    VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                        Text("Transformation Prompts")
                            .font(Tokens.Typography.heading3)
                            .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

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
                    .padding(Tokens.Spacing.lg)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )

                    EnhancementShortcutsSection()
                }
            }
            .padding(Tokens.Spacing.xl)
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Tokens.Colors.background(for: colorScheme))
        .sheet(isPresented: $isEditingPrompt) {
            PromptEditorView(mode: .add)
        }
        .sheet(item: $selectedPromptForEdit) { prompt in
            PromptEditorView(mode: .edit(prompt))
        }
    }
}

// MARK: - Drag & Drop Reorderable Grid
private struct ReorderablePromptGrid: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var enhancementService: AIEnhancementService

    let selectedPromptId: UUID?
    let onPromptSelected: (CustomPrompt) -> Void
    let onEditPrompt: ((CustomPrompt) -> Void)?
    let onDeletePrompt: ((CustomPrompt) -> Void)?
    let onAddNewPrompt: (() -> Void)?

    @State private var draggingItem: CustomPrompt?

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            if enhancementService.customPrompts.isEmpty {
                Text("No prompts available")
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .font(Tokens.Typography.caption)
            } else {
                let columns = [
                    GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 36)
                ]

                LazyVGrid(columns: columns, spacing: Tokens.Spacing.lg) {
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
                                    ? Tokens.Colors.orange.opacity(0.25)
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
                .padding(.vertical, Tokens.Spacing.md)
                .padding(.horizontal, Tokens.Spacing.lg)

                HStack {
                    Image(systemName: "info.circle")
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                    Text("Double-click to edit - Right-click for more options")
                        .font(Tokens.Typography.caption)
                        .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                }
                .padding(.top, Tokens.Spacing.sm)
                .padding(.horizontal, Tokens.Spacing.lg)
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
