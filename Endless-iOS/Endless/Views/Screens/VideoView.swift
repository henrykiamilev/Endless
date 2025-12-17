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
    let p1 = AVPlayer(url: Bundle.main.url(forResource: "swing-1", withExtension: "mp4")!)
    let p2 = AVPlayer(url: Bundle.main.url(forResource: "swing-2", withExtension: "mp4")!)
    let p3 = AVPlayer(url: Bundle.main.url(forResource: "swing-3", withExtension: "mp4")!)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VideoPlayer(player: p1)
                    .frame(width: 500, height: 500)
                    .id(1)
                    .containerRelativeFrame(.vertical, alignment: .center)
                VideoPlayer(player: p2)
                    .frame(width: 500, height: 500)
                    .id(2)
                    .containerRelativeFrame(.vertical, alignment: .center)
                VideoPlayer(player: p3)
                    .frame(width: 500, height: 500)
                    .id(3)
                    .containerRelativeFrame(.vertical, alignment: .center)
            }
        }
        .ignoresSafeArea()
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $scrollPos, anchor: .center)
        .background(.black)
    }
}

#Preview {
    VideoView()
}
