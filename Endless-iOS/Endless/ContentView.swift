import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
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

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
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
                selectedTab = 0
            }

            TabBarButton(icon: "video", label: "Video", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            // Center Record Button
            Button(action: { selectedTab = 2 }) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.primary)
                        .frame(width: 62, height: 62)
                        .shadow(color: themeManager.theme.primary.opacity(0.4), radius: 12, x: 0, y: 6)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(themeManager.theme.textInverse)
                }
            }
            .offset(y: -24)

            TabBarButton(icon: "sparkles", label: "AI", isSelected: selectedTab == 3) {
                selectedTab = 3
            }

            TabBarButton(icon: "gearshape", label: "Settings", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(28)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
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
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(themeManager.theme.primary.opacity(0.15))
                            .frame(width: 40, height: 40)
                    }

                    Image(systemName: isSelected ? "\(icon).fill" : icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? themeManager.theme.textPrimary : themeManager.theme.tabBarInactive)
                }
                .frame(width: 40, height: 40)

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? themeManager.theme.textPrimary : themeManager.theme.tabBarInactive)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
