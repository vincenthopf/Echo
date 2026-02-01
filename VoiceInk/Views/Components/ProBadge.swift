import SwiftUI

struct ProBadge: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("PRO")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: ParallelDesignTokens.Radius.small)
                    .fill(ParallelDesignTokens.Colors.primaryOrange)
            )
    }
}

#Preview {
    ProBadge()
} 