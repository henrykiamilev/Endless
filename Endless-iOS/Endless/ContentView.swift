import SwiftUI
import Combine
import UserNotifications

// Navigation Manager to handle tab switching across views
class NavigationManager: ObservableObject {
    @Published var selectedTab = 0
    @Published var showVideoDetail = false
    @Published var selectedVideoId: String?
    @Published var selectedSessionId: String?
    @Published var videoLibrarySubTab = 0  // 0 = Video, 1 = Stats

    func navigateToVideo() {
        videoLibrarySubTab = 0  // Always show Video tab when navigating
        selectedTab = 1
    }

    func navigateToLastSession() {
        // Navigate to video tab and select the first (most recent) session
        videoLibrarySubTab = 0
        selectedSessionId = MockData.sessions.first?.id
        selectedTab = 1
    }

    func navigateToRecord() {
        selectedTab = 2
    }

    func navigateToRecruit() {
        selectedTab = 3
    }

    func navigateToSettings() {
        selectedTab = 4
    }

    func navigateToHome() {
        selectedTab = 0
    }

    // Legacy function for compatibility
    func navigateToAI() {
        // AI features are now integrated elsewhere
        selectedTab = 0
    }
}

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var navigationManager = NavigationManager()
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var showingNotificationPrompt = false

    init() {
        // Hide default TabView appearance
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch navigationManager.selectedTab {
                case 0:
                    HomeView()
                case 1:
                    VideoLibraryView()
                case 2:
                    GolfSessionView()
                case 3:
                    RecruitView()
                case 4:
                    SettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $navigationManager.selectedTab, onVideoTap: {
                navigationManager.navigateToVideo()
            })
        }
        .environmentObject(navigationManager)
        .background(themeManager.theme.background)
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
        .onChange(of: authManager.isNewAccount) { _, isNew in
            if isNew {
                showingNotificationPrompt = true
                authManager.isNewAccount = false
            }
        }
        .alert("Enable Notifications?", isPresented: $showingNotificationPrompt) {
            Button("Not Now", role: .cancel) { }
            Button("Enable") {
                requestNotificationPermission()
            }
        } message: {
            Text("Stay up to date with coach messages, session reminders, and weekly progress updates. You can change this anytime in Settings.")
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                let settings = UserSettingsManager.shared
                settings.pushEnabled = granted
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var onVideoTap: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house", label: "Home", isSelected: selectedTab == 0) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }

            TabBarButton(icon: "video", label: "Video", isSelected: selectedTab == 1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onVideoTap?()
                }
            }

            // Center Record Button with golf green accent
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 2
                }
            }) {
                ZStack {
                    // Main button with golf green - rounded square
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.theme.accentGreen,
                                    themeManager.theme.accentGreen.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: themeManager.theme.accentGreen.opacity(0.35), radius: 14, x: 0, y: 6)

                    // Icon
                    Image(systemName: selectedTab == 2 ? "camera.fill" : "plus")
                        .font(.system(size: selectedTab == 2 ? 20 : 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -22)

            TabBarButton(icon: "person.crop.rectangle.stack", label: "Recruit", isSelected: selectedTab == 3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 3
                }
            }

            TabBarButton(icon: "gearshape", label: "Settings", isSelected: selectedTab == 4) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 4
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 28)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(themeManager.theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(themeManager.theme.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(themeManager.isDark ? 0.4 : 0.08), radius: 24, x: 0, y: -2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                // Icon with rounded-square background
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? themeManager.theme.accentGreen : themeManager.theme.tabBarInactive)
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? themeManager.theme.accentGreen.opacity(0.15) : Color.clear)
                    )

                // Label
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? themeManager.theme.accentGreen : themeManager.theme.tabBarInactive)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
