import SwiftUI

/// General section for profile name, icon, and default status
/// Clean form layout without heavy grey backgrounds
struct GeneralSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    @State private var isShowingIconPicker = false
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            SectionHeader(
                title: "General",
                subtitle: "Profile name, icon, and status"
            )

            // Form container with border
            VStack(spacing: 0) {
                // Icon row
                FormRow(label: "Icon") {
                    Button(action: {
                        isShowingIconPicker.toggle()
                    }) {
                        HStack(spacing: Tokens.Spacing.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                    .fill(Tokens.Colors.background(for: colorScheme))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                            .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                                    )

                                if config.emoji.shouldRenderAsSFSymbol {
                                    Image(systemName: config.emoji)
                                        .font(.system(size: 18))
                                        .foregroundColor(Tokens.Colors.orange)
                                } else {
                                    Text(config.emoji)
                                        .font(.system(size: 18))
                                }
                            }

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                        }
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $isShowingIconPicker, arrowEdge: .bottom) {
                        SymbolPickerView(
                            selectedSymbol: Binding(
                                get: { config.emoji },
                                set: { newValue in
                                    config.emoji = newValue
                                    onSave()
                                }
                            ),
                            isPresented: $isShowingIconPicker
                        )
                    }
                }

                FormDivider()

                // Name row
                FormRow(label: "Name") {
                    TextField("Profile name", text: Binding(
                        get: { config.name },
                        set: { config.name = $0 }
                    ))
                    .textFieldStyle(.plain)
                    .font(Tokens.Typography.body)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
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

                FormDivider()

                // Default toggle row
                FormRow(label: "Default") {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Toggle("", isOn: Binding(
                            get: { config.isDefault },
                            set: { newValue in
                                config.isDefault = newValue
                                onSave()
                            }
                        ))
                        .toggleStyle(.switch)
                        .tint(Tokens.Colors.orange)
                        .labelsHidden()

                        Text("Make default profile")
                            .font(Tokens.Typography.bodySmall)
                            .foregroundColor(Tokens.Colors.textSecondary(for: colorScheme))

                        InfoTip(
                            title: "Default Profile",
                            message: "The default profile activates when no other triggers match. Only one profile can be set as default."
                        )

                        Spacer()
                    }
                }
            }
            .background(Tokens.Colors.elevated(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
            )
        }
    }
}

// MARK: - Clean Form Components

/// Simple form row with label on left, content on right
struct FormRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: Tokens.Spacing.lg) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
                .frame(width: 80, alignment: .leading)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, 14)
    }
}

/// Simple horizontal divider
struct FormDivider: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(Tokens.Colors.border(for: colorScheme))
            .frame(height: 1)
    }
}

// MARK: - Legacy compatibility aliases
typealias FormGridRow = FormRow
typealias FormGridDivider = FormDivider
