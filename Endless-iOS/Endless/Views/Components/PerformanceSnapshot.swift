import SwiftUI

struct PerformanceSnapshot: View {
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 22) {
                // Header
                HStack {
                    Text("Performance Snapshot")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Spacer()

                    Text("VIEW ALL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(themeManager.theme.primary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(themeManager.theme.primary.opacity(0.15))
                        .cornerRadius(14)
                }

                // Stats row
                HStack(spacing: 0) {
                    StatItem(
                        icon: "figure.golf",
                        value: "72%",
                        label: "GIR",
                        color: themeManager.theme.accentBlue
                    )

                    StatItem(
                        icon: "flag.fill",
                        value: "65%",
                        label: "FIR",
                        color: themeManager.theme.accentGreen
                    )

                    StatItem(
                        icon: "circle.fill",
                        value: "28.4",
                        label: "Putts",
                        color: themeManager.theme.accentYellow
                    )

                    StatItem(
                        icon: "trophy.fill",
                        value: "71.3",
                        label: "Avg",
                        color: themeManager.theme.primary
                    )
                }
            }
            .padding(22)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(24)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                )

            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(themeManager.theme.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PerformanceSnapshot()
        .environmentObject(ThemeManager())
        .padding()
}
