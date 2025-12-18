import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showingMenu = false
    @State private var showingSessionEditor = false
    @State private var showingWidgetCustomization = false
    @State private var showingDrills = false
    @State private var showingPlaysViewer = false
    @State private var selectedPlayIndex = 0

    // Session data (editable)
    @State private var sessionDate = Date()
    @State private var sessionTime = Date()
    @State private var sessionLocation = "Main, Birchwood Park Golf Centre"

    // User name (could be loaded from UserDefaults or a user model)
    private let userName = "Henry"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Branded Header with Logo
                brandedHeader

                // Performance Widgets (moved to top)
                PerformanceSnapshot(
                    onTap: {
                        // Navigate to stats tab in video library
                        navigationManager.videoLibrarySubTab = 1
                        navigationManager.selectedTab = 1
                    },
                    onCustomize: {
                        showingWidgetCustomization = true
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                // Featured Session Card (now clickable)
                sectionView(label: "UPCOMING SESSION", showViewAll: false) {
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

                // Footer branding
                footerBranding

                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
        .sheet(isPresented: $showingWidgetCustomization) {
            WidgetCustomizationSheet()
        }
        .sheet(isPresented: $showingDrills) {
            TodaysDrillsView()
        }
        .fullScreenCover(isPresented: $showingPlaysViewer) {
            PlaysOfWeekViewer(startingIndex: selectedPlayIndex)
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
                }

                Spacer()

                // Theme toggle
                Button(action: { themeManager.toggleTheme() }) {
                    Image(systemName: themeManager.isDark ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                }

                // Endless Logo
                EndlessLogo(size: 48, showText: false)
                    .padding(.leading, 8)
            }
            .padding(.bottom, 24)

            // Welcome message
            Text("Welcome,")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)

            Text(userName)
                .font(.system(size: 42, weight: .heavy))
                .tracking(-1)
                .foregroundColor(themeManager.theme.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .sheet(isPresented: $showingMenu) {
            MenuSheetView()
        }
    }

    // MARK: - Featured Session Card (Clickable)

    private var featuredSessionCard: some View {
        Button(action: { showingSessionEditor = true }) {
            VStack(spacing: 0) {
                // Image area - ready for real course photos
                ZStack(alignment: .topLeading) {
                    // Modern placeholder background
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: themeManager.isDark ?
                                [Color(hex: "1A1A1A"), Color(hex: "0F0F0F")] :
                                [Color(hex: "F5F5F5"), Color(hex: "E8E8E8")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        // Decorative elements - subtle
                        GeometryReader { geo in
                            Circle()
                                .fill(themeManager.theme.textSecondary.opacity(0.04))
                                .frame(width: 200, height: 200)
                                .offset(x: geo.size.width - 80, y: -40)

                            Circle()
                                .fill(themeManager.theme.textSecondary.opacity(0.03))
                                .frame(width: 150, height: 150)
                                .offset(x: -40, y: geo.size.height - 80)

                            // Horizon line
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: geo.size.height * 0.6))
                                path.addQuadCurve(
                                    to: CGPoint(x: geo.size.width, y: geo.size.height * 0.55),
                                    control: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.45)
                                )
                            }
                            .stroke(themeManager.theme.textSecondary.opacity(0.08), lineWidth: 1.5)
                        }

                        // Golf flag icon - subtle
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.theme.textSecondary.opacity(0.06))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "flag.fill")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(themeManager.theme.textSecondary.opacity(0.25))
                            }
                        }
                    }
                    .frame(height: 200)

                    VStack(alignment: .leading, spacing: 8) {
                        // Deadline badge
                        Text("PLAY BY MAY 15")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(themeManager.theme.textInverse)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(themeManager.theme.textPrimary)
                            .clipShape(Capsule())

                        Spacer()

                        // Tap to edit hint
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                            Text("TAP TO EDIT")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .padding(18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                // Content area
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 24) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.primary)
                            Text(formatDate(sessionDate))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.primary)
                            Text(formatTime(sessionTime))
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(themeManager.theme.textPrimary)

                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.primary)
                        Text(sessionLocation)
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
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(themeManager.theme.border.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.06), radius: 24, x: 0, y: 12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingSessionEditor) {
            SessionEditorSheet(
                sessionDate: $sessionDate,
                sessionTime: $sessionTime,
                sessionLocation: $sessionLocation
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func playerRow(player: Player) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(player.isCaptain ? themeManager.theme.textPrimary : themeManager.theme.accentBlue)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(player.isCaptain ? themeManager.theme.textInverse : .white)
                )

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
                    .foregroundColor(themeManager.theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.theme.textPrimary.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            QuickActionCard(title: "Today's Drills", subtitle: "\(DrillsManager.shared.drills.count - DrillsManager.shared.completedCount) remaining", icon: "figure.golf") {
                showingDrills = true
            }
            QuickActionCard(title: "Last Session", subtitle: "2 days ago", icon: "clock") {
                navigationManager.navigateToLastSession()
            }
            QuickActionCard(title: "Recruit Views", subtitle: "12 coaches", icon: "eye") {
                navigationManager.navigateToRecruit()
            }
        }
    }

    // MARK: - Plays of the Week

    private var playsOfWeekScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(MockData.playsOfWeek.enumerated()), id: \.element.id) { index, play in
                    PlayOfWeekCard(play: play) {
                        selectedPlayIndex = index
                        showingPlaysViewer = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
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
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
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

    private func sectionView<Content: View>(
        label: String,
        showViewAll: Bool = false,
        viewAllAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                if showViewAll {
                    Button(action: {
                        if let action = viewAllAction {
                            action()
                        } else {
                            navigationManager.navigateToVideo()
                        }
                    }) {
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

// MARK: - Session Editor Sheet

struct SessionEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var sessionDate: Date
    @Binding var sessionTime: Date
    @Binding var sessionLocation: String

    private let locations = [
        "Main, Birchwood Park Golf Centre",
        "Oakmont Country Club",
        "Pebble Beach Golf Links",
        "Torrey Pines Golf Course",
        "Del Mar Country Club",
        "Augusta National Golf Club"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(themeManager.theme.primary.opacity(0.15))
                            .frame(width: 72, height: 72)

                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.theme.primary)
                    }

                    Text("Edit Session")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                List {
                    Section {
                        DatePicker("Date", selection: $sessionDate, displayedComponents: .date)
                            .tint(themeManager.theme.primary)

                        DatePicker("Time", selection: $sessionTime, displayedComponents: .hourAndMinute)
                            .tint(themeManager.theme.primary)
                    } header: {
                        Text("Date & Time")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                    }

                    Section {
                        ForEach(locations, id: \.self) { location in
                            Button(action: { sessionLocation = location }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(location.components(separatedBy: ", ").last ?? location)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(themeManager.theme.textPrimary)

                                        if location.contains(", ") {
                                            Text(location.components(separatedBy: ", ").first ?? "")
                                                .font(.system(size: 12))
                                                .foregroundColor(themeManager.theme.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    if sessionLocation == location {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(themeManager.theme.primary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Location")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                    }
                }
                .listStyle(.insetGrouped)

                // Save button
                Button(action: { dismiss() }) {
                    Text("Save Changes")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.theme.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.theme.primary)
                        .cornerRadius(28)
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

// MARK: - Performance Detail View

struct PerformanceDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header stats
                    VStack(spacing: 20) {
                        EndlessLogo(size: 48, showText: false)

                        Text("Performance Stats")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text("Your golf statistics at a glance")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                    .padding(.vertical, 24)

                    // Main stats grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        performanceCard(
                            title: "Greens in Regulation",
                            value: "72%",
                            change: "+3%",
                            isPositive: true,
                            icon: "figure.golf"
                        )

                        performanceCard(
                            title: "Fairways Hit",
                            value: "65%",
                            change: "+5%",
                            isPositive: true,
                            icon: "flag.fill"
                        )

                        performanceCard(
                            title: "Average Putts",
                            value: "28.4",
                            change: "-1.2",
                            isPositive: true,
                            icon: "circle.fill"
                        )

                        performanceCard(
                            title: "Scoring Average",
                            value: "71.3",
                            change: "-0.8",
                            isPositive: true,
                            icon: "trophy.fill"
                        )
                    }
                    .padding(.horizontal, 20)

                    // Recent rounds section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("RECENT ROUNDS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(themeManager.theme.textSecondary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            roundRow(course: "Oakmont CC", score: 71, date: "Dec 12")
                            Divider().padding(.leading, 60)
                            roundRow(course: "Pebble Beach", score: 73, date: "Dec 10")
                            Divider().padding(.leading, 60)
                            roundRow(course: "Del Mar CC", score: 70, date: "Dec 8")
                            Divider().padding(.leading, 60)
                            roundRow(course: "Torrey Pines", score: 72, date: "Dec 5")
                        }
                        .background(themeManager.theme.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                    }

                    // Trends section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PERFORMANCE TRENDS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(themeManager.theme.textSecondary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 16) {
                            trendRow(title: "Driving Distance", value: "275 yds", trend: "up")
                            trendRow(title: "Driving Accuracy", value: "68%", trend: "up")
                            trendRow(title: "Sand Saves", value: "45%", trend: "down")
                            trendRow(title: "Up & Down", value: "58%", trend: "up")
                        }
                        .padding(20)
                        .background(themeManager.theme.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(themeManager.theme.background)
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

    private func performanceCard(title: String, value: String, change: String, isPositive: Bool, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(themeManager.theme.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.theme.primary)
                    )

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                    Text(change)
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(isPositive ? themeManager.theme.accentGreen : themeManager.theme.error)
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(18)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(20)
    }

    private func roundRow(course: String, score: Int, date: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(themeManager.theme.primary)
                .frame(width: 44, height: 44)
                .overlay(
                    Text("\(score)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(course)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            Text(score <= 72 ? "Under Par" : "Over Par")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(score <= 72 ? themeManager.theme.accentGreen : themeManager.theme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background((score <= 72 ? themeManager.theme.accentGreen : themeManager.theme.textSecondary).opacity(0.15))
                .cornerRadius(10)
        }
        .padding(16)
    }

    private func trendRow(title: String, value: String, trend: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)

            Spacer()

            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Image(systemName: trend == "up" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(trend == "up" ? themeManager.theme.accentGreen : themeManager.theme.error)
            }
        }
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
