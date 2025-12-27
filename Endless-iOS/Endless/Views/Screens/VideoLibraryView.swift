import SwiftUI
import Combine

struct VideoLibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var videoStorage = VideoStorageManager.shared
    @ObservedObject private var swingVideoManager = SwingVideoManager.shared
    @ObservedObject private var highlightGenerator = HighlightReelGenerator.shared
    @ObservedObject private var filmHighlights = FilmHighlightsManager.shared
    @StateObject private var strokesGainedVM = StrokesGainedViewModel.shared

    @State private var showingMenu = false
    @State private var showingAIAnalysis = false
    @State private var selectedVideoForAI: Video?
    @State private var showingHighlightGenerator = false
    @State private var highlightPrompt = ""
    @State private var selectedCourses: Set<String> = []
    @State private var isGeneratingHighlight = false
    @State private var showingGeneratedReel = false
    @State private var generatedReelResult: HighlightReelResult?
    @State private var selectedVideoForPlayback: Video?
    @State private var showingDeleteConfirmation = false
    @State private var videoToDelete: Video?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSwingAnalysis = false
    @State private var selectedSwingVideo: ManagedSwingVideo?
    @State private var showingAddVideoOptions = false
    @State private var showingVideoPicker = false
    @State private var showingComingSoon = false
    @State private var comingSoonFeature = ""
    @State private var showingShareOptions = false
    @State private var videoToShare: Video?
    @State private var showingShareSuccess = false
    @State private var shareSuccessMessage = ""
    @State private var selectedSGCategory: SGCategory?
    @State private var isStrokesGainedExpanded = false
    @State private var showingStrokesGainedOverview = false
    @FocusState private var isPromptFocused: Bool

    private let availableCourses = ["Oakmont CC", "Pebble Beach", "Del Mar", "Torrey Pines"]

    /// All videos including user recordings
    private var allVideos: [Video] {
        videoStorage.allVideos
    }

    /// Check if a video is deletable (user-recorded videos only)
    private func isDeletable(_ video: Video) -> Bool {
        videoStorage.userVideos.contains(where: { $0.id == video.id })
    }

    var body: some View {
        VStack(spacing: 0) {
            // Branded Header - outside ScrollView
            brandedHeader

            // Toggle - outside ScrollView for reliable tapping
            ToggleButton(options: ["Video", "Stats"], selectedIndex: $navigationManager.videoLibrarySubTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Content
                    if navigationManager.videoLibrarySubTab == 0 {
                        videoTabContent
                    } else {
                        statsTabContent
                    }

                    // Footer branding
                    footerBranding

                    Spacer(minLength: 120)
                }
            }
        }
        .background(themeManager.theme.background)
        .sheet(isPresented: $showingAIAnalysis) {
            AIAnalysisView(video: selectedVideoForAI)
        }
        .sheet(isPresented: $showingGeneratedReel) {
            if let result = generatedReelResult {
                GeneratedHighlightReelView(
                    result: result,
                    prompt: highlightPrompt,
                    courses: Array(selectedCourses)
                )
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Coming Soon", isPresented: $showingComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(comingSoonFeature) is still in development. Stay tuned for updates!")
        }
        .fullScreenCover(item: $selectedVideoForPlayback) { video in
            if let videoFileName = video.videoFileName {
                VideoPlayerView(videoFileName: videoFileName, videoTitle: video.title)
                    .environmentObject(themeManager)
            } else {
                // Fallback view if video data is missing
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray)
                        Text("Video not available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                        Button("Close") {
                            selectedVideoForPlayback = nil
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
        .alert("Delete Video", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                videoToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let video = videoToDelete {
                    withAnimation {
                        videoStorage.deleteVideo(video)
                    }
                    videoToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this video? This action cannot be undone.")
        }
        .confirmationDialog("Share Video", isPresented: $showingShareOptions, titleVisibility: .visible) {
            Button("Add to Film Highlights") {
                if let video = videoToShare, let videoFileName = video.videoFileName {
                    let videoURL = URL(fileURLWithPath: videoFileName)
                    filmHighlights.saveHighlight(from: videoURL, title: video.title) { success in
                        if success {
                            shareSuccessMessage = "Video added to Film Highlights!"
                            showingShareSuccess = true
                        } else {
                            errorMessage = "Failed to add video to Film Highlights"
                            showingError = true
                        }
                        videoToShare = nil
                    }
                }
            }
            Button("Save to Camera Roll") {
                if let video = videoToShare, let videoFileName = video.videoFileName {
                    let videoURL = URL(fileURLWithPath: videoFileName)
                    filmHighlights.saveToCameraRoll(from: videoURL) { success, error in
                        if success {
                            shareSuccessMessage = "Video saved to Camera Roll!"
                            showingShareSuccess = true
                        } else {
                            errorMessage = error?.localizedDescription ?? "Failed to save video"
                            showingError = true
                        }
                        videoToShare = nil
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                videoToShare = nil
            }
        } message: {
            Text("Choose where to share your video")
        }
        .alert("Success", isPresented: $showingShareSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(shareSuccessMessage)
        }
        .sheet(item: $selectedSGCategory) { category in
            CategoryDetailView(category: category)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingStrokesGainedOverview) {
            NavigationView {
                StrokesGainedOverviewView()
                    .environmentObject(themeManager)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showingStrokesGainedOverview = false }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.theme.textSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(themeManager.theme.cardBackground)
                                    .clipShape(Circle())
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Branded Header

    private var brandedHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { showingMenu = true }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 48, height: 48)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                Spacer()

                // Endless Logo
                EndlessLogo(size: 48, showText: false)
            }
            .padding(.bottom, 28)

            // Title with accent line
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("VIDEO")
                        .font(.system(size: 48, weight: .heavy))
                        .tracking(-2)
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("LIBRARY")
                        .font(.system(size: 48, weight: .heavy))
                        .tracking(-2)
                        .foregroundColor(themeManager.theme.primary)
                }

                Spacer()

                // Video count badge
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(allVideos.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    Text("VIDEOS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .sheet(isPresented: $showingMenu) {
            MenuSheetView()
        }
    }

    // MARK: - Video Tab

    private var videoTabContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section label with icon - MATCH VIDEOS AT TOP
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.primary)
                Text("MATCH VIDEOS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Videos grid with better spacing
            if allVideos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "video")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                    Text("No videos yet")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                    Text("Record your golf sessions to see them here")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
                .padding(.horizontal, 20)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ], spacing: 18) {
                    ForEach(allVideos) { video in
                        VideoCard(
                            video: video,
                            action: {
                                // Play video when tapped
                                selectedVideoForPlayback = video
                            },
                            onDelete: isDeletable(video) ? {
                                videoToDelete = video
                                showingDeleteConfirmation = true
                            } : nil,
                            onShare: video.videoFileName != nil ? {
                                videoToShare = video
                                showingShareOptions = true
                            } : nil
                        )
                        .contextMenu {
                            Button(action: {
                                selectedVideoForPlayback = video
                            }) {
                                Label("Play Video", systemImage: "play.fill")
                            }
                            Button(action: {
                                videoToShare = video
                                showingShareOptions = true
                            }) {
                                Label("Share Video", systemImage: "square.and.arrow.up")
                            }
                            Button(action: {
                                selectedVideoForAI = video
                                showingAIAnalysis = true
                            }) {
                                Label("AI Analysis", systemImage: "sparkles")
                            }
                            if isDeletable(video) {
                                Divider()
                                Button(role: .destructive, action: {
                                    videoToDelete = video
                                    showingDeleteConfirmation = true
                                }) {
                                    Label("Delete Video", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }

            // AI Features Section - BELOW VIDEOS
            aiAnalysisSection
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
        }
    }

    // MARK: - AI Analysis Section

    private var aiAnalysisSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.accentGreen)
                Text("ENDLESS AI")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Create Highlight Reel Card
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [themeManager.theme.accentGreen, themeManager.theme.accentGreen.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(systemName: "film.stack")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create Highlight Reel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text("Powered by AI")
                            .font(.system(size: 11))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    Spacer()
                }
                .padding(16)

                // Prompt input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Describe your perfect highlight reel... (e.g., \"Create a 2-minute reel focusing on my short game and driving accuracy from my last 3 matches\")")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(3)

                    // Disabled text box - tapping shows Coming Soon
                    Button(action: {
                        comingSoonFeature = "Highlight Reel"
                        showingComingSoon = true
                    }) {
                        HStack {
                            Text("Enter your prompt here...")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textMuted)
                            Spacer()
                        }
                        .frame(height: 60, alignment: .topLeading)
                        .padding(10)
                        .background(themeManager.theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(themeManager.theme.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Course filter tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(availableCourses, id: \.self) { course in
                                CourseFilterTag(
                                    name: course,
                                    isSelected: selectedCourses.contains(course)
                                ) {
                                    comingSoonFeature = "Highlight Reel"
                                    showingComingSoon = true
                                }
                            }
                        }
                    }

                    // Generate button
                    Button(action: {
                        comingSoonFeature = "Highlight Reel"
                        showingComingSoon = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                            Text("Generate Highlight Reel")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [themeManager.theme.accentGreen, themeManager.theme.accentGreen.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.06), radius: 16, x: 0, y: 8)

            // My Swing Videos Section
            mySwingVideosSection
        }
    }

    private func generateHighlightReel() {
        // Dismiss keyboard
        isPromptFocused = false

        guard !videoStorage.allVideos.isEmpty else {
            errorMessage = "No videos available. Record some golf sessions first!"
            showingError = true
            return
        }

        isGeneratingHighlight = true

        Task {
            do {
                let config = HighlightReelConfig(
                    prompt: highlightPrompt,
                    selectedCourses: Array(selectedCourses)
                )

                let result = try await highlightGenerator.generateHighlightReel(
                    from: videoStorage.allVideos,
                    config: config
                )

                await MainActor.run {
                    isGeneratingHighlight = false
                    generatedReelResult = result
                    showingGeneratedReel = true
                    // Reset the prompt and course selection after successful generation
                    highlightPrompt = ""
                    selectedCourses = []
                }
            } catch {
                await MainActor.run {
                    isGeneratingHighlight = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }

    // MARK: - My Swing Videos Section

    private var mySwingVideosSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Swing Videos")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("Upload up to 5 swing videos with annotations")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                // Progress indicator
                Text("\(swingVideoManager.videoCount)/5")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(themeManager.theme.background)
                    .clipShape(Capsule())
            }
            .padding(16)

            Divider()
                .background(themeManager.theme.border)
                .padding(.horizontal, 16)

            // Video list
            if swingVideoManager.swingVideos.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.theme.textMuted)

                    Text("No swing videos yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)

                    Text("Add videos to get AI analysis")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(swingVideoManager.swingVideos) { video in
                        SwingVideoRow(
                            title: video.type.displayName,
                            date: video.dateString,
                            annotation: video.annotation,
                            hasAnalysis: video.analysisResult != nil,
                            score: video.analysisResult?.overallScore,
                            onAnalyze: {
                                comingSoonFeature = "Swing Analysis"
                                showingComingSoon = true
                            },
                            onDelete: {
                                swingVideoManager.deleteSwingVideo(video)
                            }
                        )
                    }
                }
                .padding(16)
            }

            // Add more videos button
            Button(action: {
                comingSoonFeature = "Swing Videos"
                showingComingSoon = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 14))
                    Text("Add Swing Video")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(themeManager.theme.accentGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(themeManager.theme.accentGreen.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.06), radius: 16, x: 0, y: 8)
        .sheet(isPresented: $showingSwingAnalysis) {
            if let video = selectedSwingVideo {
                SwingVideoAnalysisView(video: video)
                    .environmentObject(themeManager)
            }
        }
        .confirmationDialog("Add Swing Video", isPresented: $showingAddVideoOptions, titleVisibility: .visible) {
            Button("Choose from Camera Roll") {
                showingVideoPicker = true
            }
            Button("Record New Video") {
                navigationManager.navigateToRecord()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Select a video from your library or record a new swing")
        }
        .sheet(isPresented: $showingVideoPicker) {
            SwingVideoPickerView()
                .environmentObject(themeManager)
        }
    }

    // MARK: - Stats Tab

    private var statsTabContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Stats Overview Card
            statsOverviewCard

            // Strokes Gained Section
            strokesGainedSection

            // Recent Round Stats
            sectionView(label: "RECENT ROUND STATS", icon: "chart.bar.fill") {
                VStack(spacing: 0) {
                    StatBar(label: "Greens in Regulation", value: "--", percentage: 0)
                    StatBar(label: "Fairways Hit", value: "--", percentage: 0)
                    StatBar(label: "Avg Putts per Round", value: "--", percentage: 0)
                    StatBar(label: "Scoring Average", value: "--", percentage: 0, showPercentageBar: false)
                }
                .padding(20)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }

            // Round History
            sectionView(label: "ROUND HISTORY", icon: "clock.fill") {
                VStack(spacing: 0) {
                    ForEach(MockData.roundHistory) { round in
                        RoundHistoryCard(round: round)
                        if round.id != MockData.roundHistory.last?.id {
                            Rectangle()
                                .fill(themeManager.theme.border)
                                .frame(height: 1)
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(18)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Stats Overview Card

    private var statsOverviewCard: some View {
        HStack(spacing: 0) {
            statItem(value: "--", label: "AVG SCORE", icon: "flag.fill")

            Rectangle()
                .fill(themeManager.theme.border)
                .frame(width: 1)
                .padding(.vertical, 16)

            statItem(value: "0", label: "ROUNDS", icon: "repeat")

            Rectangle()
                .fill(themeManager.theme.border)
                .frame(width: 1)
                .padding(.vertical, 16)

            statItem(value: "--", label: "HANDICAP", icon: "chart.line.uptrend.xyaxis")
        }
        .padding(.vertical, 20)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(themeManager.theme.primary)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Strokes Gained Section

    private var strokesGainedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header with expand button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isStrokesGainedExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.primary)
                    Text("STROKES GAINED")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(themeManager.theme.textSecondary)

                    Spacer()

                    Image(systemName: isStrokesGainedExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Main card
            VStack(spacing: 0) {
                // Total SG Header - tappable to see full overview
                Button(action: { showingStrokesGainedOverview = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total SG")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.theme.textSecondary)

                            if let summary = strokesGainedVM.currentSummary,
                               !summary.sgByCategory.isEmpty {
                                Text(formatSG(summary.totalSG))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(sgColor(for: summary.totalSG))
                            } else {
                                Text("--")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(themeManager.theme.textMuted)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            if strokesGainedVM.currentSummary == nil {
                                Text("Complete a round to see data")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textMuted)
                            } else {
                                Text("Tap for details")
                                    .font(.system(size: 11))
                                    .foregroundColor(themeManager.theme.textMuted)
                            }

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.theme.textMuted)
                        }
                    }
                    .padding(20)
                }
                .buttonStyle(PlainButtonStyle())

                // Expanded content
                if isStrokesGainedExpanded {
                    Divider()
                        .background(themeManager.theme.border)
                        .padding(.horizontal, 16)

                    // Category breakdown - each tile is clickable
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        sgCategoryTile(.offTheTee)
                        sgCategoryTile(.approach)
                        sgCategoryTile(.shortGame)
                        sgCategoryTile(.putting)
                    }
                    .padding(16)

                    // Insights preview
                    if let summary = strokesGainedVM.currentSummary,
                       !summary.sgByCategory.isEmpty {
                        Divider()
                            .background(themeManager.theme.border)
                            .padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            // Strength and Weakness
                            HStack(spacing: 16) {
                                if let strength = summary.biggestStrength,
                                   let strengthValue = summary.sgByCategory[strength] {
                                    insightPill(
                                        icon: "arrow.up.circle.fill",
                                        label: "Strength",
                                        category: strength.displayName,
                                        value: strengthValue,
                                        isPositive: true
                                    )
                                }

                                if let leak = summary.biggestLeak,
                                   let leakValue = summary.sgByCategory[leak] {
                                    insightPill(
                                        icon: "arrow.down.circle.fill",
                                        label: "Focus Area",
                                        category: leak.displayName,
                                        value: leakValue,
                                        isPositive: false
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }

                    // Explore details button
                    Button(action: { showingStrokesGainedOverview = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                            Text("Explore Full Analysis")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(themeManager.theme.accentGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(themeManager.theme.accentGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(themeManager.theme.cardBackground)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    private func insightPill(icon: String, label: String, category: String, value: Double, isPositive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(isPositive ? themeManager.theme.accentGreen : themeManager.theme.error)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(themeManager.theme.textMuted)
            }

            HStack(spacing: 6) {
                Text(category)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(formatSG(value))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isPositive ? themeManager.theme.accentGreen : themeManager.theme.error)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(themeManager.theme.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func sgCategoryTile(_ category: SGCategory) -> some View {
        Button(action: { selectedSGCategory = category }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.accentGreen)
                        .frame(width: 28, height: 28)
                        .background(themeManager.theme.accentGreen.opacity(0.15))
                        .clipShape(Circle())

                    Text(category.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(themeManager.theme.textMuted)
                }

                if let summary = strokesGainedVM.currentSummary,
                   let sg = summary.sgByCategory[category] {
                    Text(formatSG(sg))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(sgColor(for: sg))
                } else {
                    Text("--")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.theme.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(themeManager.theme.background.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatSG(_ value: Double) -> String {
        if value >= 0 {
            return String(format: "+%.1f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }

    private func sgColor(for value: Double) -> Color {
        if value > 0.5 {
            return themeManager.theme.accentGreen
        } else if value < -0.5 {
            return themeManager.theme.error
        } else {
            return themeManager.theme.textPrimary
        }
    }

    // MARK: - Footer Branding

    private var footerBranding: some View {
        HStack(spacing: 8) {
            EndlessLogo(size: 24, showText: false)
            Text("Powered by Endless")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Section Helper

    private func sectionView<Content: View>(label: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.primary)
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            content()
        }
    }
}

// MARK: - Filter Sheet View

struct FilterSheetView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedDateRange = "All Time"
    @State private var selectedCourse = "All Courses"

    private let dateRanges = ["Last 7 Days", "Last 30 Days", "Last 3 Months", "All Time"]
    private let courses = ["All Courses", "Oakmont CC", "Pebble Beach", "Del Mar", "Torrey Pines"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Logo header
                HStack(spacing: 10) {
                    EndlessLogo(size: 32, showText: false)
                    Text("Filter Videos")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                List {
                    Section {
                        ForEach(dateRanges, id: \.self) { range in
                            Button(action: { selectedDateRange = range }) {
                                HStack {
                                    Text(range)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(themeManager.theme.textPrimary)
                                    Spacer()
                                    if selectedDateRange == range {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(themeManager.theme.primary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Date Range")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                    }

                    Section {
                        ForEach(courses, id: \.self) { course in
                            Button(action: { selectedCourse = course }) {
                                HStack {
                                    Text(course)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(themeManager.theme.textPrimary)
                                    Spacer()
                                    if selectedCourse == course {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(themeManager.theme.primary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Course")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                    }
                }
                .listStyle(.insetGrouped)

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {
                        selectedDateRange = "All Time"
                        selectedCourse = "All Courses"
                    }) {
                        Text("Reset")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeManager.theme.cardBackground)
                            .cornerRadius(24)
                    }

                    Button(action: { dismiss() }) {
                        Text("Apply Filters")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.theme.textInverse)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeManager.theme.primary)
                            .cornerRadius(24)
                    }
                }
                .padding(20)
                .background(themeManager.theme.background)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - AI Feature Button

struct AIFeatureButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.accentGreen.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.theme.accentGreen)
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(themeManager.theme.background.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AI Analysis View

struct AIAnalysisView: View {
    let video: Video?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isAnalyzing = true
    @State private var selectedTab = 0
    @State private var showingChat = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with video info
                    headerSection

                    // Analysis status
                    if isAnalyzing {
                        analyzingView
                    } else {
                        // Analysis results
                        analysisResults
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
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
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.accentGreen)
                        Text("AI Analysis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
                }
            }
            .onAppear {
                // Simulate analysis delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isAnalyzing = false
                    }
                }
            }
        }
        .sheet(isPresented: $showingChat) {
            AICoachChatView()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Video thumbnail placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1A3A2A"), Color(hex: "0D1F15")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                VStack(spacing: 12) {
                    Image(systemName: "figure.golf")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.4))

                    Text(video?.title ?? "Selected Video")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            // Video info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(video?.title ?? "Video Analysis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(video?.date ?? "Today")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                Button(action: { showingChat = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 12))
                        Text("Ask AI")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(themeManager.theme.accentGreen)
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            // Animated analysis indicator
            ZStack {
                Circle()
                    .stroke(themeManager.theme.cardBackground, lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(themeManager.theme.accentGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnalyzing)

                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.theme.accentGreen)
            }

            Text("Analyzing your swing...")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("Our AI is reviewing your technique and comparing it to professional standards")
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }

    private var analysisResults: some View {
        VStack(spacing: 20) {
            // Overall score
            overallScoreCard

            // Tab selection
            ToggleButton(options: ["Breakdown", "Tips", "Drills"], selectedIndex: $selectedTab)

            // Tab content
            if selectedTab == 0 {
                breakdownSection
            } else if selectedTab == 1 {
                tipsSection
            } else {
                drillsSection
            }
        }
    }

    private var overallScoreCard: some View {
        HStack(spacing: 20) {
            // Score circle
            ZStack {
                Circle()
                    .stroke(themeManager.theme.cardBackground, lineWidth: 8)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: 0.82)
                    .stroke(themeManager.theme.accentGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("82")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    Text("/ 100")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Great Swing!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("Your technique is solid with room for improvement in tempo and follow-through.")
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .lineLimit(3)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                    Text("+5 from last analysis")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(themeManager.theme.accentGreen)
            }
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var breakdownSection: some View {
        VStack(spacing: 12) {
            analysisRow(title: "Grip", score: 85, feedback: "Solid neutral grip position")
            analysisRow(title: "Stance", score: 80, feedback: "Good width, slight toe flare")
            analysisRow(title: "Backswing", score: 88, feedback: "Full shoulder turn achieved")
            analysisRow(title: "Downswing", score: 78, feedback: "Maintain lag longer")
            analysisRow(title: "Impact", score: 82, feedback: "Square face at contact")
            analysisRow(title: "Follow-through", score: 75, feedback: "Extend more toward target")
        }
    }

    private func analysisRow(title: String, score: Int, feedback: String) -> some View {
        HStack(spacing: 14) {
            // Score indicator
            ZStack {
                Circle()
                    .fill(scoreColor(score).opacity(0.15))
                    .frame(width: 44, height: 44)

                Text("\(score)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(scoreColor(score))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(feedback)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 85 {
            return themeManager.theme.accentGreen
        } else if score >= 70 {
            return Color(hex: "F59E0B")
        } else {
            return themeManager.theme.error
        }
    }

    private var tipsSection: some View {
        VStack(spacing: 12) {
            tipCard(
                icon: "hand.raised.fill",
                title: "Maintain Lag Longer",
                description: "Focus on keeping your wrists cocked until your hands pass your right thigh."
            )
            tipCard(
                icon: "arrow.right.circle.fill",
                title: "Extend Through Impact",
                description: "Push your arms toward the target after contact for more power and accuracy."
            )
            tipCard(
                icon: "metronome.fill",
                title: "Smooth Tempo",
                description: "Try a 3:1 backswing to downswing ratio for better timing."
            )
        }
    }

    private func tipCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.accentGreen.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.theme.accentGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var drillsSection: some View {
        VStack(spacing: 12) {
            drillCard(
                title: "Lag Drill",
                duration: "10 min",
                description: "Practice maintaining wrist angle with slow-motion swings"
            )
            drillCard(
                title: "Extension Drill",
                duration: "15 min",
                description: "Use alignment sticks to practice full extension"
            )
            drillCard(
                title: "Tempo Training",
                duration: "20 min",
                description: "Swing with a metronome at 60 BPM"
            )
        }
    }

    private func drillCard(title: String, duration: String, description: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(themeManager.theme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: "figure.golf")
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.theme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Spacer()

                    Text(duration)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Capsule())
                }

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - AI Coach Chat View

struct AICoachChatView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var aiCoach = AICoachService.shared
    @State private var messageText = ""
    @State private var scrollToBottom = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(aiCoach.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if aiCoach.isTyping {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: aiCoach.messages.count) {
                        if let lastMessage = aiCoach.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input area
                HStack(spacing: 12) {
                    TextField("Ask your AI coach...", text: $messageText)
                        .font(.system(size: 15))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Capsule())
                        .onSubmit {
                            sendMessage()
                        }

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(messageText.isEmpty ? themeManager.theme.textSecondary : themeManager.theme.accentGreen)
                    }
                    .disabled(messageText.isEmpty || aiCoach.isTyping)
                }
                .padding(16)
                .background(themeManager.theme.background)
            }
            .background(themeManager.theme.background)
            .navigationTitle("AI Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.textPrimary)
                }
            }
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let text = messageText
        messageText = ""
        aiCoach.sendMessage(text)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animating = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(themeManager.theme.textSecondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { animating = true }
    }
}

struct MessageBubble: View {
    let message: AICoachMessage
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            if message.isUser { Spacer() }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if !message.isUser {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("AI Coach")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(themeManager.theme.accentGreen)
                }

                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(message.isUser ? .white : themeManager.theme.textPrimary)
                    .padding(12)
                    .background(
                        message.isUser
                            ? themeManager.theme.accentGreen
                            : themeManager.theme.cardBackground
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - Course Filter Tag

struct CourseFilterTag: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : themeManager.theme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? themeManager.theme.accentGreen
                        : themeManager.theme.background
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : themeManager.theme.border, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Swing Video Row

struct SwingVideoRow: View {
    let title: String
    let date: String
    let annotation: String
    var hasAnalysis: Bool = false
    var score: Int? = nil
    let onAnalyze: () -> Void
    var onDelete: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Video thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(themeManager.theme.background)
                    .frame(width: 60, height: 60)

                Image(systemName: "figure.golf")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.theme.accentGreen.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    if hasAnalysis {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(themeManager.theme.accentGreen)
                    }
                }

                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.theme.textSecondary)

                if !annotation.isEmpty {
                    Text(annotation)
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textMuted)
                        .lineLimit(1)
                }

                if let score = score {
                    HStack(spacing: 4) {
                        Text("Score:")
                            .font(.system(size: 10))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text("\(score)/100")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(themeManager.theme.accentGreen)
                    }
                }
            }

            Spacer()

            // Action buttons
            HStack(spacing: 8) {
                Button(action: onAnalyze) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.accentGreen)
                        .frame(width: 32, height: 32)
                        .background(themeManager.theme.accentGreen.opacity(0.15))
                        .clipShape(Circle())
                }

                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.error)
                            .frame(width: 32, height: 32)
                            .background(themeManager.theme.error.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(12)
        .background(themeManager.theme.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Generated Highlight Reel View

struct GeneratedHighlightReelView: View {
    let result: HighlightReelResult
    let prompt: String
    let courses: [String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var videoStorage = VideoStorageManager.shared
    @ObservedObject private var filmHighlights = FilmHighlightsManager.shared
    @State private var isSendingToRecruit = false
    @State private var sentToRecruit = false
    @State private var isSavingToLibrary = false
    @State private var savedToLibrary = false
    @State private var isSavingToCameraRoll = false
    @State private var savedToCameraRoll = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private var durationString: String {
        let minutes = Int(result.totalDuration) / 60
        let seconds = Int(result.totalDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Video preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "1A3A2A"), Color(hex: "0D1F15")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 220)

                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.theme.cardBackground.opacity(0.9))
                                    .frame(width: 70, height: 70)

                                Image(systemName: "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(themeManager.theme.primary)
                                    .offset(x: 2)
                            }

                            Text("Your Highlight Reel")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Text(durationString)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        // Duration badge
                        VStack {
                            HStack {
                                Spacer()
                                Text("AI Generated")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                            Spacer()
                        }
                        .padding(16)
                    }

                    // Details card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reel Details")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.theme.accentGreen)
                                Text("Based on your prompt:")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textSecondary)
                            }

                            Text(prompt.isEmpty ? "General highlight reel" : prompt)
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textPrimary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(themeManager.theme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        if !courses.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Courses included:")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textSecondary)

                                HStack(spacing: 8) {
                                    ForEach(courses, id: \.self) { course in
                                        Text(course)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(themeManager.theme.accentGreen)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(themeManager.theme.accentGreen.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        // Stats
                        HStack(spacing: 32) {
                            statItem(value: durationString, label: "Duration")
                            statItem(value: "\(result.coursesIncluded.count)", label: "Courses")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Action buttons
                    VStack(spacing: 12) {
                        // Primary action - Save to Recruit Profile
                        Button(action: sendToRecruitPage) {
                            HStack(spacing: 8) {
                                if isSendingToRecruit {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else if sentToRecruit {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                } else {
                                    Image(systemName: "person.crop.rectangle.stack")
                                        .font(.system(size: 16))
                                }
                                Text(sentToRecruit ? "Added to Recruit Profile!" : "Add to Recruit Profile")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                sentToRecruit
                                    ? Color.green
                                    : themeManager.theme.accentGreen
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .disabled(isSendingToRecruit || sentToRecruit)

                        // Save to Camera Roll
                        Button(action: saveToCameraRoll) {
                            HStack(spacing: 8) {
                                if isSavingToCameraRoll {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                } else if savedToCameraRoll {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                } else {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 16))
                                }
                                Text(savedToCameraRoll ? "Saved to Camera Roll!" : "Save to Camera Roll")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(themeManager.theme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(isSavingToCameraRoll || savedToCameraRoll)

                        // Save to App Library & Share
                        HStack(spacing: 12) {
                            Button(action: saveToLibrary) {
                                HStack(spacing: 6) {
                                    if isSavingToLibrary {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(0.7)
                                    } else if savedToLibrary {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14))
                                    } else {
                                        Image(systemName: "square.and.arrow.down")
                                            .font(.system(size: 14))
                                    }
                                    Text(savedToLibrary ? "Saved!" : "Save to App")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(themeManager.theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(themeManager.theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .disabled(isSavingToLibrary || savedToLibrary)

                            ShareLink(item: result.outputURL) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14))
                                    Text("Share")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(themeManager.theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(themeManager.theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
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
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.accentGreen)
                        Text("Highlight Reel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
                }
            }
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sendToRecruitPage() {
        isSendingToRecruit = true
        let title = prompt.isEmpty ? "Highlight Reel" : "Highlight Reel - \(prompt.prefix(30))"
        filmHighlights.saveHighlight(from: result.outputURL, title: title) { success in
            DispatchQueue.main.async {
                isSendingToRecruit = false
                if success {
                    sentToRecruit = true
                } else {
                    errorMessage = "Failed to save to recruit profile"
                    showingError = true
                }
            }
        }
    }

    private func saveToCameraRoll() {
        isSavingToCameraRoll = true
        filmHighlights.saveToCameraRoll(from: result.outputURL) { success, error in
            DispatchQueue.main.async {
                isSavingToCameraRoll = false
                if success {
                    savedToCameraRoll = true
                } else {
                    errorMessage = error?.localizedDescription ?? "Failed to save to camera roll"
                    showingError = true
                }
            }
        }
    }

    private func saveToLibrary() {
        isSavingToLibrary = true
        let title = prompt.isEmpty ? "Highlight Reel" : "Highlight Reel - \(prompt.prefix(30))"
        videoStorage.saveVideo(from: result.outputURL, title: title) { savedVideo in
            DispatchQueue.main.async {
                isSavingToLibrary = false
                savedToLibrary = savedVideo != nil
                if savedVideo == nil {
                    errorMessage = "Failed to save to app library"
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    VideoLibraryView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
