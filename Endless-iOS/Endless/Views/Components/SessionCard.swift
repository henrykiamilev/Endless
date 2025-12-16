import SwiftUI

struct SessionCard: View {
    let session: Session
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail area - designed for real images
                ZStack(alignment: .bottomLeading) {
                    if let thumbnail = session.thumbnail {
                        AsyncImage(url: URL(string: thumbnail)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            thumbnailPlaceholder
                        }
                    } else {
                        thumbnailPlaceholder
                    }

                    // Gradient overlay for text readability
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Location badge
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 8, weight: .semibold))
                        Text(session.location)
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
                }
                .frame(width: 160, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Content area
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(session.date)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.top, 12)
                .padding(.horizontal, 2)
            }
            .frame(width: 160)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: themeManager.isDark ?
                    [Color(hex: "1A1A1A"), Color(hex: "0D0D0D")] :
                    [Color(hex: "F5F5F5"), Color(hex: "E8E8E8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle pattern overlay
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 20
                    for i in stride(from: 0, to: geo.size.width + geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: i))
                    }
                }
                .stroke(themeManager.theme.textSecondary.opacity(0.05), lineWidth: 1)
            }

            // Golf icon with subtle styling
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeManager.theme.textSecondary.opacity(0.08))
                        .frame(width: 44, height: 44)

                    Image(systemName: "figure.golf")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary.opacity(0.4))
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        SessionCard(session: MockData.sessions[0])
        SessionCard(session: MockData.sessions[0])
    }
    .environmentObject(ThemeManager())
    .padding()
}
