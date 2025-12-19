//
//  GolfSessionView.swift
//  Endless
//
//  Created by Seunghyun Bae on 11/8/25.
//

import SwiftUI

struct GolfSessionView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var videoStorage = VideoStorageManager.shared
    @State private var isSessionActive = true  // Start active by default
    @State private var exportURL: URL?
    @State private var saveMessage: String?
    @State private var shotCount = 0
    @State private var isSaving = false

    var body: some View {
        ZStack {
            // Camera view
            PoseSessionCameraView(
                isSessionActive: $isSessionActive,
                onExported: { url in
                    exportURL = url
                    isSaving = true
                    // Save to local Video library instead of camera roll
                    videoStorage.saveVideo(from: url, title: "Golf Session") { video in
                        DispatchQueue.main.async {
                            isSaving = false
                            if video != nil {
                                saveMessage = "Saved to Video Library!"
                                // Reset shot count for next session
                                shotCount = 0
                            } else {
                                saveMessage = "Save failed"
                            }
                            // Clear message after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                saveMessage = nil
                            }
                        }
                    }
                },
                onShotCaptured: {
                    shotCount += 1
                }
            )
            .ignoresSafeArea()

            // Overlay UI
            VStack {
                // Top status bar
                HStack(spacing: 12) {
                    // Recording indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isSessionActive ? Color.red : Color.gray)
                            .frame(width: 10, height: 10)
                            .overlay {
                                if isSessionActive {
                                    Circle()
                                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                                        .scaleEffect(1.5)
                                        .opacity(0.8)
                                }
                            }
                        Text(isSessionActive ? "Session Active" : "Session Ended")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())

                    Spacer()

                    // Shot counter
                    HStack(spacing: 4) {
                        Image(systemName: "figure.golf")
                            .font(.system(size: 12))
                        Text("Shots: \(shotCount)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Bottom controls
                VStack(spacing: 16) {
                    // Save status message
                    if let msg = saveMessage {
                        HStack(spacing: 8) {
                            Image(systemName: msg.contains("Saved") ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            Text(msg)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(msg.contains("Saved") ? .green : .red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.7))
                        .clipShape(Capsule())
                    }

                    if isSaving {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("Saving to Photos...")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.7))
                        .clipShape(Capsule())
                    }

                    // End Session button - always visible when session is active
                    if isSessionActive {
                        Button {
                            isSessionActive = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 20))
                                Text("End Session")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .shadow(color: .red.opacity(0.4), radius: 8, y: 4)
                        }
                    }
                }
                .padding(.bottom, 140) // Increased to clear the tab bar
            }
        }
        .onAppear {
            // Ensure session starts when view appears
            isSessionActive = true
        }
    }
}

#Preview {
    GolfSessionView()
        .environmentObject(NavigationManager())
}
