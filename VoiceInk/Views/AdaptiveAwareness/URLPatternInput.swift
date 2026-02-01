import SwiftUI

/// Tag-style input for URL patterns with validation
/// Updated to fit within the trigger grid column design
struct URLPatternInput: View {
    @Binding var urlConfigs: [URLConfig]

    @State private var newURL = ""
    @State private var validationError: String?
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
            // Existing URLs
            if !urlConfigs.isEmpty {
                VStack(spacing: Tokens.Spacing.sm) {
                    ForEach(urlConfigs) { urlConfig in
                        URLTagView(urlConfig: urlConfig) {
                            urlConfigs.removeAll { $0.id == urlConfig.id }
                        }
                    }
                }
            }

            // Input field
            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                HStack(spacing: Tokens.Spacing.sm) {
                    TextField("example.com", text: $newURL)
                        .textFieldStyle(.plain)
                        .font(Tokens.Typography.bodySmall)
                        .padding(.horizontal, Tokens.Spacing.sm)
                        .padding(.vertical, Tokens.Spacing.xs)
                        .background(Tokens.Colors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
                        )
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            addURL()
                        }
                        .onChange(of: newURL) { _, _ in
                            validationError = nil
                        }

                    Button(action: addURL) {
                        Text("Add")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(newURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let error = validationError {
                    Text(error)
                        .font(.system(size: 10))
                        .foregroundColor(Tokens.Colors.error)
                }
            }

            // Hint text
            Text("Supports wildcards: *.example.com")
                .font(.system(size: 10))
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))
        }
    }

    private func addURL() {
        let trimmed = newURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if !isValidURLPattern(trimmed) {
            validationError = "Invalid URL pattern"
            return
        }

        if urlConfigs.contains(where: { $0.url.lowercased() == trimmed.lowercased() }) {
            validationError = "Already exists"
            return
        }

        urlConfigs.append(URLConfig(url: trimmed))
        newURL = ""
        validationError = nil
    }

    private func isValidURLPattern(_ pattern: String) -> Bool {
        let cleaned = pattern
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .replacingOccurrences(of: "*", with: "")

        let components = cleaned.components(separatedBy: ".")
        return components.count >= 2 && components.allSatisfy { !$0.isEmpty }
    }
}

/// Individual URL tag with delete button
struct URLTagView: View {
    let urlConfig: URLConfig
    let onDelete: () -> Void

    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            Image(systemName: "globe")
                .font(.system(size: 10))
                .foregroundColor(Tokens.Colors.textTertiary(for: colorScheme))

            Text(urlConfig.url)
                .font(Tokens.Typography.bodySmall)
                .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                .lineLimit(1)

            Spacer(minLength: 4)

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Tokens.Colors.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Tokens.Spacing.sm)
        .padding(.vertical, Tokens.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .fill(Tokens.Colors.background(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .stroke(Tokens.Colors.border(for: colorScheme), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
