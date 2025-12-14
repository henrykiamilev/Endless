import SwiftUI
import AVFoundation

struct RecordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isRecording = false
    @State private var isFrontCamera = false
    @State private var hasPermission = false
    @State private var showPermissionAlert = false
    @State private var selectedMode = 1 // 0 = Photo, 1 = Video, 2 = Slo-Mo

    var body: some View {
        ZStack {
            // Camera preview placeholder
            Color.black
                .ignoresSafeArea()

            if hasPermission {
                cameraView
            } else {
                permissionView
            }
        }
        .onAppear {
            checkCameraPermission()
        }
    }

    // MARK: - Permission View

    private var permissionView: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(themeManager.theme.primary.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.theme.primary)
                )

            Text("Camera Access Required")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("We need camera access to record your golf swings and practice sessions.")
                .font(.system(size: 15))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: requestCameraPermission) {
                Text("Grant Permission")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.theme.textInverse)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 36)
                    .background(themeManager.theme.primary)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.theme.background)
    }

    // MARK: - Camera View

    private var cameraView: some View {
        ZStack {
            // Camera placeholder
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "1A1A1A"), Color(hex: "0A0A0A")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Demo overlay - golf swing silhouette
            Image(systemName: "figure.golf")
                .font(.system(size: 120))
                .foregroundColor(.white.opacity(0.1))

            // Top controls
            VStack {
                HStack {
                    Button(action: { navigationManager.navigateToHome() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 46, height: 46)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: { /* Toggle flash */ }) {
                        Image(systemName: "bolt.slash.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 46, height: 46)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()
            }

            // Recording indicator
            if isRecording {
                VStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)

                        Text("REC")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.top, 110)

                    Spacer()
                }
            }

            // Bottom controls
            VStack {
                Spacer()

                // Main controls
                HStack(alignment: .center, spacing: 36) {
                    // Gallery button
                    Button(action: { navigationManager.navigateToVideo() }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    // Record button
                    Button(action: { isRecording.toggle() }) {
                        ZStack {
                            Circle()
                                .stroke(isRecording ? Color.red : .white, lineWidth: 4)
                                .frame(width: 84, height: 84)

                            if isRecording {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.red)
                                    .frame(width: 34, height: 34)
                            } else {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 68, height: 68)
                            }
                        }
                    }

                    // Flip camera button
                    Button(action: { isFrontCamera.toggle() }) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 30)

                // Mode selector
                HStack(spacing: 0) {
                    modeButton("Photo", modeIndex: 0)
                    modeButton("Video", modeIndex: 1)
                    modeButton("Slo-Mo", modeIndex: 2)
                }
                .padding(.bottom, 100)
            }
        }
    }

    private func modeButton(_ title: String, modeIndex: Int) -> some View {
        let isSelected = selectedMode == modeIndex
        return Button(action: { selectedMode = modeIndex }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                if isSelected {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 40, height: 2)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 2)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Permission Helpers

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            hasPermission = false
        case .denied, .restricted:
            hasPermission = false
        @unknown default:
            hasPermission = false
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                hasPermission = granted
            }
        }
    }
}

#Preview {
    RecordView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
