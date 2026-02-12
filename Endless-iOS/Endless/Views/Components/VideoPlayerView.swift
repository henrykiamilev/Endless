import SwiftUI
import AVKit
import Combine

// MARK: - Custom AVPlayerLayer wrapper (no built-in controls)
private struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private class PlayerUIView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}

// MARK: - Broadcast-style Video Player
struct VideoPlayerView: View {
    let videoFileName: String
    let videoTitle: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var playerManager = VideoPlayerManager()
    @State private var showControls = false
    @State private var hideTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                // Video Player — custom layer, no built-in controls
                if let player = playerManager.player {
                    PlayerLayerView(player: player)
                        .ignoresSafeArea()
                } else if let error = playerManager.loadError {
                    errorView(error)
                } else if playerManager.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                        Text("Loading video...")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                // Overlay (only when video is loaded)
                if playerManager.player != nil {
                    // Tap target — covers entire screen
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { handleTap() }

                    // Auto-hiding top controls
                    VStack {
                        HStack {
                            // Close button
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial.opacity(0.8))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            // Share button
                            Button(action: shareVideo) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, geometry.safeAreaInsets.top + 8)

                        Spacer()
                    }
                    .opacity(showControls ? 1 : 0)
                    .animation(.easeInOut(duration: 0.25), value: showControls)

                    // Center play/pause indicator (brief flash on tap)
                    if showControls {
                        Button(action: {
                            playerManager.togglePlayPause()
                            scheduleHide()
                        }) {
                            Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 72, height: 72)
                                .background(.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.25), value: showControls)
                    }

                    // Bottom overlay — always visible broadcast stat boxes + thin progress
                    VStack(spacing: 0) {
                        Spacer()

                        // Broadcast stat boxes — bottom left
                        HStack {
                            HStack(spacing: 6) {
                                statBox(
                                    value: videoTitle,
                                    label: "SESSION"
                                )
                                statBox(
                                    value: formatTime(playerManager.duration),
                                    label: "DURATION"
                                )
                            }
                            .padding(.leading, 16)
                            .padding(.bottom, 10)

                            Spacer()
                        }

                        // Thin progress bar — very bottom edge
                        GeometryReader { barGeo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))

                                Rectangle()
                                    .fill(Color.white.opacity(0.85))
                                    .frame(width: playerManager.duration > 0
                                        ? CGFloat(playerManager.currentTime / playerManager.duration) * barGeo.size.width
                                        : 0)
                            }
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let pct = min(max(value.location.x / barGeo.size.width, 0), 1)
                                        playerManager.seek(to: Double(pct) * playerManager.duration)
                                    }
                            )
                        }
                        .frame(height: 3)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .statusBarHidden(true)
        .onAppear {
            playerManager.loadVideo(fileName: videoFileName)
        }
        .onDisappear {
            hideTimer?.invalidate()
            playerManager.cleanup()
        }
    }

    // MARK: - Stat box (broadcast style)
    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(0.5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }

    // MARK: - Error view
    private func errorView(_ error: String) -> some View {
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
    }

    // MARK: - Helpers
    private func handleTap() {
        if showControls {
            // Hide controls immediately
            hideTimer?.invalidate()
            withAnimation { showControls = false }
        } else {
            // Show controls, then auto-hide
            withAnimation { showControls = true }
            scheduleHide()
        }
    }

    private func scheduleHide() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation { showControls = false }
            }
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
        }
        // Method 2: Look in Videos subdirectory
        else if let url = Bundle.main.url(forResource: baseName, withExtension: "mp4", subdirectory: "Videos") {
            videoURL = url
        }
        // Method 3: Try with full filename in Videos folder
        else if let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "Videos") {
            videoURL = url
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
                    break
                }
            }
        }

        guard let url = videoURL else {
            isLoading = false
            loadError = "Video file '\(fileName)' not found in app bundle."
            return
        }

        loadFromURL(url)
    }

    private func loadFromURL(_ url: URL) {
        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)

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
                    break
                @unknown default:
                    break
                }
            }
        }

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
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }

        if let endObserver = endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }

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
