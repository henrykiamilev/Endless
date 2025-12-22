import SwiftUI

struct VideoCard: View {
    let video: Video
    var action: (() -> Void)?
    var onDelete: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingPlayer = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main card button
            Button(action: {
                if action != nil {
                    action?()
                } else if video.videoFileName != nil {
                    showingPlayer = true
                }
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    // Thumbnail area - using real video thumbnails
                    ZStack {
                        if let videoFileName = video.videoFileName {
                            VideoThumbnailView(videoFileName: videoFileName)
                        } else {
                            thumbnailPlaceholder
                        }

                        // Gradient overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.4)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        // Duration badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text(video.duration)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .padding(8)
                            }
                        }

                        // Play button overlay
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)

                            Circle()
                                .fill(Color.white)
                                .frame(width: 34, height: 34)

                            Image(systemName: "play.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(themeManager.theme.primary)
                                .offset(x: 1)
                        }
                    }
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    // Content area
                    VStack(alignment: .leading, spacing: 6) {
                        Text(video.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 9))
                            Text(video.date)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(themeManager.theme.textSecondary)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())

            // Delete button (separate from main button to avoid tap conflicts)
            if onDelete != nil {
                Button(action: {
                    onDelete?()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 28, height: 28)

                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
            }
        }
        .fullScreenCover(isPresented: $showingPlayer) {
            if let videoFileName = video.videoFileName {
                VideoPlayerView(videoFileName: videoFileName, videoTitle: video.title)
                    .environmentObject(themeManager)
            } else {
                // Fallback view if video data is missing
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray)
                        Text("Video not available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                        Button("Close") {
                            showingPlayer = false
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: themeManager.isDark ?
                    [Color(hex: "1A1A1A"), Color(hex: "0F0F0F")] :
                    [Color(hex: "F0F0F0"), Color(hex: "E0E0E0")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle grid pattern
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 16
                    for i in stride(from: 0, to: geo.size.width, by: spacing) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i, y: geo.size.height))
                    }
                    for i in stride(from: 0, to: geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: i))
                        path.addLine(to: CGPoint(x: geo.size.width, y: i))
                    }
                }
                .stroke(themeManager.theme.textSecondary.opacity(0.05), lineWidth: 1)
            }

            // Video icon - subtle
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(themeManager.theme.textSecondary.opacity(0.08))
                    .frame(width: 40, height: 40)

                Image(systemName: "video.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary.opacity(0.4))
            }
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        VideoCard(video: MockData.videos[0])
        VideoCard(video: MockData.videos[0])
    }
    .environmentObject(ThemeManager())
    .padding()
}
