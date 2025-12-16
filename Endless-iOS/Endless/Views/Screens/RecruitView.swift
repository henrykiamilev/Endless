import SwiftUI

// MARK: - Recruit Profile Manager

class RecruitProfileManager: ObservableObject {
    static let shared = RecruitProfileManager()

    @Published var profile: RecruitProfile {
        didSet { saveProfile() }
    }

    private init() {
        self.profile = Self.loadProfile()
    }

    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "recruitProfile")
        }
    }

    private static func loadProfile() -> RecruitProfile {
        if let data = UserDefaults.standard.data(forKey: "recruitProfile"),
           let decoded = try? JSONDecoder().decode(RecruitProfile.self, from: data) {
            return decoded
        }
        return RecruitProfile.default
    }
}

// MARK: - Main Recruit View

struct RecruitView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var profileManager = RecruitProfileManager.shared
    @State private var showingEditProfile = false
    @State private var showingMessages = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                headerSection

                // Academic Profile
                academicProfileSection

                // Physical Profile
                physicalProfileSection

                // Contact Information
                contactInfoSection

                // Performance Stats
                performanceStatsSection

                // Profile Activity
                profileActivitySection

                // Sponsorships
                sponsorshipsSection

                // Film Highlights
                filmHighlightsSection

                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
        .sheet(isPresented: $showingEditProfile) {
            EditRecruitProfileSheet(profile: $profileManager.profile)
        }
        .sheet(isPresented: $showingMessages) {
            MessagesView()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome \(profileManager.profile.firstName).")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(dateFormatter.string(from: Date()))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            // Profile avatar / Messages button
            Button(action: { showingMessages = true }) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(profileManager.profile.firstName.prefix(1)) + String(profileManager.profile.lastName.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )

                    // Unread indicator
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .offset(x: 2, y: -2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Academic Profile Section

    private var academicProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "graduationcap.fill", title: "Academic Profile")

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    statBox(label: "GPA", value: String(format: "%.2f", profileManager.profile.gpa))
                    dividerVertical
                    statBox(label: "ACT Score", value: profileManager.profile.actScore.map { "\($0)" } ?? "—")
                }

                dividerHorizontal

                HStack(spacing: 0) {
                    statBox(label: "SAT Score", value: profileManager.profile.satScore.map { "\($0)" } ?? "—")
                    dividerVertical
                    statBox(label: "Graduation Class", value: "\(profileManager.profile.graduationYear)")
                }

                dividerHorizontal

                // High School row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("High School")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text(profileManager.profile.highSchool)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
                    Spacer()
                }
                .padding(16)
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Physical Profile Section

    private var physicalProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "figure.stand", title: "Physical Profile")

            HStack(spacing: 0) {
                statBox(label: "Age", value: "\(profileManager.profile.age)")
                dividerVertical
                statBox(label: "Height", value: profileManager.profile.height)
                dividerVertical
                statBox(label: "Weight", value: "\(profileManager.profile.weight) lbs")
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Contact Information Section

    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "phone.fill", title: "Contact Information")

            VStack(spacing: 0) {
                contactRow(icon: "phone.fill", label: "Phone", value: profileManager.profile.phone)
                dividerHorizontal
                contactRow(icon: "envelope.fill", label: "Email", value: profileManager.profile.email)
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Performance Stats Section

    private var performanceStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "chart.bar.fill", title: "Performance Stats")

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    statBox(label: "Scoring Avg", value: "71.3", highlight: true)
                    dividerVertical
                    statBox(label: "Driving Distance", value: "288 yds", highlight: true)
                }

                dividerHorizontal

                HStack(spacing: 0) {
                    statBox(label: "GIR %", value: "63%", highlight: true)
                    dividerVertical
                    statBox(label: "Putts/Round", value: "28.4", highlight: true)
                }
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Profile Activity Section

    private var profileActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "person.2.fill", title: "Profile Activity")

            VStack(spacing: 0) {
                ForEach(Array(MockData.profileActivities.enumerated()), id: \.element.id) { index, activity in
                    activityRow(activity: activity)
                    if index < MockData.profileActivities.count - 1 {
                        dividerHorizontal
                    }
                }
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Sponsorships Section

    private var sponsorshipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "star.fill", title: "Sponsorships")

            VStack(spacing: 0) {
                if let clubSponsor = profileManager.profile.clubSponsor {
                    sponsorRow(label: "Club Sponsor", value: clubSponsor)
                    if profileManager.profile.ballSponsor != nil {
                        dividerHorizontal
                    }
                }
                if let ballSponsor = profileManager.profile.ballSponsor {
                    sponsorRow(label: "Ball Sponsor", value: ballSponsor)
                }
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Film Highlights Section

    private var filmHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionHeader(icon: "film.fill", title: "Film Highlights")
                Spacer()
                Button(action: { navigationManager.navigateToVideo() }) {
                    Text("View All")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MockData.videos.prefix(4)) { video in
                        filmThumbnail(video: video)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Views

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.theme.textSecondary)
        }
    }

    private func statBox(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(highlight ? themeManager.theme.accentGreen : themeManager.theme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var dividerVertical: some View {
        Rectangle()
            .fill(themeManager.theme.border.opacity(0.5))
            .frame(width: 1)
    }

    private var dividerHorizontal: some View {
        Rectangle()
            .fill(themeManager.theme.border.opacity(0.5))
            .frame(height: 1)
    }

    private func contactRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)
            }

            Spacer()
        }
        .padding(16)
    }

    private func activityRow(activity: ProfileActivity) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: activity.avatarColor))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(activity.coachName.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(activity.coachName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    if !activity.message.isEmpty {
                        Text("•")
                            .foregroundColor(themeManager.theme.textMuted)
                        Text(activity.message)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.theme.accentGreen)
                    }
                }
                Text(activity.university)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()
        }
        .padding(16)
    }

    private func sponsorRow(label: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.accentGreen)
            }
            Spacer()
        }
        .padding(16)
    }

    private func filmThumbnail(video: Video) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(themeManager.theme.cardBackground)
                    .frame(width: 140, height: 100)

                Image(systemName: "play.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
            }

            Text(video.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
                .lineLimit(1)

            Text(video.date)
                .font(.system(size: 10))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .frame(width: 140)
    }
}

