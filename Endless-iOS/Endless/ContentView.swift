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

    func navigateToRecord() {
        selectedTab = 2
    }

    func navigateToAI() {
        selectedTab = 3
    }

    func navigateToSettings() {
        selectedTab = 4
    }

    func navigateToHome() {
        selectedTab = 0
    }
}

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var navigationManager = NavigationManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $navigationManager.selectedTab) {
                HomeView()
                    .tag(0)

                VideoLibraryView()
                    .tag(1)

                RecordView()
                    .tag(2)

                EndlessAIView()
                    .tag(3)

                SettingsView()
                    .tag(4)
            }
            .environmentObject(navigationManager)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $navigationManager.selectedTab)
        }
        .background(themeManager.theme.background)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house", label: "Home", isSelected: selectedTab == 0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }

            TabBarButton(icon: "video", label: "Video", isSelected: selectedTab == 1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }

            // Center Record Button with Endless Logo inspired design
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }) {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.theme.primary.opacity(0.3),
                                    themeManager.theme.primary.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 72, height: 72)
                        .blur(radius: 4)

                    // Main button
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.theme.primary,
                                    themeManager.theme.primary.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: themeManager.theme.primary.opacity(0.5), radius: 16, x: 0, y: 8)

                    // Inner ring
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 52, height: 52)

                    // Icon
                    Image(systemName: selectedTab == 2 ? "camera.fill" : "plus")
                        .font(.system(size: selectedTab == 2 ? 22 : 26, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(selectedTab == 2 ? 1.1 : 1.0)
                }
            }
            .offset(y: -28)

            TabBarButton(icon: "sparkles", label: "AI", isSelected: selectedTab == 3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 3
                }
            }

            TabBarButton(icon: "gearshape", label: "Settings", isSelected: selectedTab == 4) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 4
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 14)
        .padding(.bottom, 30)
        .background(
            ZStack {
                // Background with subtle gradient
                RoundedRectangle(cornerRadius: 32)
                    .fill(themeManager.theme.cardBackground)

                // Top highlight
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.8),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.1), radius: 20, x: 0, y: -4)
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
            VStack(spacing: 5) {
                ZStack {
                    // Selection indicator
                    if isSelected {
                        Circle()
                            .fill(themeManager.theme.primary.opacity(0.12))
                            .frame(width: 44, height: 44)
                    }

                    // Icon
                    Image(systemName: isSelected ? "\(icon).fill" : icon)
                        .font(.system(size: 21, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? themeManager.theme.primary : themeManager.theme.tabBarInactive)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(width: 44, height: 44)

                // Label
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? themeManager.theme.primary : themeManager.theme.tabBarInactive)

                // Selection dot
                if isSelected {
                    Circle()
                        .fill(themeManager.theme.primary)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
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
