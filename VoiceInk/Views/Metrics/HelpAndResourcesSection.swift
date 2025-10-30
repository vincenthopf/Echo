import SwiftUI

struct HelpAndResourcesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learn More")
                .font(.system(size: 17, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                resourceLink(
                    icon: "sparkles",
                    title: "Choose the Right Model",
                    url: "https://github.com/vincenthopf/Echo#transcription-models"
                )

                Divider()
                    .padding(.leading, 24)

                resourceLink(
                    icon: "video.fill",
                    title: "Watch Video Tutorials",
                    url: "https://github.com/vincenthopf/Echo#getting-started"
                )

                Divider()
                    .padding(.leading, 24)

                resourceLink(
                    icon: "book.fill",
                    title: "Explore Advanced Features",
                    url: "https://github.com/vincenthopf/Echo#advanced-features"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private func resourceLink(icon: String, title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 16, alignment: .center)
                    .font(.system(size: 15))

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "arrow.up.forward.square")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 13))
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HelpAndResourcesSection()
        .frame(width: 400)
        .padding()
}
