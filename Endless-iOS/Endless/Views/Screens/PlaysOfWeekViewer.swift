import SwiftUI

struct PlaysOfWeekViewer: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentIndex: Int
    @State private var showComments = false
    @State private var newComment = ""
    @State private var plays: [PlayOfTheWeek]
    @State private var likedPlays: Set<String> = []

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
                            isLiked: likedPlays.contains(play.id),
                            onLike: { toggleLike(at: index) },
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

                        VStack(spacing: 2) {
                            Text("Plays of the Week")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(currentIndex + 1) of \(plays.count)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }

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

    private func toggleLike(at index: Int) {
        let playId = plays[index].id
        if likedPlays.contains(playId) {
            likedPlays.remove(playId)
            plays[index].likes -= 1
        } else {
            likedPlays.insert(playId)
            plays[index].likes += 1
        }
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
    let isLiked: Bool
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void

    @State private var showHeartAnimation = false
    @State private var isBookmarked = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video placeholder background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "1A3A2A"),
                        Color(hex: "0D1F15"),
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
                            .fill(Color(hex: "22C55E").opacity(0.15))
                            .frame(width: geometry.size.width * 1.5, height: 300)
                            .offset(y: 100)

                        // Flag in distance
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 2, height: 60)
                            Triangle()
                                .fill(Color.red.opacity(0.5))
                                .frame(width: 20, height: 15)
                                .offset(x: 10, y: -60)
                        }
                        .offset(y: -80)

                        // Golf ball
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 20, height: 20)
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                            .offset(y: -30)
                    }
                }

                // Play icon overlay
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.3))
                        .frame(width: 80, height: 80)

                    Image(systemName: "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 2)
                }

                // Heart animation on double tap
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.red)
                        .scaleEffect(showHeartAnimation ? 1.0 : 0.5)
                        .opacity(showHeartAnimation ? 1.0 : 0)
                }

                // Content overlay
                VStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 16) {
                        // Left side - Player info
                        VStack(alignment: .leading, spacing: 10) {
                            // Player name with avatar
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "22C55E"))
                                        .frame(width: 48, height: 48)

                                    Text(String(play.playerName.prefix(1)))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(play.playerName)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.white)

                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "22C55E"))
                                    }

                                    Text(play.playerTitle)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                }

                                Spacer()

                                // Follow button
                                Button(action: {}) {
                                    Text("Follow")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "22C55E"))
                                        .clipShape(Capsule())
                                }
                            }

                            // Location
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 14))
                                Text(play.location)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.8))

                            // Description
                            Text("Amazing approach shot! Watch this incredible play land within feet of the pin. 🏌️‍♂️⛳️")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                                .padding(.top, 2)

                            // Tags
                            HStack(spacing: 8) {
                                ForEach(["#golf", "#approach", "#skillshot"], id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "22C55E"))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Right side - Action buttons
                        VStack(spacing: 24) {
                            // Like button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    onLike()
                                }
                            }) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(isLiked ? .red : .white.opacity(0.3))
                                            .scaleEffect(isLiked ? 1.0 : 0.9)

                                        Image(systemName: "heart")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }

                                    Text("\(play.likes)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Comment button
                            Button(action: onComment) {
                                VStack(spacing: 4) {
                                    Image(systemName: "bubble.right.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)

                                    Text("\(play.comments.count)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Share button
                            Button(action: onShare) {
                                VStack(spacing: 4) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)

                                    Text("Share")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Bookmark button
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    isBookmarked.toggle()
                                }
                            }) {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 26))
                                    .foregroundColor(isBookmarked ? Color(hex: "22C55E") : .white)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                // Double tap to like
                if !isLiked {
                    onLike()
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showHeartAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        showHeartAnimation = false
                    }
                }
            }
        }
    }
}

// Helper shape for flag
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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
