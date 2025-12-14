import SwiftUI

struct EndlessAIView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var prompt = ""
    @State private var selectedCourses: Set<String> = []
    @State private var showingMenu = false
    @State private var isGenerating = false

    private let courseFilters = ["Oakmont CC", "Pebble Beach", "Del Mar"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                headerView

                // Create Highlight Reel Section
                sectionView(label: "CREATE HIGHLIGHT REEL") {
                    highlightReelCard
                }

                // My Swing Videos Section
                swingVideosSection

                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { showingMenu = true }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: { navigationManager.navigateToHome() }) {
                    ZStack {
                        Circle()
                            .fill(themeManager.theme.cardBackground)
                            .frame(width: 44, height: 44)

                        Text("∞")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(themeManager.theme.primary)
                    }
                }
            }
            .padding(.bottom, 20)

            Text("ENDLESS\nAI")
                .font(.system(size: 48, weight: .heavy))
                .tracking(-2)
                .foregroundColor(themeManager.theme.textPrimary)
                .lineSpacing(-8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .sheet(isPresented: $showingMenu) {
            MenuSheetView()
        }
    }

    // MARK: - Highlight Reel Card

    private var highlightReelCard: some View {
        VStack(spacing: 0) {
            // Gradient header
            LinearGradient(
                gradient: Gradient(colors: themeManager.isDark ?
                    [Color(hex: "1A3A2E"), Color(hex: "0A1A14")] :
                    [Color(hex: "D4E5DC"), Color(hex: "A8C5B5")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)
            .overlay(
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        )

                    Text("POWERED BY AI")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.8))
                }
            )

            // Content
            VStack(spacing: 16) {
                // Prompt input
                TextField("Describe your perfect highlight reel...", text: $prompt, axis: .vertical)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(3...5)
                    .padding(16)
                    .background(themeManager.theme.backgroundSecondary)
                    .cornerRadius(16)

                // Course filters
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(courseFilters, id: \.self) { course in
                        courseChip(course)
                    }
                }

                // Generate button
                Button(action: {
                    isGenerating = true
                    // Simulate generation then navigate to video
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isGenerating = false
                        navigationManager.navigateToVideo()
                    }
                }) {
                    HStack(spacing: 8) {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.theme.textInverse))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                        }
                        Text(isGenerating ? "GENERATING..." : "GENERATE REEL")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(0.5)
                    }
                    .foregroundColor(themeManager.theme.textInverse)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.theme.primary)
                    .cornerRadius(28)
                }
                .disabled(isGenerating)
            }
            .padding(20)
            .background(themeManager.theme.cardBackground)
        }
        .cornerRadius(24)
    }

    private func courseChip(_ course: String) -> some View {
        let isSelected = selectedCourses.contains(course)
        return Button(action: {
            if isSelected {
                selectedCourses.remove(course)
            } else {
                selectedCourses.insert(course)
            }
        }) {
            Text(course)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? themeManager.theme.textInverse : themeManager.theme.textSecondary)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? themeManager.theme.primary : themeManager.theme.backgroundSecondary)
                .cornerRadius(20)
        }
    }

    // MARK: - Swing Videos Section

    private var swingVideosSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("MY SWING VIDEOS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                Button(action: { navigationManager.navigateToRecord() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.theme.textInverse)
                        .frame(width: 36, height: 36)
                        .background(themeManager.theme.primary)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 6)

            Text("Upload up to 5 swing videos with annotations")
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textMuted)
                .padding(.bottom, 18)

            // Swing videos list
            VStack(spacing: 12) {
                ForEach(MockData.swingVideos) { video in
                    SwingVideoCard(video: video)
                }
            }
            .padding(.bottom, 14)

            // Add video card
            Button(action: { navigationManager.navigateToRecord() }) {
                VStack(spacing: 12) {
                    Circle()
                        .fill(themeManager.theme.primary.opacity(0.15))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.theme.primary)
                        )

                    Text("Add Swing Video")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    private func sectionView<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            content()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}

#Preview {
    EndlessAIView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
