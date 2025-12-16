import SwiftUI

struct PlayOfWeekCard: View {
    let play: PlayOfTheWeek
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 0) {
                // Image area - ready for real course photos
                ZStack {
                    // Background - will be replaced by real image
                    thumbnailArea

                    // Overlay gradient for content visibility
                    LinearGradient(
                        colors: [.clear, .clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Content overlay
                    VStack {
                        // Top badges
                        HStack {
                            // Player avatar
                            Circle()
                                .fill(themeManager.theme.accentGreen)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(String(play.playerName.prefix(1)))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                )

                            Spacer()

                            // Featured badge
                            Text("FEATURED")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .padding(16)

                        Spacer()

                        // Play button
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 64, height: 64)

                            Circle()
                                .fill(themeManager.theme.textPrimary)
                                .frame(width: 56, height: 56)

                            Image(systemName: "play.fill")
                                .font(.system(size: 22))
                                .foregroundColor(themeManager.theme.textInverse)
                                .offset(x: 2)
                        }

                        Spacer()

                        // Bottom player info and engagement
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(play.playerName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text(play.playerTitle)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            Spacer()

                            // Engagement stats
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 12))
                                    Text("\(play.likes)")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white)

                                HStack(spacing: 4) {
                                    Image(systemName: "bubble.right.fill")
                                        .font(.system(size: 12))
                                    Text("\(play.comments.count)")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .padding(16)
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                // Bottom info section
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.primary)
                        Text(play.location)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .lineLimit(1)
                    }

                    Text("Amazing shot! Watch this incredible play from \(play.playerName).")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(2)

                    // CTA Button
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                        Text("WATCH")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                    }
                    .foregroundColor(themeManager.theme.textInverse)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(themeManager.theme.textPrimary)
                    .clipShape(Capsule())
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
            }
            .frame(width: 260)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var thumbnailArea: some View {
        ZStack {
            // Gradient background (placeholder for real image)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1A3A2A"),
                    Color(hex: "0D1F15")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative elements - subtle golf course feel
            GeometryReader { geo in
                // Fairway shape
                Ellipse()
                    .fill(Color(hex: "22C55E").opacity(0.15))
                    .frame(width: geo.size.width * 1.5, height: 150)
                    .offset(x: -geo.size.width * 0.25, y: geo.size.height - 60)

                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .offset(x: geo.size.width - 40, y: -20)
            }

            // Golf ball
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 16, height: 16)
                .offset(x: 40, y: 50)
        }
    }
}

#Preview {
    PlayOfWeekCard(play: MockData.playsOfWeek[0])
        .environmentObject(ThemeManager())
        .padding()
}
