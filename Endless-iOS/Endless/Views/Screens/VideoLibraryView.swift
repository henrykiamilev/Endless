import SwiftUI

struct VideoLibraryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                headerView

                // Toggle
                ToggleButton(options: ["Video", "Stats"], selectedIndex: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                // Content
                if selectedTab == 0 {
                    videoTabContent
                } else {
                    statsTabContent
                }

                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                }

                Spacer()

                Circle()
                    .fill(themeManager.theme.primary)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text("W")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(themeManager.theme.textInverse)
                    )
            }
            .padding(.bottom, 20)

            Text("VIDEO\nLIBRARY")
                .font(.system(size: 48, weight: .heavy))
                .tracking(-2)
                .foregroundColor(themeManager.theme.textPrimary)
                .lineSpacing(-8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: - Video Tab

    private var videoTabContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Filter header
            HStack {
                Text("Showing matches from October 2025")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(10)
                        .background(themeManager.theme.cardBackground)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Section label
            Text("MATCH VIDEOS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            // Videos grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(MockData.videos) { video in
                    VideoCard(video: video)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Stats Tab

    private var statsTabContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Recent Round Stats
            sectionView(label: "RECENT ROUND STATS") {
                VStack(spacing: 0) {
                    StatBar(label: "Greens in Regulation", value: "72", percentage: 72)
                    StatBar(label: "Fairways Hit", value: "65", percentage: 65)
                    StatBar(label: "Avg Putts per Round", value: "28.4", percentage: 71)
                    StatBar(label: "Scoring Average", value: "71.3", percentage: 90, showPercentageBar: false)
                }
                .padding(20)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(20)
            }

            // Launch Monitor
            sectionView(label: "LAUNCH MONITOR DATA") {
                VStack(spacing: 18) {
                    Circle()
                        .fill(themeManager.theme.primary.opacity(0.15))
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: "cpu")
                                .font(.system(size: 28))
                                .foregroundColor(themeManager.theme.primary)
                        )

                    Text("Connect your launch monitor to track club data")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .multilineTextAlignment(.center)

                    Button(action: {}) {
                        Text("CONNECT GCQUAD")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(themeManager.theme.textInverse)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 32)
                            .background(themeManager.theme.primary)
                            .cornerRadius(28)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(20)
            }

            // Round History
            sectionView(label: "ROUND HISTORY") {
                VStack(spacing: 0) {
                    ForEach(MockData.roundHistory) { round in
                        RoundHistoryCard(round: round)
                        if round.id != MockData.roundHistory.last?.id {
                            Divider()
                                .background(themeManager.theme.border)
                        }
                    }
                }
                .padding(18)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
    }

    private func sectionView<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            content()
        }
    }
}

#Preview {
    VideoLibraryView()
        .environmentObject(ThemeManager())
}
