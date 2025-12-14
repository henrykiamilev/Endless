import SwiftUI

struct VideoCard: View {
    let video: Video
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 10) {
                // Thumbnail
                ZStack {
                    if let thumbnail = video.thumbnail {
                        AsyncImage(url: URL(string: thumbnail)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            placeholderView
                        }
                    } else {
                        placeholderView
                    }

                    // Duration badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(video.duration)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }

                    // Play button overlay
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.primary)
                                .offset(x: 1)
                        )
                }
                .frame(height: 90)
                .cornerRadius(16)
                .clipped()

                Text(video.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(1)

                Text(video.date)
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .frame(width: (UIScreen.main.bounds.width - 52) / 2)
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
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 24))
                .foregroundColor(themeManager.theme.primary.opacity(0.5))
        )
    }
}

#Preview {
    VideoCard(video: MockData.videos[0])
        .environmentObject(ThemeManager())
        .padding()
}
