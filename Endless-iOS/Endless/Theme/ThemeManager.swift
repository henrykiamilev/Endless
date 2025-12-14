import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDark: Bool {
        didSet {
            UserDefaults.standard.set(isDark, forKey: "isDarkMode")
        }
    }

    var theme: AppTheme {
        isDark ? .dark : .light
    }

    init() {
        self.isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
    }

    func toggleTheme() {
        isDark.toggle()
    }
}
