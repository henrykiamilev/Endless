import SwiftUI

struct RoundHistoryCard: View {
    let round: RoundHistory
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                // Course icon
                Circle()
                    .fill(themeManager.theme.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "figure.golf")
                            .font(.system(size: 18))
                            .foregroundColor(themeManager.theme.primary)
                    )

                // Course info
                VStack(alignment: .leading, spacing: 3) {
                    Text(round.course)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(round.date)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                // Score
                Text("\(round.score)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(scoreColor)
            }
            .padding(.vertical, 10)
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
