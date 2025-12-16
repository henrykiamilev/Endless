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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .onAppear {
                            setupPlayer()
                        }
                } else {
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

                // Custom overlay controls
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
                                        .fill(themeManager.theme.accentGreen)
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
                                        .fill(themeManager.theme.accentGreen)
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
        // Try to load from bundle
        if let url = Bundle.main.url(forResource: videoFileName.replacingOccurrences(of: ".mp4", with: ""), withExtension: "mp4") {
            player = AVPlayer(url: url)
            setupPlayer()
        } else {
            // Try loading from Videos folder in bundle
            if let url = Bundle.main.url(forResource: videoFileName, withExtension: nil, subdirectory: "Videos") {
                player = AVPlayer(url: url)
                setupPlayer()
            } else {
                print("Could not find video: \(videoFileName)")
            }
        }
    }

    private func setupPlayer() {
        guard let player = player else { return }

        // Get duration
        if let item = player.currentItem {
            let durationTime = item.asset.duration
            duration = CMTimeGetSeconds(durationTime)
        }

        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
            if let item = player.currentItem {
                duration = CMTimeGetSeconds(item.duration)
            }
        }

        // Auto-play
        player.play()
        isPlaying = true
        isLoading = false

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
