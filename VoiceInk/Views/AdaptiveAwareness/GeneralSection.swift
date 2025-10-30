import SwiftUI

/// General section for profile name, emoji, enabled state, and default status
struct GeneralSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @State private var isShowingEmojiPicker = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("General")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Profile name, icon, and status")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Name and Emoji Row
            HStack(spacing: 16) {
                // Emoji Picker Button
                Button(action: {
                    isShowingEmojiPicker.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Text(config.emoji)
                            .font(.system(size: 28))
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isShowingEmojiPicker, arrowEdge: .bottom) {
                    EmojiPickerView(
                        selectedEmoji: Binding(
                            get: { config.emoji },
                            set: { newValue in
                                config.emoji = newValue
                                onSave()
                            }
                        ),
                        isPresented: $isShowingEmojiPicker
                    )
                }

                // Name Field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Profile name", text: Binding(
                        get: { config.name },
                        set: { config.name = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 15))
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        onSave()
                    }
                    .onChange(of: isNameFieldFocused) { _, focused in
                        if !focused {
                            onSave()
                        }
                    }
                }
            }

            // Toggles
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Enable profile", isOn: Binding(
                    get: { config.isEnabled },
                    set: { newValue in
                        config.isEnabled = newValue
                        onSave()
                    }
                ))
                .toggleStyle(.switch)

                HStack(spacing: 8) {
                    Toggle("Make default", isOn: Binding(
                        get: { config.isDefault },
                        set: { newValue in
                            config.isDefault = newValue
                            onSave()
                        }
                    ))
                    .toggleStyle(.switch)

                    InfoTip(
                        title: "Default Profile",
                        message: "The default profile activates when no other triggers match. Only one profile can be set as default."
                    )
                }
            }
        }
    }
}
