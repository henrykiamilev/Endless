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

        background: Color(hex: "000000"),
        backgroundSecondary: Color(hex: "0A0A0A"),
        cardBackground: Color(hex: "141414"),
        cardBackgroundElevated: Color(hex: "1C1C1C"),

        textPrimary: .white,
        textSecondary: Color(hex: "9CA3AF"),
        textMuted: Color(hex: "6B7280"),
        textInverse: Color(hex: "000000"),

        accent: Color(hex: "22C55E"),  // Golf green accent
        accentGreen: Color(hex: "22C55E"),  // Golf green
        accentYellow: Color(hex: "FCD34D"),
        accentRed: Color(hex: "F87171"),
        accentBlue: Color(hex: "60A5FA"),
        accentOlive: Color(hex: "84CC16"),

        border: Color(hex: "262626"),
        borderLight: Color(hex: "333333"),

        success: Color(hex: "22C55E"),
        warning: Color(hex: "FCD34D"),
        error: Color(hex: "F87171"),
        info: Color(hex: "60A5FA"),

        tabBarBackground: Color(hex: "0A0A0A"),
        tabBarActive: .white,
        tabBarInactive: Color(hex: "6B7280"),

        buttonPrimary: .white,
        buttonPrimaryText: Color(hex: "000000"),
        buttonSecondary: Color(hex: "262626"),
        buttonSecondaryText: .white,

        overlayDark: Color.black.opacity(0.8),
        overlayLight: Color.black.opacity(0.5),

        isDark: true
    )

    static let light = AppTheme(
        primary: Color(hex: "1A1A1A"),
        primaryLight: Color(hex: "333333"),
        primaryDark: Color(hex: "000000"),

        background: Color(hex: "FFFFFF"),
        backgroundSecondary: Color(hex: "F5F5F5"),
        cardBackground: Color(hex: "FAFAFA"),
        cardBackgroundElevated: .white,

        textPrimary: Color(hex: "1A1A1A"),
        textSecondary: Color(hex: "6B7280"),
        textMuted: Color(hex: "9CA3AF"),
        textInverse: .white,

        accent: Color(hex: "16A34A"),  // Golf green accent
        accentGreen: Color(hex: "16A34A"),  // Golf green
        accentYellow: Color(hex: "EAB308"),
        accentRed: Color(hex: "EF4444"),
        accentBlue: Color(hex: "3B82F6"),
        accentOlive: Color(hex: "84CC16"),

        border: Color(hex: "E5E5E5"),
        borderLight: Color(hex: "D4D4D4"),

        success: Color(hex: "16A34A"),
        warning: Color(hex: "EAB308"),
        error: Color(hex: "EF4444"),
        info: Color(hex: "3B82F6"),

        tabBarBackground: .white,
        tabBarActive: Color(hex: "1A1A1A"),
        tabBarInactive: Color(hex: "9CA3AF"),

        buttonPrimary: Color(hex: "1A1A1A"),
        buttonPrimaryText: .white,
        buttonSecondary: Color(hex: "F5F5F5"),
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
