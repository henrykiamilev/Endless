import SwiftUI
import Combine

struct VideoLibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showingMenu = false
    @State private var showingFilter = false
    @State private var showingAIAnalysis = false
    @State private var selectedVideoForAI: Video?
    @State private var showingHighlightGenerator = false
    @State private var highlightPrompt = ""
    @State private var selectedCourses: Set<String> = []
    @State private var isGeneratingHighlight = false
    @State private var showingGeneratedReel = false
    @State private var showingVideoPlayer = false
    @State private var selectedVideoForPlayback: Video?

    private let availableCourses = ["Oakmont CC", "Pebble Beach", "Del Mar", "Torrey Pines"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Branded Header
                brandedHeader

                // Toggle with shadow
                ToggleButton(options: ["Video", "Stats"], selectedIndex: $navigationManager.videoLibrarySubTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

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
        .background(themeManager.theme.background)
        .sheet(isPresented: $showingAIAnalysis) {
            AIAnalysisView(video: selectedVideoForAI)
        }
        .sheet(isPresented: $showingGeneratedReel) {
            GeneratedHighlightReelView(prompt: highlightPrompt, courses: Array(selectedCourses))
        }
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            if let video = selectedVideoForPlayback, let videoFileName = video.videoFileName {
                VideoPlayerView(videoFileName: videoFileName, videoTitle: video.title)
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
                    Text("\(MockData.videos.count)")
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
            // Filter header with better styling
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.primary)
                    Text("October 2025")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }

                Spacer()

                Button(action: { showingFilter = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                        Text("Filter")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(themeManager.theme.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(themeManager.theme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                }
                .sheet(isPresented: $showingFilter) {
                    FilterSheetView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

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
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ], spacing: 18) {
                ForEach(MockData.videos) { video in
                    VideoCard(video: video) {
                        // Play video when tapped
                        selectedVideoForPlayback = video
                        showingVideoPlayer = true
                    }
                    .contextMenu {
                        Button(action: {
                            selectedVideoForPlayback = video
                            showingVideoPlayer = true
                        }) {
                            Label("Play Video", systemImage: "play.fill")
                        }
                        Button(action: {
                            selectedVideoForAI = video
                            showingAIAnalysis = true
                        }) {
                            Label("AI Analysis", systemImage: "sparkles")
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)

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

                    TextEditor(text: $highlightPrompt)
                        .font(.system(size: 14))
                        .frame(height: 60)
                        .padding(10)
                        .background(themeManager.theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(themeManager.theme.border, lineWidth: 1)
                        )

                    // Course filter tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(availableCourses, id: \.self) { course in
                                CourseFilterTag(
                                    name: course,
                                    isSelected: selectedCourses.contains(course)
                                ) {
                                    if selectedCourses.contains(course) {
                                        selectedCourses.remove(course)
                                    } else {
                                        selectedCourses.insert(course)
                                    }
                                }
                            }
                        }
                    }

                    // Generate button
                    Button(action: {
                        generateHighlightReel()
                    }) {
                        HStack(spacing: 8) {
                            if isGeneratingHighlight {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                            }
                            Text(isGeneratingHighlight ? "Generating..." : "Generate Highlight Reel")
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
                    .disabled(highlightPrompt.isEmpty || isGeneratingHighlight)
                    .opacity(highlightPrompt.isEmpty ? 0.6 : 1)
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
        isGeneratingHighlight = true
        // Simulate generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isGeneratingHighlight = false
            showingGeneratedReel = true
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

                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(themeManager.theme.background)
                        .clipShape(Circle())
                }
            }
            .padding(16)

            Divider()
                .background(themeManager.theme.border)
                .padding(.horizontal, 16)

            // Video list
            VStack(spacing: 12) {
                SwingVideoRow(
                    title: "Down the Line - Current Swing",
                    date: "DTL - 10/16/25",
                    annotation: "Working on staying centered over the ball",
                    onAnalyze: {
                        selectedVideoForAI = MockData.videos.first
                        showingAIAnalysis = true
                    }
                )

                SwingVideoRow(
                    title: "Face On View",
                    date: "Face On - 10/15/25",
                    annotation: "Focusing on reducing head sway",
                    onAnalyze: {
                        selectedVideoForAI = MockData.videos.first
                        showingAIAnalysis = true
                    }
                )
            }
            .padding(16)

            // Add more videos button
            Button(action: {}) {
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
    }

    // MARK: - Stats Tab

    private var statsTabContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Stats Overview Card
            statsOverviewCard

            // Recent Round Stats
            sectionView(label: "RECENT ROUND STATS", icon: "chart.bar.fill") {
                VStack(spacing: 0) {
                    StatBar(label: "Greens in Regulation", value: "72", percentage: 72)
                    StatBar(label: "Fairways Hit", value: "65", percentage: 65)
                    StatBar(label: "Avg Putts per Round", value: "28.4", percentage: 71)
                    StatBar(label: "Scoring Average", value: "71.3", percentage: 90, showPercentageBar: false)
                }
                .padding(20)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }

            // Launch Monitor
            sectionView(label: "LAUNCH MONITOR DATA", icon: "cpu") {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(themeManager.theme.primary.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(themeManager.theme.primary.opacity(0.2))
                            .frame(width: 60, height: 60)

                        Image(systemName: "cpu")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.theme.primary)
                    }

                    VStack(spacing: 8) {
                        Text("Connect Launch Monitor")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text("Track club data and improve your swing")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    BrandedButton(title: "CONNECT GCQUAD", icon: "link", action: {})
                }
                .frame(maxWidth: .infinity)
                .padding(28)
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
            statItem(value: "72.1", label: "AVG SCORE", icon: "flag.fill")

            Rectangle()
                .fill(themeManager.theme.border)
                .frame(width: 1)
                .padding(.vertical, 16)

            statItem(value: "18", label: "ROUNDS", icon: "repeat")

            Rectangle()
                .fill(themeManager.theme.border)
                .frame(width: 1)
                .padding(.vertical, 16)

            statItem(value: "4.2", label: "HANDICAP", icon: "chart.line.uptrend.xyaxis")
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
    @State private var messageText = ""
    @State private var messages: [AIMessage] = [
        AIMessage(isUser: false, text: "Hi! I'm your AI Golf Coach. I've analyzed your swing and I'm here to help. What would you like to know?"),
        AIMessage(isUser: true, text: "How can I improve my follow-through?"),
        AIMessage(isUser: false, text: "Great question! Based on your swing analysis, I noticed your follow-through could use more extension. Here are some tips:\n\n1. Focus on pushing your hands toward the target after impact\n2. Let your arms fully extend before they begin to fold\n3. Your belt buckle should face the target at finish\n\nWould you like me to suggest some specific drills?")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(16)
                }

                // Input area
                HStack(spacing: 12) {
                    TextField("Ask your AI coach...", text: $messageText)
                        .font(.system(size: 15))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Capsule())

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(messageText.isEmpty ? themeManager.theme.textSecondary : themeManager.theme.accentGreen)
                    }
                    .disabled(messageText.isEmpty)
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
        let userMessage = AIMessage(isUser: true, text: messageText)
        messages.append(userMessage)
        messageText = ""

        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = AIMessage(isUser: false, text: "That's a great follow-up question! Let me think about that based on your swing data...")
            messages.append(aiResponse)
        }
    }
}

