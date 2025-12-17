//
//  GolfSessionView.swift
//  Endless
//
//  Created by Seunghyun Bae on 11/8/25.
//

import SwiftUI
import Photos

struct GolfSessionView: View {
    @State private var isSessionActive = false
    @State private var exportURL: URL?
    @State private var saveMessage: String?
    @State private var shotCount = 0

    var body: some View {
        VStack(spacing: 12) {
            PoseSessionCameraView(
                isSessionActive: $isSessionActive,
                onExported: { url in
                    exportURL = url
                    saveToPhotos(url) { ok, err in
                        saveMessage = ok ? "Saved to Photos" : "Save failed: \(err?.localizedDescription ?? "")"
                    }
                },
                onShotCaptured: {
                    shotCount += 1
                }
            )
            .overlay(alignment: .bottom) {
                VStack(spacing: 6) {
                    Text(isSessionActive ? "Session: Recording swings..." : "Session: Idle")
                        .font(.callout).padding(6)
                        .background(.black.opacity(0.5)).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("Shots: \(shotCount)")
                        .font(.footnote).padding(4)
                        .background(.black.opacity(0.45)).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.top, 10)
            }

            HStack {
                Button {
                    isSessionActive = true
                } label: { Label("Start Session", systemImage: "play.circle") }
                .buttonStyle(.borderedProminent)
                .disabled(isSessionActive)

                Button(role: .destructive) {
                    isSessionActive = false
                } label: { Label("End Session", systemImage: "stop.circle") }
                .buttonStyle(.bordered)
                .disabled(!isSessionActive)
            }

            if let msg = saveMessage {
                Text(msg).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

private func saveToPhotos(_ url: URL, completion: @escaping (Bool, Error?) -> Void) {
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        guard status == .authorized || status == .limited else {
            completion(false, NSError(domain: "photos", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photos permission denied"]))
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { ok, err in
            completion(ok, err)
        }
    }
}

#Preview {
    GolfSessionView()
}
