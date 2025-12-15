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
                // Icon with subtle styling
                ZStack {
                    // Simple circle background
                    Circle()
                        .fill(themeManager.theme.textSecondary.opacity(0.08))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary.opacity(0.7))
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
