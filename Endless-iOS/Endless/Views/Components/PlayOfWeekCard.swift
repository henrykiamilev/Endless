import SwiftUI

struct PlayOfWeekCard: View {
    let play: PlayOfTheWeek
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 0) {
                // Top gradient section with play button
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: themeManager.isDark ?
                            [Color(hex: "1A3A2E"), Color(hex: "0A1A14")] :
                            [Color(hex: "C5D9CD"), Color(hex: "8FB09A")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Placeholder icon
                    Image(systemName: "figure.golf")
                        .font(.system(size: 64))
                        .foregroundColor(themeManager.theme.primary.opacity(0.3))

                    // Viewers badge
                    VStack {
                        HStack {
                            viewersBadge
                            Spacer()
                        }
                        .padding(16)
                        Spacer()
                    }

                    // Play button
                    Circle()
                        .fill(themeManager.theme.primary)
                        .frame(width: 64, height: 64)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.theme.textInverse)
                                .offset(x: 2)
                        )
                }
                .frame(height: 220)
                .clipped()

                // Bottom info section
                VStack(alignment: .leading, spacing: 10) {
                    Text(play.location)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)

                    Text("Its unique 47 holes layouts, comprising of a trio of testing nine hole circuits.")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: { action?() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 14))
                            Text("START ROUND")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(themeManager.theme.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(themeManager.theme.primary)
                        .cornerRadius(28)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .background(themeManager.theme.cardBackground)
            }
            .frame(width: 300)
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var viewersBadge: some View {
        HStack(spacing: 8) {
            // Avatars
            HStack(spacing: -10) {
                Circle()
                    .fill(themeManager.theme.primary)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("H")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )

                Circle()
                    .fill(themeManager.theme.accentBlue)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("J")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
            }

            Text("4 FRIENDS ARE HERE")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(20)
    }
}

#Preview {
    PlayOfWeekCard(play: MockData.playsOfWeek[0])
        .environmentObject(ThemeManager())
        .padding()
}
