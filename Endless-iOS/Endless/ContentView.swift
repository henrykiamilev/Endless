import SwiftUI

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
                    VideoView()
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
            .environmentObject(navigationManager)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $navigationManager.selectedTab)
        }
        .background(themeManager.theme.background)
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
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
                    selectedTab = 1
                }
            }

            // Center Record Button with golf green accent
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 2
                }
            }) {
                ZStack {
                    // Main button with golf green
                    Circle()
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
                        .frame(width: 60, height: 60)
                        .shadow(color: themeManager.theme.accentGreen.opacity(0.4), radius: 12, x: 0, y: 6)

                    // Icon
                    Image(systemName: selectedTab == 2 ? "camera.fill" : "plus")
                        .font(.system(size: selectedTab == 2 ? 20 : 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -24)

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
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            themeManager.theme.cardBackground
                .cornerRadius(28)
                .shadow(color: .black.opacity(themeManager.isDark ? 0.4 : 0.08), radius: 16, x: 0, y: -2)
        )
        .padding(.horizontal, 16)
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
            VStack(spacing: 4) {
                // Icon
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? themeManager.theme.textPrimary : themeManager.theme.tabBarInactive)
                    .frame(width: 40, height: 40)

                // Label
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? themeManager.theme.textPrimary : themeManager.theme.tabBarInactive)

                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 20, height: 2)
                } else {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.clear)
                        .frame(width: 20, height: 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
