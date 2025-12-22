import SwiftUI

@main
struct EndlessApp: App {
    @StateObject private var themeManager = ThemeManager()

    init() {
        // Reset all cached data to simulate fresh install for new user experience
        // Remove this block after testing if you want data to persist between launches
        resetAppToNewUserState()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
    }

    /// Clears all cached user data to simulate a fresh app install
    private func resetAppToNewUserState() {
        // Clear profile data
        RecruitProfileManager.shared.resetToDefaults()

        // Clear widget preferences
        WidgetPreferencesManager.shared.resetToDefaults()

        // Clear video storage
        VideoStorageManager.shared.clearAllVideos()
    }
}
