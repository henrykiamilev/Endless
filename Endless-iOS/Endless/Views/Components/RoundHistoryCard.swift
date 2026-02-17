import SwiftUI

struct RoundHistoryCard: View {
    let round: RoundHistory
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                // Course icon with gradient
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [themeManager.theme.accentGreen.opacity(0.12), themeManager.theme.accentGreen.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: "figure.golf")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.theme.accentGreen)
                }

                // Course info
                VStack(alignment: .leading, spacing: 4) {
                    Text(round.course)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(round.date)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                // Score badge
                VStack(spacing: 2) {
                    Text("\(round.score)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(scoreColor)
                    Text("score")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)
                        .textCase(.uppercase)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var scoreColor: Color {
        if round.score <= 71 {
            return themeManager.theme.accentGreen
        } else if round.score <= 73 {
            return themeManager.theme.primary
        } else {
            return themeManager.theme.textSecondary
        }
    }
}

#Preview {
    VStack {
        ForEach(MockData.roundHistory) { round in
            RoundHistoryCard(round: round)
        }
    }
    .padding()
    .environmentObject(ThemeManager())
}
