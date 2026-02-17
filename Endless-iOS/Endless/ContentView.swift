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
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedTab = 0
                }
            }

            TabBarButton(icon: "play.rectangle", label: "Video", isSelected: selectedTab == 1) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    onVideoTap?()
                }
            }

            // Center Record Button
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedTab = 2
                }
            }) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 52, height: 52)
                        .shadow(color: themeManager.theme.accentGreen.opacity(0.3), radius: 12, x: 0, y: 4)

                    Image(systemName: selectedTab == 2 ? "camera.fill" : "plus")
                        .font(.system(size: selectedTab == 2 ? 18 : 22, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -4)

            TabBarButton(icon: "person.text.rectangle", label: "Recruit", isSelected: selectedTab == 3) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedTab = 3
                }
            }

            TabBarButton(icon: "gearshape", label: "Settings", isSelected: selectedTab == 4) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedTab = 4
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            ZStack {
                // Frosted glass background
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(themeManager.theme.tabBarBackground.opacity(0.85))

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(themeManager.theme.border.opacity(0.3), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(themeManager.isDark ? 0.4 : 0.06), radius: 20, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
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
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? themeManager.theme.tabBarActive : themeManager.theme.tabBarInactive)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? themeManager.theme.tabBarActive : themeManager.theme.tabBarInactive)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isSelected ? themeManager.theme.textPrimary.opacity(0.08) : Color.clear)
                    .padding(.horizontal, 4)
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
