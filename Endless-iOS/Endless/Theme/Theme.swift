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
        primary: Color.white,
        primaryLight: Color.white.opacity(0.9),
        primaryDark: Color(hex: "E0E0E0"),

        background: Color(hex: "121210"),
        backgroundSecondary: Color(hex: "1A1A17"),
        cardBackground: Color(hex: "1E1E1B"),
        cardBackgroundElevated: Color(hex: "262622"),

        textPrimary: Color(hex: "F5F2ED"),
        textSecondary: Color(hex: "9B978F"),
        textMuted: Color(hex: "6B6860"),
        textInverse: Color(hex: "121210"),

        accent: Color(hex: "4CAF82"),  // Warm green accent
        accentGreen: Color(hex: "4CAF82"),  // Warm green accent
        accentYellow: Color(hex: "FCD34D"),
        accentRed: Color(hex: "F87171"),
        accentBlue: Color(hex: "60A5FA"),
        accentOlive: Color(hex: "84CC16"),

        border: Color(hex: "2A2A26"),
        borderLight: Color(hex: "353530"),

        success: Color(hex: "4CAF82"),
        warning: Color(hex: "FCD34D"),
        error: Color(hex: "F87171"),
        info: Color(hex: "60A5FA"),

        tabBarBackground: Color(hex: "1A1A17"),
        tabBarActive: Color(hex: "F5F2ED"),
        tabBarInactive: Color(hex: "6B6860"),

        buttonPrimary: Color(hex: "F5F2ED"),
        buttonPrimaryText: Color(hex: "121210"),
        buttonSecondary: Color(hex: "2A2A26"),
        buttonSecondaryText: Color(hex: "F5F2ED"),

        overlayDark: Color.black.opacity(0.8),
        overlayLight: Color.black.opacity(0.5),

        isDark: true
    )

    static let light = AppTheme(
        primary: Color(hex: "2C2C2A"),
        primaryLight: Color(hex: "4A4A46"),
        primaryDark: Color(hex: "1A1A18"),

        background: Color(hex: "F8F6F1"),
        backgroundSecondary: Color(hex: "F0EDE6"),
        cardBackground: Color(hex: "FFFFFF"),
        cardBackgroundElevated: Color(hex: "FFFFFF"),

        textPrimary: Color(hex: "2C2C2A"),
        textSecondary: Color(hex: "8A8680"),
        textMuted: Color(hex: "B5B0A8"),
        textInverse: .white,

        accent: Color(hex: "3D9E6F"),  // Warm green accent
        accentGreen: Color(hex: "3D9E6F"),  // Warm green accent
        accentYellow: Color(hex: "EAB308"),
        accentRed: Color(hex: "EF4444"),
        accentBlue: Color(hex: "3B82F6"),
        accentOlive: Color(hex: "84CC16"),

        border: Color(hex: "E8E4DC"),
        borderLight: Color(hex: "D8D4CC"),

        success: Color(hex: "3D9E6F"),
        warning: Color(hex: "EAB308"),
        error: Color(hex: "EF4444"),
        info: Color(hex: "3B82F6"),

        tabBarBackground: Color(hex: "FFFFFF"),
        tabBarActive: Color(hex: "2C2C2A"),
        tabBarInactive: Color(hex: "B5B0A8"),

        buttonPrimary: Color(hex: "2C2C2A"),
        buttonPrimaryText: .white,
        buttonSecondary: Color(hex: "F0EDE6"),
        buttonSecondaryText: Color(hex: "2C2C2A"),

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
