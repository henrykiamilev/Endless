import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedTab = 0
    @State private var showingMenu = false

    private let navTabs = ["Sessions", "Team", "Profile"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Branded Header with Logo
                brandedHeader

                // Pill Navigation Tabs
                navTabsView

                // Featured Session Card
                sectionView(label: "UPCOMING SESSION", showViewAll: true) {
                    featuredSessionCard
                }

                // Quick Actions
                sectionView(label: "QUICK ACTIONS") {
                    quickActionsRow
                }

                // Plays of the Week
                sectionView(label: "PLAYS OF THE WEEK", showViewAll: true) {
                    playsOfWeekScroll
                }

                // Recent Sessions
                sectionView(label: "RECENT SESSIONS", showViewAll: true) {
                    sessionsScroll
                }

                // Performance Snapshot
                sectionView(label: "PERFORMANCE") {
                    PerformanceSnapshot()
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

                // Theme toggle
                Button(action: { themeManager.toggleTheme() }) {
                    Image(systemName: themeManager.isDark ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.theme.primary)
                        .frame(width: 48, height: 48)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                // Endless Logo
                EndlessLogo(size: 48, showText: false)
                    .padding(.leading, 8)
            }
            .padding(.bottom, 28)

            // Large title with branding
            HStack(alignment: .bottom, spacing: 12) {
                Text("ALL\nSESSIONS")
                    .font(.system(size: 52, weight: .heavy))
                    .tracking(-2)
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineSpacing(-8)

                Spacer()
            }
            .padding(.bottom, 12)

            Button(action: { navigationManager.navigateToVideo() }) {
                HStack(spacing: 6) {
                    Text("VIEW STANDINGS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(themeManager.theme.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .sheet(isPresented: $showingMenu) {
            MenuSheetView()
        }
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
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.8)
                        .foregroundColor(selectedTab == index ?
                            themeManager.theme.textInverse :
                            themeManager.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
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
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    // MARK: - Featured Session Card

    private var featuredSessionCard: some View {
        VStack(spacing: 0) {
            // Image area with gradient overlay
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    gradient: Gradient(colors: themeManager.isDark ?
                        [Color(hex: "1A3A2E"), Color(hex: "0D1F17")] :
                        [Color(hex: "D4E5DC"), Color(hex: "A8C5B5")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                .overlay(
                    ZStack {
                        // Decorative circles
                        Circle()
                            .stroke(themeManager.theme.primary.opacity(0.1), lineWidth: 1)
                            .frame(width: 200, height: 200)
                            .offset(x: 80, y: -20)

                        Circle()
                            .stroke(themeManager.theme.primary.opacity(0.1), lineWidth: 1)
                            .frame(width: 120, height: 120)
                            .offset(x: -60, y: 60)

                        Image(systemName: "figure.golf")
                            .font(.system(size: 56))
                            .foregroundColor(themeManager.theme.primary.opacity(0.6))
                    }
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("PLAY BY MAY 15")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(themeManager.theme.textInverse)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(themeManager.theme.primary)
                        .cornerRadius(16)

                    Spacer()

                    // Endless branded badge
                    HStack(spacing: 6) {
                        EndlessLogo(size: 20, showText: false)
                        Text("FEATURED")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(themeManager.theme.cardBackground.opacity(0.95))
                    .cornerRadius(14)
                }
                .padding(18)
            }
            .clipped()

            // Content area
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 24) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.primary)
                        Text("May 6")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.primary)
                        Text("09:00")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundColor(themeManager.theme.textPrimary)

                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.primary)
                    Text("Main, Birchwood Park Golf Centre")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)

            Rectangle()
                .fill(themeManager.theme.border)
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Team section
            VStack(alignment: .leading, spacing: 16) {
                Text("TEAM 1")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textMuted)

                ForEach(MockData.team1Players) { player in
                    playerRow(player: player)
                }
            }
            .padding(20)
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
    }

    private func playerRow(player: Player) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(player.isCaptain ? themeManager.theme.primary : themeManager.theme.accentBlue)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: (player.isCaptain ? themeManager.theme.primary : themeManager.theme.accentBlue).opacity(0.3), radius: 6, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 3) {
                Text(player.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("HCP: \(String(format: "%.1f", player.handicap))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            if player.isCaptain {
                Text("CAPTAIN")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.8)
                    .foregroundColor(themeManager.theme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.theme.primary.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            QuickActionCard(title: "Today's Drills", subtitle: "5 remaining", icon: "figure.golf") {
                navigationManager.navigateToRecord()
            }
            QuickActionCard(title: "Last Session", subtitle: "2 days ago", icon: "clock") {
                navigationManager.navigateToVideo()
            }
            QuickActionCard(title: "Recruit Views", subtitle: "12 coaches", icon: "eye") {
                navigationManager.navigateToAI()
            }
        }
    }

    // MARK: - Plays of the Week

    private var playsOfWeekScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(MockData.playsOfWeek) { play in
                    PlayOfWeekCard(play: play) {
                        navigationManager.selectedVideoId = play.id
                        navigationManager.navigateToVideo()
                    }
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
                    SessionCard(session: session) {
                        navigationManager.selectedSessionId = session.id
                        navigationManager.navigateToVideo()
                    }
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.leading, -20)
        .padding(.horizontal, 20)
    }

    // MARK: - Footer Branding

    private var footerBranding: some View {
        VStack(spacing: 12) {
            EndlessLogo(size: 36, showText: true, textPosition: .right)

            Text("Your complete golf training companion")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
    }

    // MARK: - Section Helper

    private func sectionView<Content: View>(label: String, showViewAll: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                if showViewAll {
                    Button(action: { navigationManager.navigateToVideo() }) {
                        HStack(spacing: 4) {
                            Text("View All")
                                .font(.system(size: 12, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(themeManager.theme.primary)
                    }
                }
            }

            content()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}

// MARK: - Menu Sheet View

struct MenuSheetView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Logo header
                VStack(spacing: 16) {
                    EndlessLogo(size: 64, showText: true, textPosition: .bottom)

                    Text("Golf Training Reimagined")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                List {
                    Section {
                        menuButton(icon: "house.fill", title: "Home", subtitle: "Dashboard & Overview") {
                            dismiss()
                            navigationManager.navigateToHome()
                        }
                        menuButton(icon: "video.fill", title: "Video Library", subtitle: "Your recorded sessions") {
                            dismiss()
                            navigationManager.navigateToVideo()
                        }
                        menuButton(icon: "camera.fill", title: "Record Session", subtitle: "Capture your swing") {
                            dismiss()
                            navigationManager.navigateToRecord()
                        }
                        menuButton(icon: "sparkles", title: "Endless AI", subtitle: "AI-powered analysis") {
                            dismiss()
                            navigationManager.navigateToAI()
                        }
                        menuButton(icon: "gearshape.fill", title: "Settings", subtitle: "Preferences & Account") {
                            dismiss()
                            navigationManager.navigateToSettings()
                        }
                    }
                }
                .listStyle(.insetGrouped)
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

    private func menuButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.primary.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.theme.primary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.theme.textMuted)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