// MARK: - Edit Profile Sheet

struct EditRecruitProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var profile: RecruitProfile

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var graduationYear: String = ""
    @State private var highSchool: String = ""
    @State private var gpa: String = ""
    @State private var satScore: String = ""
    @State private var actScore: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var clubSponsor: String = ""
    @State private var ballSponsor: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Personal Info
                    formSection(title: "Personal Information") {
                        formField(label: "First Name", text: $firstName)
                        formField(label: "Last Name", text: $lastName)
                        formField(label: "Age", text: $age, keyboardType: .numberPad)
                        formField(label: "Height (e.g., 6'1\")", text: $height)
                        formField(label: "Weight (lbs)", text: $weight, keyboardType: .numberPad)
                    }

                    // Academic Info
                    formSection(title: "Academic Information") {
                        formField(label: "High School", text: $highSchool)
                        formField(label: "Graduation Year", text: $graduationYear, keyboardType: .numberPad)
                        formField(label: "GPA", text: $gpa, keyboardType: .decimalPad)
                        formField(label: "SAT Score (optional)", text: $satScore, keyboardType: .numberPad)
                        formField(label: "ACT Score (optional)", text: $actScore, keyboardType: .numberPad)
                    }

                    // Contact Info
                    formSection(title: "Contact Information") {
                        formField(label: "Phone", text: $phone, keyboardType: .phonePad)
                        formField(label: "Email", text: $email, keyboardType: .emailAddress)
                    }

                    // Sponsorships
                    formSection(title: "Sponsorships") {
                        formField(label: "Club Sponsor (optional)", text: $clubSponsor)
                        formField(label: "Ball Sponsor (optional)", text: $ballSponsor)
                    }
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveProfile() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }
            }
        }
        .onAppear { loadCurrentValues() }
    }

    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.theme.textSecondary)

            VStack(spacing: 12) {
                content()
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func formField(label: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)

            TextField("", text: text)
                .font(.system(size: 16))
                .foregroundColor(themeManager.theme.textPrimary)
                .padding(12)
                .background(themeManager.theme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .keyboardType(keyboardType)
        }
    }

    private func loadCurrentValues() {
        firstName = profile.firstName
        lastName = profile.lastName
        age = "\(profile.age)"
        height = profile.height
        weight = "\(profile.weight)"
        graduationYear = "\(profile.graduationYear)"
        highSchool = profile.highSchool
        gpa = String(format: "%.2f", profile.gpa)
        satScore = profile.satScore.map { "\($0)" } ?? ""
        actScore = profile.actScore.map { "\($0)" } ?? ""
        phone = profile.phone
        email = profile.email
        clubSponsor = profile.clubSponsor ?? ""
        ballSponsor = profile.ballSponsor ?? ""
    }

    private func saveProfile() {
        profile.firstName = firstName
        profile.lastName = lastName
        profile.age = Int(age) ?? profile.age
        profile.height = height
        profile.weight = Int(weight) ?? profile.weight
        profile.graduationYear = Int(graduationYear) ?? profile.graduationYear
        profile.highSchool = highSchool
        profile.gpa = Double(gpa) ?? profile.gpa
        profile.satScore = Int(satScore)
        profile.actScore = Int(actScore)
        profile.phone = phone
        profile.email = email
        profile.clubSponsor = clubSponsor.isEmpty ? nil : clubSponsor
        profile.ballSponsor = ballSponsor.isEmpty ? nil : ballSponsor
        dismiss()
    }
}

// MARK: - Messages View

struct MessagesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMessage: CoachMessage?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(MockData.coachMessages) { message in
                            Button(action: { selectedMessage = message }) {
                                messageRow(message: message)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()
                                .background(themeManager.theme.border.opacity(0.5))
                                .padding(.leading, 72)
                        }
                    }
                }
            }
            .background(themeManager.theme.background)
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
            .sheet(item: $selectedMessage) { message in
                MessageDetailView(message: message)
            }
        }
    }

    private func messageRow(message: CoachMessage) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(message.isRead ? themeManager.theme.textSecondary : themeManager.theme.accentGreen)
                    .frame(width: 48, height: 48)

                Text(message.avatarInitial)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.coachName)
                        .font(.system(size: 15, weight: message.isRead ? .medium : .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Spacer()

                    Text(formatDate(message.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Text(message.university)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)

                Text(message.message)
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .lineLimit(2)
            }

            if !message.isRead {
                Circle()
                    .fill(themeManager.theme.accentGreen)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(16)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Message Detail View

struct MessageDetailView: View {
    let message: CoachMessage
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var replyText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Coach info header
                VStack(spacing: 12) {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Text(message.avatarInitial)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text(message.coachName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(message.university)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                // Message content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(message.message)
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(20)
                }

                // Reply input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $replyText)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    Button(action: { /* Send reply */ }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(replyText.isEmpty ? themeManager.theme.textSecondary : themeManager.theme.accentGreen)
                    }
                    .disabled(replyText.isEmpty)
                }
                .padding(16)
                .background(themeManager.theme.background)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
    }
}

#Preview {
    RecruitView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
