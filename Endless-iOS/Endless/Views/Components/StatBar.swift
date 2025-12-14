import SwiftUI

struct StatBar: View {
    let label: String
    let value: String
    let percentage: Double
    var showPercentageBar: Bool = true
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                Text(showPercentageBar ? "\(value)%" : value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)
            }

            if showPercentageBar {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.theme.backgroundSecondary)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.theme.primary)
                            .frame(width: geometry.size.width * (percentage / 100), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        StatBar(label: "Greens in Regulation", value: "72", percentage: 72)
        StatBar(label: "Fairways Hit", value: "65", percentage: 65)
        StatBar(label: "Scoring Average", value: "71.3", percentage: 90, showPercentageBar: false)
    }
    .padding()
    .environmentObject(ThemeManager())
}
