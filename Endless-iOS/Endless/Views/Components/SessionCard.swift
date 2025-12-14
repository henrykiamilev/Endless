import SwiftUI

struct SessionCard: View {
    let session: Session
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 10) {
                // Thumbnail
                ZStack(alignment: .bottomLeading) {
                    if let thumbnail = session.thumbnail {
                        AsyncImage(url: URL(string: thumbnail)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            placeholderView
                        }
                    } else {
                        placeholderView
                    }

                    // Location Badge
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                        Text(session.location)
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(themeManager.theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.theme.cardBackground)
                    .cornerRadius(10)
                    .padding(8)
                }
                .frame(width: 140, height: 100)
                .cornerRadius(20)
                .clipped()

                Text(session.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(1)

                Text(session.date)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .frame(width: 140)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var placeholderView: some View {
        LinearGradient(
            gradient: Gradient(colors: themeManager.isDark ?
                [Color(hex: "1A3A2E"), Color(hex: "0D1F17")] :
                [Color(hex: "D4E5DC"), Color(hex: "A8C5B5")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "figure.golf")
                .font(.system(size: 28))
                .foregroundColor(themeManager.theme.primary.opacity(0.6))
        )
    }
}

#Preview {
    SessionCard(session: MockData.sessions[0])
        .environmentObject(ThemeManager())
        .padding()
}
