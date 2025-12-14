import SwiftUI

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.primary.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(themeManager.theme.primary)
                }

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickActionCard(title: "Today's Drills", subtitle: "5 remaining", icon: "figure.golf")
        .environmentObject(ThemeManager())
        .padding()
}
