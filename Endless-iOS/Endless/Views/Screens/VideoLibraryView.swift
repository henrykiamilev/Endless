import SwiftUI

struct VideoLibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showingMenu = false
    @State private var showingFilter = false

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

            // Section label with icon
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
                    VideoCard(video: video)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
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

#Preview {
    VideoLibraryView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
