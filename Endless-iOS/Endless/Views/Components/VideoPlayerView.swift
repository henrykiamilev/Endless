import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoFileName: String
    let videoTitle: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showControls = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isLoading = true
    @State private var loadError: String?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                } else if let error = loadError {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)

                        Text("Unable to Load Video")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("Make sure the video files are added to your Xcode project's target and included in 'Copy Bundle Resources'.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: { dismiss() }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        .padding(.top, 10)
                    }
                } else if isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading video...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                // Custom overlay controls (only show when video is loaded)
                if player != nil {
                    VStack {
                        // Top bar
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Text(videoTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Spacer()

                            // Share button
                            Button(action: shareVideo) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)

                        Spacer()

                        // Bottom controls
                        VStack(spacing: 16) {
                            // Progress bar
                            HStack(spacing: 12) {
                                Text(formatTime(currentTime))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 50)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        // Background track
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.white.opacity(0.3))
                                            .frame(height: 4)

                                        // Progress
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.green)
                                            .frame(width: duration > 0 ? CGFloat(currentTime / duration) * geo.size.width : 0, height: 4)
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let percentage = value.location.x / geo.size.width
                                                let clampedPercentage = min(max(percentage, 0), 1)
                                                let newTime = Double(clampedPercentage) * duration
                                                player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
                                            }
                                    )
                                }
                                .frame(height: 20)

                                Text(formatTime(duration))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 50)
                            }
                            .padding(.horizontal, 20)

                            // Playback controls
                            HStack(spacing: 40) {
                                // Rewind 10s
                                Button(action: {
                                    skip(by: -10)
                                }) {
                                    Image(systemName: "gobackward.10")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }

                                // Play/Pause
                                Button(action: togglePlayPause) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 64, height: 64)

                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(.white)
                                            .offset(x: isPlaying ? 0 : 2)
                                    }
                                }

                                // Forward 10s
                                Button(action: {
                                    skip(by: 10)
                                }) {
                                    Image(systemName: "goforward.10")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.bottom, 50)
                        .background(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .opacity(showControls ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: showControls)
                }
            }
            .onTapGesture {
                withAnimation {
                    showControls.toggle()
                }
            }
        }
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func loadVideo() {
        isLoading = true
        loadError = nil

        // Get the base name without extension
        let baseName = videoFileName.replacingOccurrences(of: ".mp4", with: "")

        // Try multiple paths to find the video
        var videoURL: URL?

        // Method 1: Direct bundle lookup (most common)
        if let url = Bundle.main.url(forResource: baseName, withExtension: "mp4") {
            videoURL = url
            print("Found video at: \(url.path)")
        }
        // Method 2: Look in Videos subdirectory
        else if let url = Bundle.main.url(forResource: baseName, withExtension: "mp4", subdirectory: "Videos") {
            videoURL = url
            print("Found video in Videos folder: \(url.path)")
        }
        // Method 3: Try with full filename in Videos folder
        else if let url = Bundle.main.url(forResource: videoFileName, withExtension: nil, subdirectory: "Videos") {
            videoURL = url
            print("Found video with full name: \(url.path)")
        }
        // Method 4: Search in bundle's resource path
        else if let resourcePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(resourcePath)/\(videoFileName)",
                "\(resourcePath)/Videos/\(videoFileName)",
                "\(resourcePath)/\(baseName).mp4",
                "\(resourcePath)/Videos/\(baseName).mp4"
            ]

            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    videoURL = URL(fileURLWithPath: path)
                    print("Found video at path: \(path)")
                    break
                }
            }
        }

        // If we found the video, create the player
        if let url = videoURL {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            setupPlayer()
        } else {
            // List available resources for debugging
            print("Could not find video: \(videoFileName)")
            print("Bundle path: \(Bundle.main.bundlePath)")

            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    let mp4Files = contents.filter { $0.hasSuffix(".mp4") }
                    print("MP4 files in bundle: \(mp4Files)")
                } catch {
                    print("Error listing bundle contents: \(error)")
                }
            }

            isLoading = false
            loadError = "Video file '\(videoFileName)' not found in app bundle."
        }
    }

    private func setupPlayer() {
        guard let player = player, let item = player.currentItem else { return }

        isLoading = false

        // Observe when the player is ready
        item.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                let durationTime = item.asset.duration
                if durationTime.isValid && !durationTime.isIndefinite {
                    self.duration = CMTimeGetSeconds(durationTime)
                }
            }
        }

        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
            if let item = player.currentItem {
                let dur = item.duration
                if dur.isValid && !dur.isIndefinite {
                    duration = CMTimeGetSeconds(dur)
                }
            }
        }

        // Auto-play
        player.play()
        isPlaying = true

        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }

    private func togglePlayPause() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    private func skip(by seconds: Double) {
        guard let player = player else { return }

        let newTime = currentTime + seconds
        let clampedTime = min(max(newTime, 0), duration)
        player.seek(to: CMTime(seconds: clampedTime, preferredTimescale: 600))
    }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func shareVideo() {
        // Share functionality would go here
    }
}

// MARK: - Fullscreen Video Player Sheet
struct FullscreenVideoPlayer: View {
    let video: Video
    @Environment(\.dismiss) var dismiss

    var body: some View {
        if let fileName = video.videoFileName {
            VideoPlayerView(videoFileName: fileName, videoTitle: video.title)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "video.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                Text("Video not available")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    VideoPlayerView(videoFileName: "swing-1.mp4", videoTitle: "Oakmont CC")
        .environmentObject(ThemeManager())
}