struct AIMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

struct MessageBubble: View {
    let message: AIMessage
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
    let onAnalyze: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Video thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(themeManager.theme.background)
                    .frame(width: 60, height: 60)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.theme.accentGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.theme.textSecondary)

                Text(annotation)
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.theme.textMuted)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onAnalyze) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.accentGreen)
                    .frame(width: 32, height: 32)
                    .background(themeManager.theme.accentGreen.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(themeManager.theme.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Generated Highlight Reel View

struct GeneratedHighlightReelView: View {
    let prompt: String
    let courses: [String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isSendingToRecruit = false
    @State private var sentToRecruit = false

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
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 70, height: 70)

                                Image(systemName: "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                    .offset(x: 2)
                            }

                            Text("Your Highlight Reel")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Text("2:14")
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
                        HStack(spacing: 24) {
                            statItem(value: "12", label: "Clips")
                            statItem(value: "8", label: "Best Shots")
                            statItem(value: "4", label: "Courses")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Action buttons
                    VStack(spacing: 12) {
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
                                Text(sentToRecruit ? "Sent to Recruit Page!" : "Send to Recruit Page")
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

                        HStack(spacing: 12) {
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 14))
                                    Text("Save")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(themeManager.theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(themeManager.theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }

                            Button(action: {}) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSendingToRecruit = false
            sentToRecruit = true
        }
    }
}

#Preview {
    VideoLibraryView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
