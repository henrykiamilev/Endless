//
//  VideoView.swift
//  Endless
//
//  Simple video player view - scrollable videos from bundle
//

import SwiftUI
import AVKit

struct VideoView: View {
    @State private var scrollPos: Int? = 1
    @State private var players: [Int: AVPlayer] = [:]
    @State private var loadError: String?

    private let videoNames = ["swing-1", "swing-2", "swing-3"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(videoNames.enumerated()), id: \.offset) { index, videoName in
                    if let player = players[index] {
                        VideoPlayer(player: player)
                            .frame(width: 500, height: 500)
                            .id(index + 1)
                            .containerRelativeFrame(.vertical, alignment: .center)
                    } else {
                        // Placeholder while loading or if video not found
                        ZStack {
                            Color.black
                            if loadError != nil {
                                VStack(spacing: 12) {
                                    Image(systemName: "video.slash")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.gray)
                                    Text("Video not available")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.gray)
                                }
                            } else {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(width: 500, height: 500)
                        .id(index + 1)
                        .containerRelativeFrame(.vertical, alignment: .center)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $scrollPos, anchor: .center)
        .background(.black)
        .onAppear {
            loadVideos()
        }
    }

    private func loadVideos() {
        for (index, videoName) in videoNames.enumerated() {
            if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                players[index] = AVPlayer(url: url)
            } else {
                print("Could not find video: \(videoName).mp4")
                loadError = "Video files not found in bundle"
            }
        }
    }
}

#Preview {
    VideoView()
}

