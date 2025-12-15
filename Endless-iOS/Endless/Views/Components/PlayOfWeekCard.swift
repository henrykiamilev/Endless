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
                        colors: [.clear, .clear, .black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Content overlay
                    VStack {
                        // Top badges
                        HStack {
                            viewersBadge
                            Spacer()

                            // Featured badge
                            Text("FEATURED")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(themeManager.theme.accentGreen)
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
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                // Bottom info section
                VStack(alignment: .leading, spacing: 12) {
                    Text(play.location)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)

                    Text("A beautiful course featuring challenging holes and stunning views perfect for your next round.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // CTA Button
                    Button(action: { action?() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            Text("WATCH NOW")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(0.5)
                        }
                        .foregroundColor(themeManager.theme.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(themeManager.theme.textPrimary)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
                .padding(18)
                .background(themeManager.theme.cardBackground)
            }
            .frame(width: 280)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var thumbnailArea: some View {
        ZStack {
            // Gradient background (placeholder for real image)
            LinearGradient(
                gradient: Gradient(colors: themeManager.isDark ?
                    [Color(hex: "1F1F1F"), Color(hex: "141414")] :
                    [Color(hex: "E8E8E8"), Color(hex: "D4D4D4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative elements
            GeometryReader { geo in
                // Abstract golf course shapes
                Circle()
                    .fill(themeManager.theme.accentGreen.opacity(0.08))
                    .frame(width: 180, height: 180)
                    .offset(x: geo.size.width - 60, y: -40)

                Circle()
                    .fill(themeManager.theme.accentGreen.opacity(0.05))
                    .frame(width: 120, height: 120)
                    .offset(x: -30, y: geo.size.height - 60)
            }

            // Golf flag icon
            VStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(themeManager.theme.accentGreen.opacity(0.25))
            }
        }
    }

    private var viewersBadge: some View {
        HStack(spacing: 6) {
            // Avatar stack
            HStack(spacing: -8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill([
                            themeManager.theme.textPrimary,
                            themeManager.theme.accentBlue,
                            themeManager.theme.accentGreen
                        ][index])
                        .frame(width: 22, height: 22)
                        .overlay(
                            Text(["H", "J", "M"][index])
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(index == 0 ? themeManager.theme.textInverse : .white)
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1.5)
                        )
                }
            }

            Text("+4")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 6)
        .padding(.leading, 6)
        .padding(.trailing, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

#Preview {
    PlayOfWeekCard(play: MockData.playsOfWeek[0])
        .environmentObject(ThemeManager())
        .padding()
}
