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
            // Prompt Dropdown using native Picker
            HStack(spacing: 12) {
                Picker("Enhancement Prompt", selection: Binding(
                    get: { selectedPromptId },
                    set: { newValue in
                        selectedPromptId = newValue
                        onSave()
                    }
                )) {
                    Text("None").tag(nil as String?)

                    Divider()

                    // Predefined prompts
                    let predefinedPrompts = sortedPrompts.filter { $0.isPredefined }
                    if !predefinedPrompts.isEmpty {
                        Section(header: Text("Predefined")) {
                            ForEach(predefinedPrompts) { prompt in
                                HStack {
                                    Image(systemName: prompt.icon.rawValue)
                                    Text(prompt.title)

                                    // Usage count display
                                    let count = usageCount(for: prompt)
                                    if count > 0 {
                                        Text("(Used in \(count))")
                                            .font(.caption)
                                    }
                                }.tag(prompt.id.uuidString as String?)
                            }
                        }
                    }

                    // Custom prompts
                    let customPrompts = sortedPrompts.filter { !$0.isPredefined }
                    if !customPrompts.isEmpty {
                        Section(header: Text("Custom")) {
                            ForEach(customPrompts) { prompt in
                                HStack {
                                    Image(systemName: prompt.icon.rawValue)
                                    Text(prompt.title)

                                    // Usage count display
                                    let count = usageCount(for: prompt)
                                    if count > 0 {
                                        Text("(Used in \(count))")
                                            .font(.caption)
                                    }
                                }.tag(prompt.id.uuidString as String?)
                            }
                        }
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()

                // Create new prompt button
                Button(action: {
                    editingPrompt = nil
                    showingPromptEditor = true
                }) {
                    Label("Create New Prompt", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

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

    private func usageCount(for prompt: CustomPrompt) -> Int {
        // Use the CustomPrompt's built-in usageCount for consistency
        return prompt.usageCount
    }
}
