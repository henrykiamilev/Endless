import SwiftUI

struct PlaysOfWeekViewer: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentIndex: Int
    @State private var showComments = false
    @State private var newComment = ""
    @State private var plays: [PlayOfTheWeek]

    init(startingIndex: Int = 0) {
        _currentIndex = State(initialValue: startingIndex)
        _plays = State(initialValue: MockData.playsOfWeek)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black.ignoresSafeArea()

                // Vertical paging scroll view (TikTok style)
                TabView(selection: $currentIndex) {
                    ForEach(Array(plays.enumerated()), id: \.element.id) { index, play in
                        PlayVideoCard(
                            play: play,
                            onLike: { likePlay(at: index) },
                            onComment: { showComments = true },
                            onShare: { sharePlay(play) }
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                // Top overlay with close button
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial.opacity(0.5))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text("Plays of the Week")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        // Placeholder for balance
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showComments) {
            CommentsSheet(play: plays[currentIndex], newComment: $newComment) { comment in
                addComment(comment, at: currentIndex)
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func likePlay(at index: Int) {
        plays[index].likes += 1
    }

    private func sharePlay(_ play: PlayOfTheWeek) {
        // Share functionality
    }

    private func addComment(_ text: String, at index: Int) {
        let comment = PlayComment(
            id: UUID().uuidString,
            userName: "You",
            text: text,
            timestamp: Date()
        )
        plays[index].comments.append(comment)
        newComment = ""
    }
}

// MARK: - Play Video Card (Full Screen)

struct PlayVideoCard: View {
    let play: PlayOfTheWeek
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void

    @State private var isLiked = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video placeholder background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "1A1A1A"),
                        Color(hex: "0A0A0A")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Decorative golf course elements
                VStack {
                    Spacer()
                    ZStack {
                        // Abstract fairway shape
                        Ellipse()
                            .fill(Color(hex: "22C55E").opacity(0.1))
                            .frame(width: geometry.size.width * 1.5, height: 300)
                            .offset(y: 100)

                        // Golf ball
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 24, height: 24)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .offset(y: -50)
                    }
                }

                // Play icon overlay
                Image(systemName: "play.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white.opacity(0.3))

                // Content overlay
                VStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 16) {
                        // Left side - Player info
                        VStack(alignment: .leading, spacing: 8) {
                            // Player name with avatar
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color(hex: "22C55E"))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(String(play.playerName.prefix(1)))
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(play.playerName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)

                                    Text(play.playerTitle)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }

                            // Location
                            HStack(spacing: 4) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 12))
                                Text(play.location)
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.white.opacity(0.7))

                            // Description
                            Text("Amazing shot from the fairway! Watch this incredible approach shot land within feet of the pin. 🏌️‍♂️⛳️")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(3)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Right side - Action buttons
                        VStack(spacing: 20) {
                            // Like button
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    isLiked.toggle()
                                }
                                onLike()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 28))
                                        .foregroundColor(isLiked ? .red : .white)
                                        .scaleEffect(isLiked ? 1.1 : 1.0)

                                    Text("\(play.likes + (isLiked ? 1 : 0))")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Comment button
                            Button(action: onComment) {
                                VStack(spacing: 4) {
                                    Image(systemName: "bubble.right")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)

                                    Text("\(play.comments.count)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Share button
                            Button(action: onShare) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrowshape.turn.up.right")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)

                                    Text("Share")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Bookmark button
                            Button(action: {}) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Comments Sheet

struct CommentsSheet: View {
    let play: PlayOfTheWeek
    @Binding var newComment: String
    let onSubmit: (String) -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if play.comments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))

                                Text("No comments yet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.theme.textSecondary)

                                Text("Be the first to comment!")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.theme.textMuted)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(play.comments) { comment in
                                commentRow(comment: comment)
                            }
                        }
                    }
                    .padding(.top, 16)
                }

                // Comment input
                HStack(spacing: 12) {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("Y")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )

                    TextField("Add a comment...", text: $newComment)
                        .font(.system(size: 15))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Capsule())

                    Button(action: {
                        if !newComment.isEmpty {
                            onSubmit(newComment)
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(newComment.isEmpty ? themeManager.theme.textSecondary : themeManager.theme.accentGreen)
                    }
                    .disabled(newComment.isEmpty)
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

    private func commentRow(comment: PlayComment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(themeManager.theme.textSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(comment.userName.prefix(1)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("•")
                        .foregroundColor(themeManager.theme.textMuted)

                    Text(formatDate(comment.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Text(comment.text)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textPrimary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    PlaysOfWeekViewer()
        .environmentObject(ThemeManager())
}
