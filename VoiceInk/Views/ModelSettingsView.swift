import SwiftUI

struct ModelSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var whisperPrompt: WhisperPrompt
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("IsTextFormattingEnabled") private var isTextFormattingEnabled = true
    @AppStorage("IsVADEnabled") private var isVADEnabled = true
    @AppStorage("AppendTrailingSpace") private var appendTrailingSpace = true
    @State private var customPrompt: String = ""
    @State private var isEditing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            HStack {
                Text("Output Format")
                    .font(Tokens.Typography.heading3)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))

                InfoTip(
                    title: "Output Format Guide",
                    message: "Unlike GPT, Voice Models(whisper) follows the style of your prompt rather than instructions. Use examples of your desired output format instead of commands.",
                    learnMoreURL: "https://echo.vjh.io/docs"
                )

                Spacer()

                Button(action: {
                    if isEditing {
                        // Save changes
                        whisperPrompt.setCustomPrompt(customPrompt, for: selectedLanguage)
                        isEditing = false
                    } else {
                        // Enter edit mode
                        customPrompt = whisperPrompt.getLanguagePrompt(for: selectedLanguage)
                        isEditing = true
                    }
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .font(Tokens.Typography.caption)
                }
                .tint(Tokens.Colors.orange)
            }

            if isEditing {
                TextEditor(text: $customPrompt)
                    .font(Tokens.Typography.label)
                    .padding(Tokens.Spacing.sm)
                    .frame(height: 80)
                    .background(Tokens.Colors.elevated(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )

            } else {
                Text(whisperPrompt.getLanguagePrompt(for: selectedLanguage))
                    .font(Tokens.Typography.label)
                    .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))
                    .padding(Tokens.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .fill(Tokens.Colors.background(for: colorScheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                    )
            }

            Divider().padding(.vertical, Tokens.Spacing.xs)

            HStack {
                Toggle(isOn: $appendTrailingSpace) {
                    Text("Add space after paste")
                        .font(Tokens.Typography.body)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                }
                .toggleStyle(.switch)
                .tint(Tokens.Colors.orange)

                InfoTip(
                    title: "Trailing Space",
                    message: "Automatically add a space after pasted text. Useful for space-delimited languages."
                )
            }

            HStack {
                Toggle(isOn: $isTextFormattingEnabled) {
                    Text("Automatic text formatting")
                        .font(Tokens.Typography.body)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                }
                .toggleStyle(.switch)
                .tint(Tokens.Colors.orange)

                InfoTip(
                    title: "Automatic Text Formatting",
                    message: "Apply intelligent text formatting to break large block of text into paragraphs."
                )
            }

            HStack {
                Toggle(isOn: $isVADEnabled) {
                    Text("Voice Activity Detection (VAD)")
                        .font(Tokens.Typography.body)
                        .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                }
                .toggleStyle(.switch)
                .tint(Tokens.Colors.orange)

                InfoTip(
                    title: "Voice Activity Detection",
                    message: "Detect speech segments and filter out silence to improve accuracy of local models."
                )
            }

        }
        .padding(Tokens.Spacing.lg)
        .background(Tokens.Colors.elevated(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
        // Reset the editor when language changes
        .onChange(of: selectedLanguage) { oldValue, newValue in
            if isEditing {
                customPrompt = whisperPrompt.getLanguagePrompt(for: selectedLanguage)
            }
        }
    }
} 
