import SwiftUI
import AVKit
import Combine

struct VideoPlayerView: View {
    let videoFileName: String
    let videoTitle: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var playerManager = VideoPlayerManager()
    @State private var showControls = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                // Video Player
                if let player = playerManager.player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                } else if let error = playerManager.loadError {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)

                        Text("Unable to Load Video")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        Text(error)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Text("Make sure the video files are added to your Xcode project's target and included in 'Copy Bundle Resources'.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: { dismiss() }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        .padding(.top, 10)
                    }
                } else if playerManager.isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                        Text("Loading video...")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                // Custom overlay controls (only show when video is loaded)
                if playerManager.player != nil {
                    VStack {
                        // Top bar
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Text(videoTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)

                            Spacer()

                            // Share button
                            Button(action: shareVideo) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
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
                                Text(formatTime(playerManager.currentTime))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white)
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
                                            .frame(width: playerManager.duration > 0 ? CGFloat(playerManager.currentTime / playerManager.duration) * geo.size.width : 0, height: 4)
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let percentage = value.location.x / geo.size.width
                                                let clampedPercentage = min(max(percentage, 0), 1)
                                                let newTime = Double(clampedPercentage) * playerManager.duration
                                                playerManager.seek(to: newTime)
                                            }
                                    )
                                }
                                .frame(height: 20)

                                Text(formatTime(playerManager.duration))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white)
                                    .frame(width: 50)
                            }
                            .padding(.horizontal, 20)

                            // Playback controls
                            HStack(spacing: 40) {
                                // Rewind 10s
                                Button(action: {
                                    playerManager.skip(by: -10)
                                }) {
                                    Image(systemName: "gobackward.10")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                }

                                // Play/Pause
                                Button(action: { playerManager.togglePlayPause() }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 64, height: 64)

                                        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .offset(x: playerManager.isPlaying ? 0 : 2)
                                    }
                                }

                                // Forward 10s
                                Button(action: {
                                    playerManager.skip(by: 10)
                                }) {
                                    Image(systemName: "goforward.10")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
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
            playerManager.loadVideo(fileName: videoFileName)
        }
        .onDisappear {
            playerManager.cleanup()
        }
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

// MARK: - Video Player Manager (ObservableObject for proper state management)
final class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isLoading = true
    @Published var loadError: String?

    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var statusObserver: NSKeyValueObservation?

    func loadVideo(fileName: String) {
        isLoading = true
        loadError = nil

        // Check if it's a remote URL first
        if fileName.hasPrefix("http://") || fileName.hasPrefix("https://") {
            if let remoteURL = URL(string: fileName) {
                print("Loading remote video from: \(fileName)")
                loadFromURL(remoteURL)
                return
            } else {
                isLoading = false
                loadError = "Invalid video URL: \(fileName)"
                return
            }
        }

        // Check if it's a local file path (user-recorded videos)
        if fileName.hasPrefix("/") && FileManager.default.fileExists(atPath: fileName) {
            print("Loading local video from: \(fileName)")
            loadFromURL(URL(fileURLWithPath: fileName))
            return
        }

        // Get the base name without extension
        let baseName = fileName.replacingOccurrences(of: ".mp4", with: "")

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
        else if let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "Videos") {
            videoURL = url
            print("Found video with full name: \(url.path)")
        }
        // Method 4: Search in bundle's resource path
        else if let resourcePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(resourcePath)/\(fileName)",
                "\(resourcePath)/Videos/\(fileName)",
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
        guard let url = videoURL else {
            // List available resources for debugging
            print("Could not find video: \(fileName)")
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
            loadError = "Video file '\(fileName)' not found in app bundle."
            return
        }

        loadFromURL(url)
    }

    private func loadFromURL(_ url: URL) {
        // Create player item and player
        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)

        // Observe the player item status for errors
        statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isLoading = false
                    self.player = newPlayer
                    self.setupObservers()
                    newPlayer.play()
                    self.isPlaying = true
                case .failed:
                    self.isLoading = false
                    self.loadError = item.error?.localizedDescription ?? "Failed to load video"
                case .unknown:
                    // Still loading
                    break
                @unknown default:
                    break
                }
            }
        }

        // Set a timeout for loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let self = self else { return }
            if self.isLoading && self.player == nil {
                self.isLoading = false
                self.loadError = "Video loading timed out. Please check your connection."
            }
        }
    }

    private func setupObservers() {
        guard let player = player else { return }

        // Add time observer with weak self to prevent retain cycle
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            if let item = player.currentItem {
                let dur = item.duration
                if dur.isValid && !dur.isIndefinite && self.duration == 0 {
                    self.duration = CMTimeGetSeconds(dur)
                }
            }
        }

        // Loop video when it ends
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.player?.seek(to: .zero)
            self.player?.play()
            self.isPlaying = true
        }
    }

    func togglePlayPause() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func skip(by seconds: Double) {
        let newTime = currentTime + seconds
        let clampedTime = min(max(newTime, 0), duration)
        seek(to: clampedTime)
    }

    func cleanup() {
        // Remove time observer
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }

        // Remove end observer
        if let endObserver = endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }

        // Remove status observer
        statusObserver?.invalidate()
        statusObserver = nil

        player?.pause()
        player = nil
    }

    deinit {
        cleanup()
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
                    .foregroundStyle(.gray)
                Text("Video not available")
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    VideoPlayerView(videoFileName: "swing-1.mp4", videoTitle: "Oakmont CC")
        .environmentObject(ThemeManager())
}
