import SwiftUI
import FirebaseCore

// MARK: - Firebase App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App

@main
struct EndlessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authManager = AuthenticationManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeManager)
                .environmentObject(authManager)
        }
    }
}

// MARK: - Root View (Handles Auth State)

struct RootView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        ZStack {
            switch authManager.authState {
            case .undefined:
                // Loading state
                ZStack {
                    themeManager.theme.background
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        EndlessLogo(size: 80, showText: true)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: themeManager.theme.accentGreen))
                            .scaleEffect(1.2)
                    }
                }

            case .unauthenticated:
                // Show login/signup
                AuthenticationView()
                    .environmentObject(themeManager)
                    .transition(.opacity)

            case .authenticated:
                // Show main app
                ContentView()
                    .environmentObject(themeManager)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.authState)
    }
}
