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
                    isGenerating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isGenerating = false
                        navigationManager.navigateToVideo()
                    }
                }
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

                Button(action: { navigationManager.navigateToRecord() }) {
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
                        .fill(index < MockData.swingVideos.count ?
                              themeManager.theme.primary :
                              themeManager.theme.border)
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Text("\(MockData.swingVideos.count)/5 videos")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(.bottom, 18)

            // Swing videos list
            VStack(spacing: 14) {
                ForEach(MockData.swingVideos) { video in
                    SwingVideoCard(video: video)
                }
            }
            .padding(.bottom, 16)

            // Add video card
            Button(action: { navigationManager.navigateToRecord() }) {
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

#Preview {
    EndlessAIView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
