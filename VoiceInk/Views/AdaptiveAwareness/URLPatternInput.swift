import SwiftUI

/// Tag-style input for URL patterns with validation
struct URLPatternInput: View {
    @Binding var urlConfigs: [URLConfig]

    @State private var newURL = ""
    @State private var validationError: String?
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !urlConfigs.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 250))], spacing: 8) {
                    ForEach(urlConfigs) { urlConfig in
                        URLTagView(urlConfig: urlConfig) {
                            urlConfigs.removeAll { $0.id == urlConfig.id }
                        }
                    }
                }
                .padding(.bottom, 4)
            } else {
                Text("No URL patterns added")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Input field
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    TextField("example.com or *.example.com", text: $newURL)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            addURL()
                        }
                        .onChange(of: newURL) { _, _ in
                            // Clear validation error on change
                            validationError = nil
                        }

                    Button("Add") {
                        addURL()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(newURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let error = validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Text("Tip: Supports wildcards like *.example.com or example.com/path")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func addURL() {
        let trimmed = newURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Basic validation
        if !isValidURLPattern(trimmed) {
            validationError = "Invalid URL pattern"
            return
        }

        // Check for duplicates
        if urlConfigs.contains(where: { $0.url.lowercased() == trimmed.lowercased() }) {
            validationError = "URL pattern already exists"
            return
        }

        urlConfigs.append(URLConfig(url: trimmed))
        newURL = ""
        validationError = nil
    }

    private func isValidURLPattern(_ pattern: String) -> Bool {
        // Allow wildcards and basic URL patterns
        // Must contain at least a domain-like structure
        let cleaned = pattern
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .replacingOccurrences(of: "*", with: "")

        // Basic validation: must have at least one dot and some characters
        let components = cleaned.components(separatedBy: ".")
        return components.count >= 2 && components.allSatisfy { !$0.isEmpty }
    }
}

/// Individual URL tag with delete button
struct URLTagView: View {
    let urlConfig: URLConfig
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "globe")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Text(urlConfig.url)
                .font(.system(size: 13))
                .lineLimit(1)
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isHovered ? .red : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .help("Remove URL pattern")
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        }
    }
}
