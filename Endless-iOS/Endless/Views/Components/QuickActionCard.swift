import SwiftUI

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 14) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [themeManager.theme.accentGreen.opacity(0.15), themeManager.theme.accentGreen.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.theme.accentGreen)
                }

                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    themeManager.theme.cardBackground
                    // Subtle top highlight
                    VStack {
                        LinearGradient(
                            colors: [themeManager.theme.accentGreen.opacity(0.03), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)
                        Spacer()
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(themeManager.theme.border.opacity(0.5), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(themeManager.isDark ? 0.25 : 0.06), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 12) {
        QuickActionCard(title: "Today's Drills", subtitle: "5 remaining", icon: "figure.golf")
        QuickActionCard(title: "Last Session", subtitle: "2 days ago", icon: "clock")
    }
    .environmentObject(ThemeManager())
    .padding()
}
