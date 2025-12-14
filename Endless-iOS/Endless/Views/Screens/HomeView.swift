import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0

    private let navTabs = ["Sessions", "Team", "Profile"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Header
                heroHeader

                // Pill Navigation Tabs
                navTabsView

                // Featured Session Card
                sectionView(label: "UPCOMING SESSION") {
                    featuredSessionCard
                }

                // Quick Actions
                sectionView(label: "QUICK ACTIONS") {
                    quickActionsRow
                }

                // Plays of the Week
                sectionView(label: "PLAYS OF THE WEEK") {
                    playsOfWeekScroll
                }

                // Recent Sessions
                sectionView(label: "RECENT SESSIONS") {
                    sessionsScroll
                }

                // Performance Snapshot
                sectionView(label: "PERFORMANCE") {
                    PerformanceSnapshot()
                }

                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
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

                Button(action: { themeManager.toggleTheme() }) {
                    Image(systemName: themeManager.isDark ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.theme.primary)
                        .frame(width: 44, height: 44)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 20)

            Text("ALL\nSESSIONS")
                .font(.system(size: 52, weight: .heavy))
                .tracking(-2)
                .foregroundColor(themeManager.theme.textPrimary)
                .lineSpacing(-8)
                .padding(.bottom, 12)

            HStack(spacing: 4) {
                Text("STANDINGS")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: - Navigation Tabs

    private var navTabsView: some View {
        HStack(spacing: 0) {
            ForEach(Array(navTabs.enumerated()), id: \.offset) { index, tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    Text(tab.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(selectedTab == index ?
                            themeManager.theme.textInverse :
                            themeManager.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == index ?
                            themeManager.theme.textPrimary :
                            Color.clear
                        )
                        .cornerRadius(26)
                }
            }
        }
        .padding(4)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(30)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    // MARK: - Featured Session Card

    private var featuredSessionCard: some View {
        VStack(spacing: 0) {
            // Image area
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    gradient: Gradient(colors: themeManager.isDark ?
                        [Color(hex: "1A3A2E"), Color(hex: "0D1F17")] :
                        [Color(hex: "D4E5DC"), Color(hex: "A8C5B5")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .overlay(
                    Image(systemName: "figure.golf")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.theme.primary)
                )

                Text("PLAY BY MAY 15")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(themeManager.theme.textInverse)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.theme.primary)
                    .cornerRadius(14)
                    .padding(16)
            }

            // Content area
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text("May 6")
                            .font(.system(size: 13, weight: .medium))
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("09:00")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                    Text("Main, Birchwood Park Golf Centre")
                        .font(.system(size: 13))
                }
                .foregroundColor(themeManager.theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)

            Divider()
                .background(themeManager.theme.border)
                .padding(.horizontal, 18)

            // Team section
            VStack(alignment: .leading, spacing: 14) {
                Text("TEAM 1")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1)
                    .foregroundColor(themeManager.theme.textMuted)

                ForEach(MockData.team1Players) { player in
                    playerRow(player: player)
                }
            }
            .padding(18)
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
    }

    private func playerRow(player: Player) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(player.isCaptain ? themeManager.theme.primary : themeManager.theme.accentBlue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.theme.textInverse)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("HCP: \(String(format: "%.1f", player.handicap))")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            if player.isCaptain {
                Text("CAPTAIN")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(themeManager.theme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.theme.cardBackgroundElevated)
                    .cornerRadius(10)
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: 10) {
            QuickActionCard(title: "Today's Drills", subtitle: "5 remaining", icon: "figure.golf")
            QuickActionCard(title: "Last Session", subtitle: "2 days ago", icon: "clock")
            QuickActionCard(title: "Recruit Views", subtitle: "12 coaches", icon: "eye")
        }
    }

    // MARK: - Plays of the Week

    private var playsOfWeekScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(MockData.playsOfWeek) { play in
                    PlayOfWeekCard(play: play)
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.leading, -20)
        .padding(.horizontal, 20)
    }

    // MARK: - Sessions

    private var sessionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(MockData.sessions) { session in
                    SessionCard(session: session)
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.leading, -20)
        .padding(.horizontal, 20)
    }

    // MARK: - Section Helper

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
    HomeView()
        .environmentObject(ThemeManager())
}
