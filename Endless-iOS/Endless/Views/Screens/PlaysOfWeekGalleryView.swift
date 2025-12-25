import SwiftUI

struct PlaysOfWeekGalleryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingViewer = false
    @State private var selectedPlayIndex = 0
    @State private var plays: [PlayOfTheWeek] = MockData.playsOfWeek

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.theme.background.ignoresSafeArea()

                if plays.isEmpty {
                    emptyState
                } else {
                    galleryContent
                }
            }
            .navigationTitle("Plays of the Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingViewer) {
            PlaysOfWeekViewer(startingIndex: selectedPlayIndex)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.cardBackground)
                    .frame(width: 120, height: 120)

                Image(systemName: "star.circle")
                    .font(.system(size: 48))
                    .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No Plays Yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("The best plays from the community\nwill appear here each week")
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 14))
                    Text("Record your best shots")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(themeManager.theme.textMuted)

                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle")
                        .font(.system(size: 14))
                    Text("Submit for a chance to be featured")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(themeManager.theme.textMuted)
            }
            .padding(.top, 8)
        }
        .padding(40)
    }

    // MARK: - Gallery Content

    private var galleryContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header info
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.primary)
                        Text("This Week's Top Plays")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    Text("\(plays.count) featured \(plays.count == 1 ? "play" : "plays")")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textMuted)
                }
                .padding(.top, 8)

                // Grid of plays
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(plays.enumerated()), id: \.element.id) { index, play in
                        GalleryPlayCard(play: play, rank: index + 1) {
                            selectedPlayIndex = index
                            showingViewer = true
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Gallery Play Card

struct GalleryPlayCard: View {
    let play: PlayOfTheWeek
    let rank: Int
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isLiked = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Thumbnail
                ZStack(alignment: .topLeading) {
                    // Background
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "1A3A2A"),
                                Color(hex: "0D1F15")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        // Decorative elements
                        GeometryReader { geo in
                            Ellipse()
                                .fill(Color(hex: "22C55E").opacity(0.12))
                                .frame(width: geo.size.width * 1.2, height: 80)
                                .offset(x: -geo.size.width * 0.1, y: geo.size.height - 25)
                        }

                        // Play icon
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial.opacity(0.6))
                                .frame(width: 44, height: 44)

                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .offset(x: 1)
                        }
                    }

                    // Gradient overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    // Rank badge
                    if rank <= 3 {
                        HStack(spacing: 4) {
                            Image(systemName: rank == 1 ? "trophy.fill" : "star.fill")
                                .font(.system(size: 9))
                            Text("#\(rank)")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            rank == 1 ? Color(hex: "FFD700") :
                            rank == 2 ? Color(hex: "C0C0C0") :
                            Color(hex: "CD7F32")
                        )
                        .clipShape(Capsule())
                        .padding(8)
                    }
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Info section
                VStack(alignment: .leading, spacing: 8) {
                    // Player info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(themeManager.theme.accentGreen)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(String(play.playerName.prefix(1)))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 1) {
                            Text(play.playerName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(themeManager.theme.textPrimary)
                                .lineLimit(1)

                            Text(play.playerTitle)
                                .font(.system(size: 10))
                                .foregroundColor(themeManager.theme.textSecondary)
                                .lineLimit(1)
                        }
                    }

                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 9))
                        Text(play.location.components(separatedBy: " ").first ?? play.location)
                            .font(.system(size: 10))
                            .lineLimit(1)
                    }
                    .foregroundColor(themeManager.theme.textMuted)

                    // Engagement stats
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red.opacity(0.8))
                            Text("\(play.likes)")
                                .font(.system(size: 11, weight: .medium))
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "bubble.right.fill")
                                .font(.system(size: 10))
                            Text("\(play.comments.count)")
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.theme.cardBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlaysOfWeekGalleryView()
        .environmentObject(ThemeManager())
}
