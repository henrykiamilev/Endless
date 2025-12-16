import SwiftUI

struct PlayOfWeekCard: View {
    let play: PlayOfTheWeek
    var action: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false
    @State private var localComments: [PlayComment]
    @State private var newCommentText = ""

    init(play: PlayOfTheWeek, action: (() -> Void)? = nil) {
        self.play = play
        self.action = action
        _likeCount = State(initialValue: play.likes)
        _localComments = State(initialValue: play.comments)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Image area - clickable to open full viewer
            Button(action: { action?() }) {
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

                        // Bottom player info
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
                        }
                        .padding(16)
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())

            // Bottom info section with interactive buttons
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

                // Interactive like and comment buttons
                HStack(spacing: 16) {
                    // Like button
                    Button(action: toggleLike) {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isLiked ? .red : themeManager.theme.textSecondary)
                            Text("\(likeCount)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isLiked ? .red : themeManager.theme.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            isLiked
                                ? Color.red.opacity(0.1)
                                : themeManager.theme.background
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Comment button
                    Button(action: { showComments = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 16))
                            Text("\(localComments.count)")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(themeManager.theme.background)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Watch button
                    Button(action: { action?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            Text("WATCH")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(themeManager.theme.textInverse)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(themeManager.theme.textPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(14)
            .background(themeManager.theme.cardBackground)
        }
        .frame(width: 260)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 20, x: 0, y: 10)
        .sheet(isPresented: $showComments) {
            CardCommentsSheet(
                play: play,
                comments: $localComments,
                newCommentText: $newCommentText
            )
            .presentationDetents([.medium])
        }
    }

    private func toggleLike() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
            if isLiked {
                likeCount += 1
            } else {
                likeCount -= 1
            }
        }
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

// MARK: - Card Comments Sheet

struct CardCommentsSheet: View {
    let play: PlayOfTheWeek
    @Binding var comments: [PlayComment]
    @Binding var newCommentText: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment)
                        }

                        if comments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 32))
                                    .foregroundColor(themeManager.theme.textMuted)
                                Text("No comments yet")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.theme.textSecondary)
                                Text("Be the first to comment!")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textMuted)
                            }
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(16)
                }

                // Input area
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newCommentText)
                        .font(.system(size: 14))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Capsule())

                    Button(action: postComment) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(newCommentText.isEmpty ? themeManager.theme.textMuted : themeManager.theme.accentGreen)
                    }
                    .disabled(newCommentText.isEmpty)
                }
                .padding(16)
                .background(themeManager.theme.background)
            }
            .background(themeManager.theme.background)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.textPrimary)
                }
            }
        }
    }

    private func postComment() {
        guard !newCommentText.isEmpty else { return }

        let comment = PlayComment(
            id: UUID().uuidString,
            userName: "You",
            text: newCommentText,
            timestamp: Date()
        )

        withAnimation {
            comments.append(comment)
        }
        newCommentText = ""
    }
}

// MARK: - Comment Row

struct CommentRow: View {
    let comment: PlayComment
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(themeManager.theme.accentGreen)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(comment.userName.prefix(1)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(comment.userName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(timeAgo(from: comment.timestamp))
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textMuted)
                }

                Text(comment.text)
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else {
            return "\(Int(interval / 86400))d"
        }
    }
}

#Preview {
    PlayOfWeekCard(play: MockData.playsOfWeek[0])
        .environmentObject(ThemeManager())
        .padding()
}
