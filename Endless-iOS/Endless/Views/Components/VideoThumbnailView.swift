import SwiftUI
import AVFoundation

// MARK: - Video Thumbnail Generator
actor VideoThumbnailGenerator {
    static let shared = VideoThumbnailGenerator()
    private var cache: [String: UIImage] = [:]
    private let maxCacheSize = 50

    private init() {}

    func generateThumbnail(for videoFileName: String, at time: CMTime = CMTime(seconds: 1, preferredTimescale: 600)) async -> UIImage? {
        // Check cache first
        let cacheKey = "\(videoFileName)-\(time.seconds)"
        if let cachedImage = cache[cacheKey] {
            return cachedImage
        }

        // Try to find the video file
        let url = findVideoURL(for: videoFileName)

        guard let videoURL = url else {
            print("VideoThumbnailGenerator: Could not find video: \(videoFileName)")
            return nil
        }

        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 400, height: 400)

        do {
            // Use modern async API for thumbnail generation (iOS 16+)
            let (cgImage, _) = try await imageGenerator.image(at: time)
            let image = UIImage(cgImage: cgImage)

            // Manage cache size
            if cache.count >= maxCacheSize {
                // Remove oldest entry (simple FIFO)
                if let firstKey = cache.keys.first {
                    cache.removeValue(forKey: firstKey)
                }
            }
            cache[cacheKey] = image

            return image
        } catch {
            print("VideoThumbnailGenerator: Error generating thumbnail: \(error)")
            return nil
        }
    }

    func getVideoDuration(for videoFileName: String) async -> Double? {
        let url = findVideoURL(for: videoFileName)
        guard let videoURL = url else { return nil }

        let asset = AVAsset(url: videoURL)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            print("VideoThumbnailGenerator: Error loading duration: \(error)")
            return nil
        }
    }

    func clearCache() {
        cache.removeAll()
    }

    // MARK: - Private Helpers

    private nonisolated func findVideoURL(for videoFileName: String) -> URL? {
        let baseName = videoFileName.replacingOccurrences(of: ".mp4", with: "")

        // Try bundle root
        if let bundleURL = Bundle.main.url(forResource: baseName, withExtension: "mp4") {
            return bundleURL
        }
        // Try Videos subdirectory
        if let videosURL = Bundle.main.url(forResource: baseName, withExtension: "mp4", subdirectory: "Videos") {
            return videosURL
        }
        // Try without extension manipulation
        if let directURL = Bundle.main.url(forResource: videoFileName, withExtension: nil, subdirectory: "Videos") {
            return directURL
        }
        // Search in bundle's resource path
        if let resourcePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(resourcePath)/\(videoFileName)",
                "\(resourcePath)/Videos/\(videoFileName)",
                "\(resourcePath)/\(baseName).mp4",
                "\(resourcePath)/Videos/\(baseName).mp4"
            ]

            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    return URL(fileURLWithPath: path)
                }
            }
        }

        return nil
    }
}

// MARK: - Video Thumbnail View (SwiftUI)
struct VideoThumbnailView: View {
    let videoFileName: String
    @State private var thumbnail: UIImage?
    @State private var isLoading = true
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                // Loading placeholder
                ZStack {
                    thumbnailPlaceholder
                    ProgressView()
                        .controlSize(.small)
                        .tint(themeManager.theme.textSecondary)
                }
            } else {
                // Failed to load - show placeholder
                thumbnailPlaceholder
            }
        }
        .task {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        isLoading = true
        thumbnail = await VideoThumbnailGenerator.shared.generateThumbnail(for: videoFileName)
        isLoading = false
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
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

            // Video icon
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(themeManager.theme.textSecondary.opacity(0.08))
                    .frame(width: 40, height: 40)

                Image(systemName: "video.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(themeManager.theme.textSecondary.opacity(0.4))
            }
        }
    }
}

// MARK: - Session Thumbnail View
struct SessionThumbnailView: View {
    let session: Session
    @State private var thumbnail: UIImage?
    @State private var isLoading = true
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ZStack {
                    placeholderBackground
                    ProgressView()
                        .controlSize(.small)
                        .tint(themeManager.theme.textSecondary)
                }
            } else {
                placeholderBackground
            }
        }
        .task {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        guard let videoFileName = session.thumbnail else {
            isLoading = false
            return
        }
        isLoading = true
        thumbnail = await VideoThumbnailGenerator.shared.generateThumbnail(for: videoFileName)
        isLoading = false
    }

    private var placeholderBackground: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: themeManager.isDark ?
                    [Color(hex: "1A1A1A"), Color(hex: "0D0D0D")] :
                    [Color(hex: "F5F5F5"), Color(hex: "E8E8E8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 20
                    for i in stride(from: 0, to: geo.size.width + geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: i))
                    }
                }
                .stroke(themeManager.theme.textSecondary.opacity(0.05), lineWidth: 1)
            }

            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.textSecondary.opacity(0.08))
                        .frame(width: 44, height: 44)

                    Image(systemName: "figure.golf")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(themeManager.theme.textSecondary.opacity(0.4))
                }
            }
        }
    }
}

#Preview {
    VStack {
        VideoThumbnailView(videoFileName: "swing-1.mp4")
            .frame(width: 200, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .environmentObject(ThemeManager())
    .padding()
}
