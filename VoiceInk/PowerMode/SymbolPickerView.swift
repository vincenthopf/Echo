import SwiftUI

/// SF Symbol picker for profile icons
/// Clean grid of symbols using VoiceInk design tokens
struct SymbolPickerView: View {
    @Binding var selectedSymbol: String
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme

    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 44), spacing: 8)]

    var body: some View {
        VStack(spacing: Tokens.Spacing.md) {
            // Header
            HStack {
                Text("Choose Icon")
                    .font(Tokens.Typography.bodyMedium)
                    .foregroundColor(Tokens.Colors.textPrimary(for: colorScheme))
                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.sm)

            // Symbol grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(ProfileSymbol.allCases) { symbol in
                        Button(action: {
                            selectedSymbol = symbol.rawValue
                            isPresented = false
                        }) {
                            Image(systemName: symbol.rawValue)
                                .font(.system(size: 18))
                                .foregroundColor(selectedSymbol == symbol.rawValue ? .white : Tokens.Colors.orange)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                        .fill(selectedSymbol == symbol.rawValue
                                              ? Tokens.Colors.orange
                                              : Tokens.Colors.orangeSoft(for: colorScheme))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Tokens.Radius.md)
                                        .stroke(
                                            selectedSymbol == symbol.rawValue
                                            ? Tokens.Colors.orange
                                            : Tokens.Colors.border(for: colorScheme),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .help(symbol.displayName)
                    }
                }
            }
            .frame(maxHeight: 220)
        }
        .padding(Tokens.Spacing.md)
        .frame(width: 280)
        .background(Tokens.Colors.elevated(for: colorScheme))
    }
}

#if DEBUG
struct SymbolPickerView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPickerView(
            selectedSymbol: .constant("sparkles"),
            isPresented: .constant(true)
        )
    }
}
#endif
