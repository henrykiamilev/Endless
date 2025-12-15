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
                // Icon with modern styling
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(themeManager.theme.accentGreen.opacity(0.15), lineWidth: 2)
                        .frame(width: 52, height: 52)

                    // Inner circle
                    Circle()
                        .fill(themeManager.theme.accentGreen.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.theme.accentGreen)
                }

                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(themeManager.theme.border.opacity(0.5), lineWidth: 1)
            )
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
