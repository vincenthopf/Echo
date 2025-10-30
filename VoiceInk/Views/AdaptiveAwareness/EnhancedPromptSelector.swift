import SwiftUI

/// Enhanced prompt selector with usage counts and inline editing
struct EnhancedPromptSelector: View {
    @Binding var selectedPromptId: String?
    let onSave: () -> Void

    @EnvironmentObject private var enhancementService: AIEnhancementService
    @State private var showingPromptEditor = false
    @State private var editingPrompt: CustomPrompt?

    private var selectedPrompt: CustomPrompt? {
        guard let promptId = selectedPromptId,
              let uuid = UUID(uuidString: promptId) else {
            return nil
        }
        return enhancementService.allPrompts.first { $0.id == uuid }
    }

    private var sortedPrompts: [CustomPrompt] {
        enhancementService.allPrompts.sorted { $0.title < $1.title }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Prompt Dropdown
            Menu {
                Button("None") {
                    selectedPromptId = nil
                    onSave()
                }

                Divider()

                // Predefined prompts
                let predefinedPrompts = sortedPrompts.filter { $0.isPredefined }
                if !predefinedPrompts.isEmpty {
                    Section(header: Text("Predefined")) {
                        ForEach(predefinedPrompts) { prompt in
                            promptMenuItem(for: prompt)
                        }
                    }
                }

                // Custom prompts
                let customPrompts = sortedPrompts.filter { !$0.isPredefined }
                if !customPrompts.isEmpty {
                    Section(header: Text("Custom")) {
                        ForEach(customPrompts) { prompt in
                            promptMenuItem(for: prompt)
                        }
                    }
                }

                Divider()

                Button(action: {
                    editingPrompt = nil
                    showingPromptEditor = true
                }) {
                    Label("Create New Prompt", systemImage: "plus.circle")
                }
            } label: {
                HStack {
                    if let prompt = selectedPrompt {
                        Image(systemName: prompt.icon.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)

                        Text(prompt.title)
                            .foregroundColor(.primary)

                        // Stage 4: Better usage count display in selector
                        let count = usageCount(for: prompt)
                        if count > 0 {
                            Text("(Used in \(count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("(Not in use)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Text("Select a prompt")
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)

            // Preview and Edit Button
            if let prompt = selectedPrompt {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(String(prompt.promptText.prefix(100)) + (prompt.promptText.count > 100 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.textBackgroundColor))
                        )

                    Button(action: {
                        editingPrompt = prompt
                        showingPromptEditor = true
                    }) {
                        Label("Edit Prompt", systemImage: "pencil")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .sheet(isPresented: $showingPromptEditor) {
            if let prompt = editingPrompt {
                PromptEditorView(mode: .edit(prompt))
            } else {
                PromptEditorView(mode: .add)
            }
        }
    }

    @ViewBuilder
    private func promptMenuItem(for prompt: CustomPrompt) -> some View {
        Button(action: {
            selectedPromptId = prompt.id.uuidString
            onSave()
        }) {
            HStack {
                Image(systemName: prompt.icon.rawValue)
                Text(prompt.title)

                // Stage 4: Display usage count or "Not in use" label
                let count = usageCount(for: prompt)
                if count > 0 {
                    Text("(Used in \(count))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("(Not in use)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                if selectedPromptId == prompt.id.uuidString {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }

    private func usageCount(for prompt: CustomPrompt) -> Int {
        // Use the CustomPrompt's built-in usageCount for consistency
        return prompt.usageCount
    }
}
