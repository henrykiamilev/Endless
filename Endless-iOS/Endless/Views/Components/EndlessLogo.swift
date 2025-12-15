import SwiftUI

// MARK: - Endless Logo Component

struct EndlessLogo: View {
    let size: CGFloat
    var showText: Bool = false
    var textPosition: TextPosition = .right
    @EnvironmentObject var themeManager: ThemeManager

    enum TextPosition {
        case right, bottom
    }

    var body: some View {
        switch textPosition {
        case .right:
            HStack(spacing: size * 0.25) {
                logoCircle
                if showText {
                    logoText
                }
            }
        case .bottom:
            VStack(spacing: size * 0.2) {
                logoCircle
                if showText {
                    logoText
                }
            }
        }
    }

    private var logoCircle: some View {
        ZStack {
            Circle()
                .fill(themeManager.isDark ? Color.white : Color(hex: "1A1A1A"))
                .frame(width: size, height: size)

            // Infinity symbol
            Text("∞")
                .font(.system(size: size * 0.5, weight: .light))
                .foregroundColor(themeManager.isDark ? Color(hex: "1A1A1A") : .white)
        }
    }

    private var logoText: some View {
        Text("ENDLESS")
            .font(.system(size: size * 0.4, weight: .bold))
            .tracking(size * 0.08)
            .foregroundColor(themeManager.theme.textPrimary)
    }
}

// MARK: - Logo Header Component

struct LogoHeader: View {
    var title: String? = nil
    var subtitle: String? = nil
    var showMenuButton: Bool = true
    var onMenuTap: (() -> Void)? = nil
    var onLogoTap: (() -> Void)? = nil
    var trailing: AnyView? = nil

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar with logo and actions
            HStack {
                if showMenuButton {
                    Button(action: { onMenuTap?() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(Circle())
                    }
                }

                Spacer()

                Button(action: { onLogoTap?() }) {
                    EndlessLogo(size: 44, showText: false)
                }

                if let trailing = trailing {
                    trailing
                        .padding(.leading, 12)
                }
            }
            .padding(.bottom, 24)

            // Title section
            if let title = title {
                Text(title)
                    .font(.system(size: 48, weight: .heavy))
                    .tracking(-2)
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineSpacing(-8)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }
}

// MARK: - Branded Section Header

struct BrandedSectionHeader: View {
    let title: String
    var showViewAll: Bool = false
    var onViewAll: (() -> Void)? = nil

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            Spacer()

            if showViewAll {
                Button(action: { onViewAll?() }) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }
}

// MARK: - Branded Card

struct BrandedCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 24
    var padding: CGFloat = 20

    @EnvironmentObject var themeManager: ThemeManager

    init(cornerRadius: CGFloat = 24, padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - Branded Button

struct BrandedButton: View {
    let title: String
    var icon: String? = nil
    var style: BrandedButtonStyle = .primary
    var isLoading: Bool = false
    let action: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    enum BrandedButtonStyle {
        case primary, secondary, outline
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .tracking(0.5)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(borderColor, lineWidth: style == .outline ? 2 : 0)
            )
        }
        .disabled(isLoading)
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return themeManager.theme.textInverse
        case .secondary:
            return themeManager.theme.textPrimary
        case .outline:
            return themeManager.theme.primary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return themeManager.theme.primary
        case .secondary:
            return themeManager.theme.cardBackgroundElevated
        case .outline:
            return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return themeManager.theme.primary
        default:
            return .clear
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        EndlessLogo(size: 60, showText: true)

        EndlessLogo(size: 80, showText: true, textPosition: .bottom)

        BrandedButton(title: "GET STARTED", icon: "arrow.right", action: {})

        BrandedButton(title: "SECONDARY", style: .secondary, action: {})

        BrandedButton(title: "OUTLINE", style: .outline, action: {})
    }
    .padding()
    .environmentObject(ThemeManager())
}
