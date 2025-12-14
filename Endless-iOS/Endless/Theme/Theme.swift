import SwiftUI

struct AppTheme {
    // Primary colors
    let primary: Color
    let primaryLight: Color
    let primaryDark: Color

    // Background colors
    let background: Color
    let backgroundSecondary: Color
    let cardBackground: Color
    let cardBackgroundElevated: Color

    // Text colors
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color
    let textInverse: Color

    // Accent colors
    let accent: Color
    let accentGreen: Color
    let accentYellow: Color
    let accentRed: Color
    let accentBlue: Color
    let accentOlive: Color

    // Border colors
    let border: Color
    let borderLight: Color

    // Status colors
    let success: Color
    let warning: Color
    let error: Color
    let info: Color

    // Tab bar
    let tabBarBackground: Color
    let tabBarActive: Color
    let tabBarInactive: Color

    // Button colors
    let buttonPrimary: Color
    let buttonPrimaryText: Color
    let buttonSecondary: Color
    let buttonSecondaryText: Color

    // Overlay colors
    let overlayDark: Color
    let overlayLight: Color

    // Mode
    let isDark: Bool
}

extension AppTheme {
    static let dark = AppTheme(
        primary: Color(hex: "00D4AA"),
        primaryLight: Color(hex: "00F5C4"),
        primaryDark: Color(hex: "00B894"),

        background: Color(hex: "0C0C0C"),
        backgroundSecondary: Color(hex: "141414"),
        cardBackground: Color(hex: "1A1A1A"),
        cardBackgroundElevated: Color(hex: "222222"),

        textPrimary: .white,
        textSecondary: Color(hex: "9CA3AF"),
        textMuted: Color(hex: "6B7280"),
        textInverse: Color(hex: "0C0C0C"),

        accent: Color(hex: "00D4AA"),
        accentGreen: Color(hex: "22C55E"),
        accentYellow: Color(hex: "FACC15"),
        accentRed: Color(hex: "EF4444"),
        accentBlue: Color(hex: "3B82F6"),
        accentOlive: Color(hex: "4A5D23"),

        border: Color(hex: "2A2A2A"),
        borderLight: Color(hex: "3A3A3A"),

        success: Color(hex: "22C55E"),
        warning: Color(hex: "FACC15"),
        error: Color(hex: "EF4444"),
        info: Color(hex: "3B82F6"),

        tabBarBackground: Color(hex: "0C0C0C"),
        tabBarActive: Color(hex: "00D4AA"),
        tabBarInactive: Color(hex: "6B7280"),

        buttonPrimary: Color(hex: "00D4AA"),
        buttonPrimaryText: Color(hex: "0C0C0C"),
        buttonSecondary: Color(hex: "2A2A2A"),
        buttonSecondaryText: .white,

        overlayDark: Color.black.opacity(0.7),
        overlayLight: Color.black.opacity(0.4),

        isDark: true
    )

    static let light = AppTheme(
        primary: Color(hex: "00B894"),
        primaryLight: Color(hex: "00D4AA"),
        primaryDark: Color(hex: "009B7D"),

        background: Color(hex: "F5F3EF"),
        backgroundSecondary: Color(hex: "EEEBE5"),
        cardBackground: .white,
        cardBackgroundElevated: Color(hex: "F8F6F2"),

        textPrimary: Color(hex: "1A1A1A"),
        textSecondary: Color(hex: "5C5C5C"),
        textMuted: Color(hex: "8A8A8A"),
        textInverse: .white,

        accent: Color(hex: "00B894"),
        accentGreen: Color(hex: "4A5D23"),
        accentYellow: Color(hex: "C9A227"),
        accentRed: Color(hex: "C53030"),
        accentBlue: Color(hex: "2563EB"),
        accentOlive: Color(hex: "4A5D23"),

        border: Color(hex: "E5E2DC"),
        borderLight: Color(hex: "D1CEC6"),

        success: Color(hex: "4A5D23"),
        warning: Color(hex: "C9A227"),
        error: Color(hex: "C53030"),
        info: Color(hex: "2563EB"),

        tabBarBackground: Color(hex: "F5F3EF"),
        tabBarActive: Color(hex: "00B894"),
        tabBarInactive: Color(hex: "8A8A8A"),

        buttonPrimary: Color(hex: "00B894"),
        buttonPrimaryText: .white,
        buttonSecondary: Color(hex: "E5E2DC"),
        buttonSecondaryText: Color(hex: "1A1A1A"),

        overlayDark: Color.black.opacity(0.6),
        overlayLight: Color.black.opacity(0.3),

        isDark: false
    )
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
