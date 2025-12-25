import SwiftUI

struct EndlessAIView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var videoStorage = VideoStorageManager.shared
    @ObservedObject private var swingVideoManager = SwingVideoManager.shared
    @ObservedObject private var highlightGenerator = HighlightReelGenerator.shared

    @State private var prompt = ""
    @State private var selectedCourses: Set<String> = []
    @State private var showingMenu = false
    @State private var isGenerating = false
    @State private var showingGeneratedReel = false
    @State private var generatedReelResult: HighlightReelResult?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingAddSwingVideo = false
    @State private var showingSwingAnalysis = false
    @State private var selectedSwingVideo: ManagedSwingVideo?
    @State private var showingAddVideoOptions = false
    @State private var showingVideoPicker = false

    private let courseFilters = ["Oakmont CC", "Pebble Beach", "Del Mar"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Branded Header
                brandedHeader

                // AI Features Overview
                aiFeaturesBanner

                // Create Highlight Reel Section
                sectionView(label: "CREATE HIGHLIGHT REEL", icon: "wand.and.stars") {
                    highlightReelCard
                }

                // My Swing Videos Section
                swingVideosSection

                // Footer branding
                footerBranding

                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
        .sheet(isPresented: $showingGeneratedReel) {
            if let result = generatedReelResult {
                GeneratedHighlightReelView(
                    result: result,
                    prompt: prompt,
                    courses: Array(selectedCourses)
                )
            }
        }
        .sheet(isPresented: $showingSwingAnalysis) {
            if let video = selectedSwingVideo {
                SwingVideoAnalysisView(video: video)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
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

    // MARK: - Generate Highlight Reel

    private func generateHighlightReel() {
        guard !videoStorage.allVideos.isEmpty else {
            errorMessage = "No videos available. Record some golf sessions first!"
            showingError = true
            return
        }

        isGenerating = true

        Task {
            do {
                let config = HighlightReelConfig(
                    prompt: prompt,
                    selectedCourses: Array(selectedCourses)
                )

                let result = try await highlightGenerator.generateHighlightReel(
                    from: videoStorage.allVideos,
                    config: config
                )

                await MainActor.run {
                    isGenerating = false
                    generatedReelResult = result
                    showingGeneratedReel = true
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showingError = true
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

                // Endless Logo with AI badge
                ZStack(alignment: .bottomTrailing) {
                    EndlessLogo(size: 48, showText: false)

                    // AI Badge
                    Text("AI")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: [themeManager.theme.primary, themeManager.theme.accentBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(6)
                        .offset(x: 4, y: 4)
                }
            }
            .padding(.bottom, 28)

            // Title with gradient effect
            VStack(alignment: .leading, spacing: 0) {
                Text("ENDLESS")
                    .font(.system(size: 48, weight: .heavy))
                    .tracking(-2)
                    .foregroundColor(themeManager.theme.textPrimary)

                HStack(spacing: 12) {
                    Text("AI")
                        .font(.system(size: 48, weight: .heavy))
                        .tracking(-2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeManager.theme.primary, themeManager.theme.accentBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Beta badge
                    Text("BETA")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(themeManager.theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(themeManager.theme.primary.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 12)

            Text("Create AI-powered highlight reels from your golf videos")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .sheet(isPresented: $showingMenu) {
            MenuSheetView()
        }
    }

    // MARK: - AI Features Banner

    private var aiFeaturesBanner: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                aiFeatureChip(icon: "sparkles", title: "Smart Editing")
                aiFeatureChip(icon: "waveform", title: "Audio Sync")
                aiFeatureChip(icon: "camera.metering.matrix", title: "Best Shots")
                aiFeatureChip(icon: "music.note", title: "Music Match")
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
    }

    private func aiFeatureChip(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.primary)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Highlight Reel Card

    private var highlightReelCard: some View {
        VStack(spacing: 0) {
            // Gradient header with animated particles effect
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: themeManager.isDark ?
                        [Color(hex: "1A3A2E"), Color(hex: "0A1A14")] :
                        [Color(hex: "D4E5DC"), Color(hex: "A8C5B5")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 160)

                // Decorative elements
                Circle()
                    .stroke(themeManager.theme.primary.opacity(0.2), lineWidth: 1)
                    .frame(width: 200, height: 200)
                    .offset(x: 80, y: 40)

                Circle()
                    .stroke(themeManager.theme.primary.opacity(0.15), lineWidth: 1)
                    .frame(width: 100, height: 100)
                    .offset(x: -80, y: -20)

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "sparkles")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 6) {
                        EndlessLogo(size: 18, showText: false)
                        Text("POWERED BY ENDLESS AI")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .clipped()

            // Content
            VStack(spacing: 18) {
                // Prompt input with icon
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.primary)
                        .padding(.top, 2)

                    TextField("Describe your perfect highlight reel...", text: $prompt, axis: .vertical)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(3...5)
                }
                .padding(16)
                .background(themeManager.theme.backgroundSecondary)
                .cornerRadius(18)

                // Course filters
                VStack(alignment: .leading, spacing: 10) {
                    Text("SELECT COURSES")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(themeManager.theme.textMuted)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(courseFilters, id: \.self) { course in
                            courseChip(course)
                        }
                    }
                }

                // Generate button
                BrandedButton(
                    title: isGenerating ? "GENERATING..." : "GENERATE REEL",
                    icon: "sparkles",
                    isLoading: isGenerating
                ) {
                    generateHighlightReel()
                }
                .disabled(videoStorage.allVideos.isEmpty)
            }
            .padding(22)
            .background(themeManager.theme.cardBackground)
        }
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
    }

    private func courseChip(_ course: String) -> some View {
        let isSelected = selectedCourses.contains(course)
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedCourses.remove(course)
                } else {
                    selectedCourses.insert(course)
                }
            }
        }) {
            Text(course)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isSelected ? themeManager.theme.textInverse : themeManager.theme.textSecondary)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? themeManager.theme.primary : themeManager.theme.backgroundSecondary)
                .cornerRadius(22)
        }
    }

    // MARK: - Swing Videos Section

    private var swingVideosSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.primary)
                    Text("MY SWING VIDEOS")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                Button(action: { showingAddVideoOptions = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(themeManager.theme.textInverse)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(themeManager.theme.primary)
                    .cornerRadius(16)
                }
            }
            .padding(.bottom, 8)

            Text("Upload up to 5 swing videos for AI analysis")
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textMuted)
                .padding(.bottom, 18)

            // Progress indicator
            HStack(spacing: 6) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < swingVideoManager.videoCount ?
                              themeManager.theme.primary :
                              themeManager.theme.border)
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Text("\(swingVideoManager.videoCount)/5 videos")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(.bottom, 18)

            // Swing videos list
            VStack(spacing: 14) {
                ForEach(swingVideoManager.swingVideos) { video in
                    ManagedSwingVideoCard(
                        video: video,
                        onAnalyze: {
                            selectedSwingVideo = video
                            showingSwingAnalysis = true
                        },
                        onDelete: {
                            swingVideoManager.deleteSwingVideo(video)
                        }
                    )
                }
            }
            .padding(.bottom, 16)

            // Add video card
            Button(action: { showingAddVideoOptions = true }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(themeManager.theme.primary.opacity(0.1))
                            .frame(width: 56, height: 56)

                        Circle()
                            .stroke(themeManager.theme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .frame(width: 56, height: 56)

                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(themeManager.theme.primary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add New Swing Video")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text("Record or upload from library")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textMuted)
                }
                .padding(18)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    // MARK: - Footer Branding

    private var footerBranding: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                EndlessLogo(size: 24, showText: false)
                Text("Endless AI")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            Text("Transforming your golf moments into cinematic highlights")
                .font(.system(size: 11))
                .foregroundColor(themeManager.theme.textMuted)
                .multilineTextAlignment(.center)
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
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}

// MARK: - Managed Swing Video Card

struct ManagedSwingVideoCard: View {
    let video: ManagedSwingVideo
    let onAnalyze: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(themeManager.theme.backgroundSecondary)
                    .frame(width: 64, height: 64)

                Image(systemName: "figure.golf")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.theme.primary.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(video.type.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    if video.analysisResult != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.primary)
                    }
                }

                Text(video.dateString)
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.theme.textSecondary)

                if !video.annotation.isEmpty {
                    Text(video.annotation)
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textMuted)
                        .lineLimit(1)
                }

                if let score = video.analysisResult?.overallScore {
                    HStack(spacing: 4) {
                        Text("Score:")
                            .font(.system(size: 10))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text("\(score)/100")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(themeManager.theme.primary)
                    }
                }
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button(action: onAnalyze) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.primary)
                        .frame(width: 36, height: 36)
                        .background(themeManager.theme.primary.opacity(0.1))
                        .clipShape(Circle())
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.error)
                        .frame(width: 32, height: 32)
                        .background(themeManager.theme.error.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Swing Video Analysis View

struct SwingVideoAnalysisView: View {
    let video: ManagedSwingVideo
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var swingAnalyzer = SwingAnalyzer.shared
    @ObservedObject private var swingVideoManager = SwingVideoManager.shared
    @ObservedObject private var aiCoach = AICoachService.shared

    @State private var analysisResult: SwingAnalysisResult?
    @State private var isAnalyzing = false
    @State private var selectedTab = 0
    @State private var showingChat = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    if isAnalyzing {
                        analyzingView
                    } else if let result = analysisResult ?? video.analysisResult {
                        analysisResultsView(result: result)
                    } else {
                        noAnalysisView
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
                            .foregroundColor(themeManager.theme.primary)
                        Text("AI Analysis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
                }
            }
            .onAppear {
                if video.analysisResult == nil {
                    analyzeVideo()
                }
            }
        }
        .sheet(isPresented: $showingChat) {
            AICoachChatView()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Video info
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1A3A2A"), Color(hex: "0D1F15")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)

                VStack(spacing: 8) {
                    Image(systemName: "figure.golf")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.4))

                    Text(video.type.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.type.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(video.dateString)
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
                    .background(themeManager.theme.primary)
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(themeManager.theme.cardBackground, lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: swingAnalyzer.analysisProgress)
                    .stroke(themeManager.theme.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.theme.primary)
            }

            Text("Analyzing your swing...")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("Our AI is reviewing your technique using pose detection")
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }

    private var noAnalysisView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundColor(themeManager.theme.primary.opacity(0.5))

            Text("Ready to Analyze")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("Tap below to get AI-powered insights on your swing")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: analyzeVideo) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Analyze Swing")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(themeManager.theme.primary)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 40)
    }

    private func analysisResultsView(result: SwingAnalysisResult) -> some View {
        VStack(spacing: 20) {
            // Overall score
            overallScoreCard(result: result)

            // Tab selection
            ToggleButton(options: ["Breakdown", "Tips", "Drills"], selectedIndex: $selectedTab)

            // Tab content
            if selectedTab == 0 {
                breakdownSection(result: result)
            } else if selectedTab == 1 {
                tipsSection(result: result)
            } else {
                drillsSection(result: result)
            }
        }
    }

    private func overallScoreCard(result: SwingAnalysisResult) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(themeManager.theme.cardBackground, lineWidth: 8)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: Double(result.overallScore) / 100.0)
                    .stroke(themeManager.theme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(result.overallScore)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    Text("/ 100")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(scoreLabel(result.overallScore))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("Your technique shows good fundamentals with room for improvement.")
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .lineLimit(3)

                if let improvement = result.improvement, improvement != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: improvement > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(improvement > 0 ? "+" : "")\(improvement) from last analysis")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(improvement > 0 ? themeManager.theme.primary : themeManager.theme.error)
                }
            }
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 90...100: return "Excellent!"
        case 80..<90: return "Great Swing!"
        case 70..<80: return "Good Progress"
        case 60..<70: return "Keep Practicing"
        default: return "Room to Improve"
        }
    }

    private func breakdownSection(result: SwingAnalysisResult) -> some View {
        VStack(spacing: 12) {
            ForEach(result.breakdown) { phase in
                phaseRow(phase: phase)
            }
        }
    }

    private func phaseRow(phase: SwingPhaseScore) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(scoreColor(phase.score).opacity(0.15))
                    .frame(width: 44, height: 44)

                Text("\(phase.score)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(scoreColor(phase.score))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(phase.phase.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(phase.feedback)
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
            return themeManager.theme.primary
        } else if score >= 70 {
            return Color(hex: "F59E0B")
        } else {
            return themeManager.theme.error
        }
    }

    private func tipsSection(result: SwingAnalysisResult) -> some View {
        VStack(spacing: 12) {
            ForEach(result.tips) { tip in
                tipCard(tip: tip)
            }
        }
    }

    private func tipCard(tip: SwingTip) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.primary.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: tip.icon)
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.theme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(tip.description)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func drillsSection(result: SwingAnalysisResult) -> some View {
        VStack(spacing: 12) {
            ForEach(result.drills) { drill in
                drillCard(drill: drill)
            }
        }
    }

    private func drillCard(drill: RecommendedDrill) -> some View {
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
                    Text(drill.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Spacer()

                    Text(drill.duration)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Capsule())
                }

                Text(drill.description)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analyzeVideo() {
        isAnalyzing = true

        Task {
            let result = await swingVideoManager.analyzeSwingVideo(video)

            await MainActor.run {
                isAnalyzing = false
                if let result = result {
                    analysisResult = result
                    aiCoach.setAnalysisContext(result)
                }
            }
        }
    }
}

#Preview {
    EndlessAIView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
