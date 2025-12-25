import SwiftUI
import PhotosUI
import AVKit

/// View for selecting a swing video from camera roll and getting AI analysis
struct SwingVideoPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var swingVideoManager = SwingVideoManager.shared
    @ObservedObject private var swingAnalyzer = SwingAnalyzer.shared

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedVideoURL: URL?
    @State private var selectedVideoType: SwingVideoType = .downTheLine
    @State private var annotation = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var importedVideo: ManagedSwingVideo?
    @State private var showingAnalysis = false
    @State private var analysisResult: SwingAnalysisResult?

    // Import flow states
    enum ImportState {
        case selecting
        case configuring
        case importing
        case analyzing
        case complete
    }
    @State private var importState: ImportState = .selecting

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.theme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch importState {
                        case .selecting:
                            selectingView
                        case .configuring:
                            configuringView
                        case .importing:
                            importingView
                        case .analyzing:
                            analyzingView
                        case .complete:
                            completeView
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.primary)
                        Text("Import Swing Video")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                if let newItem = newItem {
                    loadVideo(from: newItem)
                }
            }
        }
        .sheet(isPresented: $showingAnalysis) {
            if let video = importedVideo {
                SwingVideoAnalysisView(video: video)
                    .environmentObject(themeManager)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Selecting View

    private var selectingView: some View {
        VStack(spacing: 32) {
            // Header illustration
            ZStack {
                Circle()
                    .fill(themeManager.theme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(themeManager.theme.primary.opacity(0.15))
                    .frame(width: 90, height: 90)

                Image(systemName: "figure.golf")
                    .font(.system(size: 44))
                    .foregroundColor(themeManager.theme.primary)
            }
            .padding(.top, 40)

            VStack(spacing: 12) {
                Text("Select a Swing Video")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("Choose a video from your camera roll to get AI-powered swing analysis")
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Video picker button
            PhotosPicker(
                selection: $selectedItem,
                matching: .videos,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20))
                    Text("Choose from Library")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(themeManager.theme.primary)
                .cornerRadius(16)
            }

            // Tips
            VStack(alignment: .leading, spacing: 16) {
                Text("FOR BEST RESULTS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(themeManager.theme.textMuted)

                tipRow(icon: "camera.viewfinder", text: "Record from down-the-line or face-on angle")
                tipRow(icon: "sun.max", text: "Ensure good lighting for clear visibility")
                tipRow(icon: "person.fill", text: "Full body should be visible in frame")
                tipRow(icon: "clock", text: "Include your full swing motion")
            }
            .padding(20)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)
            .padding(.top, 20)

            // Capacity indicator
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < swingVideoManager.videoCount ?
                              themeManager.theme.primary :
                              themeManager.theme.border)
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Text("\(swingVideoManager.videoCount)/5 swing videos")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(.top, 8)

            Spacer(minLength: 40)
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.primary)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)

            Spacer()
        }
    }

    // MARK: - Configuring View

    private var configuringView: some View {
        VStack(spacing: 24) {
            // Video preview
            if let videoURL = selectedVideoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 220)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.theme.border, lineWidth: 1)
                    )
            }

            // Video type selection
            VStack(alignment: .leading, spacing: 12) {
                Text("SWING ANGLE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(themeManager.theme.textMuted)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(SwingVideoType.allCases, id: \.self) { type in
                        videoTypeButton(type)
                    }
                }
            }
            .padding(20)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)

            // Annotation input
            VStack(alignment: .leading, spacing: 12) {
                Text("NOTES (OPTIONAL)")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(themeManager.theme.textMuted)

                TextField("What are you working on?", text: $annotation, axis: .vertical)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(2...4)
                    .padding(14)
                    .background(themeManager.theme.backgroundSecondary)
                    .cornerRadius(14)
            }
            .padding(20)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)

            Spacer(minLength: 20)

            // Action buttons
            VStack(spacing: 12) {
                Button(action: importAndAnalyze) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                        Text("Import & Analyze")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.theme.primary)
                    .cornerRadius(16)
                }
                .disabled(!swingVideoManager.canAddMoreVideos)

                Button(action: {
                    selectedItem = nil
                    selectedVideoURL = nil
                    importState = .selecting
                }) {
                    Text("Choose Different Video")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }

            if !swingVideoManager.canAddMoreVideos {
                Text("Maximum 5 swing videos. Delete one to add more.")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.error)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func videoTypeButton(_ type: SwingVideoType) -> some View {
        let isSelected = selectedVideoType == type
        return Button(action: { selectedVideoType = type }) {
            VStack(spacing: 8) {
                Image(systemName: iconForType(type))
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : themeManager.theme.primary)

                Text(type.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .white : themeManager.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? themeManager.theme.primary : themeManager.theme.backgroundSecondary)
            .cornerRadius(14)
        }
    }

    private func iconForType(_ type: SwingVideoType) -> String {
        switch type {
        case .downTheLine: return "arrow.right"
        case .faceOn: return "person.fill"
        case .behindView: return "arrow.backward"
        case .frontView: return "arrow.forward"
        }
    }

    // MARK: - Importing View

    private var importingView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(themeManager.theme.cardBackground, lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(themeManager.theme.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)

                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.theme.primary)
            }

            Text("Importing Video...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("Saving to your swing videos")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)

            Spacer()
        }
        .onAppear {
            isLoading = true
        }
    }

    // MARK: - Analyzing View

    private var analyzingView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(themeManager.theme.cardBackground, lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: swingAnalyzer.analysisProgress)
                    .stroke(themeManager.theme.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.theme.primary)
            }

            Text("Analyzing Your Swing...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("AI is reviewing your technique using pose detection")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Analysis steps
            VStack(alignment: .leading, spacing: 12) {
                analysisStep(icon: "video", text: "Extracting frames", isComplete: swingAnalyzer.analysisProgress > 0.2)
                analysisStep(icon: "figure.golf", text: "Detecting pose", isComplete: swingAnalyzer.analysisProgress > 0.5)
                analysisStep(icon: "chart.bar", text: "Analyzing technique", isComplete: swingAnalyzer.analysisProgress > 0.75)
                analysisStep(icon: "lightbulb", text: "Generating tips", isComplete: swingAnalyzer.analysisProgress > 0.9)
            }
            .padding(20)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)
            .padding(.top, 20)

            Spacer()
        }
    }

    private func analysisStep(icon: String, text: String, isComplete: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isComplete ? themeManager.theme.primary : themeManager.theme.backgroundSecondary)
                    .frame(width: 32, height: 32)

                Image(systemName: isComplete ? "checkmark" : icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isComplete ? .white : themeManager.theme.textMuted)
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isComplete ? themeManager.theme.textPrimary : themeManager.theme.textSecondary)

            Spacer()
        }
    }

    // MARK: - Complete View

    private var completeView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success animation
            ZStack {
                Circle()
                    .fill(themeManager.theme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(themeManager.theme.primary)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("Analysis Complete!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                if let score = analysisResult?.overallScore {
                    HStack(spacing: 8) {
                        Text("Your Score:")
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.theme.textSecondary)

                        Text("\(score)/100")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeManager.theme.primary)
                    }
                }
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    showingAnalysis = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16))
                        Text("View Full Analysis")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.theme.primary)
                    .cornerRadius(16)
                }

                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(themeManager.theme.cardBackground)
                        .cornerRadius(14)
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Actions

    private func loadVideo(from item: PhotosPickerItem) {
        isLoading = true

        Task {
            do {
                // Load video data
                guard let movie = try await item.loadTransferable(type: VideoTransferable.self) else {
                    throw VideoImportError.loadFailed
                }

                await MainActor.run {
                    selectedVideoURL = movie.url
                    importState = .configuring
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load video: \(error.localizedDescription)"
                    showingError = true
                    isLoading = false
                }
            }
        }
    }

    private func importAndAnalyze() {
        guard let videoURL = selectedVideoURL else { return }

        importState = .importing

        // Add swing video
        swingVideoManager.addSwingVideo(
            from: videoURL,
            type: selectedVideoType,
            annotation: annotation
        ) { video in
            if let video = video {
                importedVideo = video
                importState = .analyzing

                // Start analysis
                Task {
                    let result = await swingVideoManager.analyzeSwingVideo(video)

                    await MainActor.run {
                        analysisResult = result
                        importState = .complete
                    }
                }
            } else {
                errorMessage = "Failed to save video. Please try again."
                showingError = true
                importState = .configuring
            }
        }
    }
}

// MARK: - Video Transferable

struct VideoTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            // Create a unique file name in temp directory
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")

            // Copy the file
            try FileManager.default.copyItem(at: received.file, to: tempURL)

            return VideoTransferable(url: tempURL)
        }
    }
}

enum VideoImportError: LocalizedError {
    case loadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Failed to load video from library"
        case .saveFailed:
            return "Failed to save video"
        }
    }
}

#Preview {
    SwingVideoPickerView()
        .environmentObject(ThemeManager())
}
