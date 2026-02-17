import SwiftUI

struct SwingVideoCard: View {
    let video: SwingVideo
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                // Thumbnail
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: themeManager.isDark ?
                            [Color(hex: "1A3A2E"), Color(hex: "0D1F17")] :
                            [Color(hex: "D4E5DC"), Color(hex: "A8C5B5")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "figure.golf")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.theme.primary.opacity(0.5))

                    // Play button
                    Circle()
                        .fill(themeManager.theme.cardBackground.opacity(0.95))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                                .foregroundColor(themeManager.theme.primary)
                                .offset(x: 1)
                        )
                }
                .frame(width: 80, height: 60)
                .cornerRadius(12)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(video.type)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(themeManager.theme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(themeManager.theme.primary.opacity(0.15))
                            .cornerRadius(8)

                        Spacer()

                        Text(video.date)
                            .font(.system(size: 11))
                            .foregroundColor(themeManager.theme.textMuted)
                    }

                    Text(video.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)

                    Text(video.description)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(14)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SwingVideoCard(video: MockData.swingVideos[0])
        .environmentObject(ThemeManager())
        .padding()
}
