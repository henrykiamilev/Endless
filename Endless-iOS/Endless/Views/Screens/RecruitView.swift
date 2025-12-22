import SwiftUI
import Combine

// MARK: - Recruit Profile Manager

class RecruitProfileManager: ObservableObject {
    static let shared = RecruitProfileManager()

    @Published var profile: RecruitProfile {
        didSet { saveProfile() }
    }

    @Published var messages: [CoachMessage] {
        didSet { saveMessages() }
    }

    private init() {
        self.profile = Self.loadProfile()
        self.messages = Self.loadMessages()
    }

    func sendMessage(to coachId: String, text: String) {
        // In a real app, this would send to a server
        // For now, we just add a sent message indicator
    }

    func markAsRead(_ messageId: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isRead = true
        }
    }

    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "recruitProfile")
        }
    }

    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "coachMessages")
        }
    }

    private static func loadProfile() -> RecruitProfile {
        if let data = UserDefaults.standard.data(forKey: "recruitProfile"),
           let decoded = try? JSONDecoder().decode(RecruitProfile.self, from: data) {
            return decoded
        }
        return RecruitProfile.default
    }

    private static func loadMessages() -> [CoachMessage] {
        if let data = UserDefaults.standard.data(forKey: "coachMessages"),
           let decoded = try? JSONDecoder().decode([CoachMessage].self, from: data) {
            return decoded
        }
        return MockData.coachMessages
    }
}

// MARK: - Main Recruit View

struct RecruitView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var profileManager = RecruitProfileManager.shared
    @State private var showingEditProfile = false
    @State private var showingEditContact = false
    @State private var showingMessages = false
    @State private var selectedCoach: ProfileActivity?
    @State private var editSection: EditSection?

    enum EditSection: Identifiable {
        case academic, physical, contact, sponsorship
        var id: Self { self }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                academicProfileSection
                physicalProfileSection
                contactInfoSection
                performanceStatsSection
                profileActivitySection
                sponsorshipsSection
                filmHighlightsSection
                Spacer(minLength: 120)
            }
        }
        .background(themeManager.theme.background)
        .sheet(isPresented: $showingMessages) {
            MessagesView(profileManager: profileManager)
        }
        .sheet(item: $editSection) { section in
            EditSectionSheet(section: section, profile: $profileManager.profile)
        }
        .sheet(item: $selectedCoach) { coach in
            CoachProfileView(coach: coach)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome \(profileManager.profile.firstName.isEmpty ? "Golfer" : profileManager.profile.firstName).")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(dateFormatter.string(from: Date()))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            Button(action: { showingMessages = true }) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(profileManager.profile.firstName.isEmpty && profileManager.profile.lastName.isEmpty ? "?" : String(profileManager.profile.firstName.prefix(1)) + String(profileManager.profile.lastName.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )

                    if profileManager.messages.contains(where: { !$0.isRead }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .offset(x: 2, y: -2)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Academic Profile Section (Clickable)

    private var isAcademicProfileEmpty: Bool {
        profileManager.profile.gpa == 0 &&
        profileManager.profile.satScore == nil &&
        profileManager.profile.actScore == nil &&
        profileManager.profile.highSchool.isEmpty
    }

    private var academicProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            editableSectionHeader(icon: "graduationcap.fill", title: "Academic Profile") {
                editSection = .academic
            }

            Button(action: { editSection = .academic }) {
                if isAcademicProfileEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                        Text("No academic info yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text("Tap to add your GPA, test scores, and school")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            statBox(label: "GPA", value: profileManager.profile.gpa > 0 ? String(format: "%.2f", profileManager.profile.gpa) : "--")
                            dividerVertical
                            statBox(label: "ACT Score", value: profileManager.profile.actScore.map { "\($0)" } ?? "--")
                        }

                        dividerHorizontal

                        HStack(spacing: 0) {
                            statBox(label: "SAT Score", value: profileManager.profile.satScore.map { "\($0)" } ?? "--")
                            dividerVertical
                            statBox(label: "Graduation Class", value: "\(profileManager.profile.graduationYear)")
                        }

                        dividerHorizontal

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("High School")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(themeManager.theme.textSecondary)
                                Text(profileManager.profile.highSchool.isEmpty ? "Add high school" : profileManager.profile.highSchool)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(profileManager.profile.highSchool.isEmpty ? themeManager.theme.textMuted : themeManager.theme.textPrimary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textMuted)
                        }
                        .padding(16)
                    }
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Physical Profile Section (Clickable)

    private var isPhysicalProfileEmpty: Bool {
        profileManager.profile.age == 0 &&
        profileManager.profile.height.isEmpty &&
        profileManager.profile.weight == 0 &&
        profileManager.profile.firstName.isEmpty &&
        profileManager.profile.lastName.isEmpty
    }

    private var physicalProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            editableSectionHeader(icon: "figure.stand", title: "Physical Profile") {
                editSection = .physical
            }

            Button(action: { editSection = .physical }) {
                if isPhysicalProfileEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.stand")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                        Text("No physical info yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text("Tap to add your name, age, height, and weight")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    HStack(spacing: 0) {
                        statBox(label: "Age", value: profileManager.profile.age > 0 ? "\(profileManager.profile.age)" : "--")
                        dividerVertical
                        statBox(label: "Height", value: profileManager.profile.height.isEmpty ? "--" : profileManager.profile.height)
                        dividerVertical
                        VStack(spacing: 6) {
                            Text("Weight")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(themeManager.theme.textSecondary)
                            HStack(spacing: 4) {
                                Text(profileManager.profile.weight > 0 ? "\(profileManager.profile.weight) lbs" : "--")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(themeManager.theme.textPrimary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textMuted)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Contact Information Section (Clickable)

    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            editableSectionHeader(icon: "phone.fill", title: "Contact Information") {
                editSection = .contact
            }

            Button(action: { editSection = .contact }) {
                VStack(spacing: 0) {
                    contactRow(icon: "phone.fill", label: "Phone", value: profileManager.profile.phone.isEmpty ? "Add phone" : profileManager.profile.phone, isEmpty: profileManager.profile.phone.isEmpty)
                    dividerHorizontal
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(themeManager.theme.textSecondary)
                            Text(profileManager.profile.email.isEmpty ? "Add email" : profileManager.profile.email)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(profileManager.profile.email.isEmpty ? themeManager.theme.textMuted : themeManager.theme.textPrimary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.textMuted)
                    }
                    .padding(16)
                }
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())
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
                    statBox(label: "Scoring Avg", value: "--", highlight: true)
                    dividerVertical
                    statBox(label: "Driving Distance", value: "--", highlight: true)
                }

                dividerHorizontal

                HStack(spacing: 0) {
                    statBox(label: "GIR %", value: "--", highlight: true)
                    dividerVertical
                    statBox(label: "Putts/Round", value: "--", highlight: true)
                }
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Profile Activity Section (Clickable coaches)

    private var profileActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(icon: "person.2.fill", title: "Profile Activity")

            if MockData.profileActivities.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2")
                        .font(.system(size: 28))
                        .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                    Text("No activity yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                    Text("When coaches view your profile, they'll appear here")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(MockData.profileActivities.enumerated()), id: \.element.id) { index, activity in
                        Button(action: { selectedCoach = activity }) {
                            activityRow(activity: activity)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if index < MockData.profileActivities.count - 1 {
                            dividerHorizontal
                        }
                    }
                }
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Sponsorships Section (Clickable)

    private var isSponsorshipsEmpty: Bool {
        profileManager.profile.clubSponsor == nil && profileManager.profile.ballSponsor == nil
    }

    private var sponsorshipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            editableSectionHeader(icon: "star.fill", title: "Sponsorships") {
                editSection = .sponsorship
            }

            Button(action: { editSection = .sponsorship }) {
                if isSponsorshipsEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "star")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                        Text("No sponsorships yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text("Tap to add your club and ball sponsors")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    VStack(spacing: 0) {
                        sponsorRow(label: "Club Sponsor", value: profileManager.profile.clubSponsor ?? "Add sponsor")
                        dividerHorizontal
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ball Sponsor")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(themeManager.theme.textSecondary)
                                Text(profileManager.profile.ballSponsor ?? "Add sponsor")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(profileManager.profile.ballSponsor != nil ? themeManager.theme.accentGreen : themeManager.theme.textMuted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textMuted)
                        }
                        .padding(16)
                    }
                    .background(themeManager.theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .buttonStyle(PlainButtonStyle())
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

            if MockData.videos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "film")
                        .font(.system(size: 28))
                        .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                    Text("No videos yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                    Text("Record your swings to showcase your skills")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(MockData.videos.prefix(4)) { video in
                            filmThumbnail(video: video)
                        }
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

    private func editableSectionHeader(icon: String, title: String, action: @escaping () -> Void) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textSecondary)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            Spacer()
            Button(action: action) {
                Text("Edit")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.theme.accentGreen)
            }
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

    private func contactRow(icon: String, label: String, value: String, isEmpty: Bool = false) -> some View {
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
                    .foregroundColor(isEmpty ? themeManager.theme.textMuted : themeManager.theme.textPrimary)
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

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textMuted)
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
                    .foregroundColor(value == "Add sponsor" ? themeManager.theme.textMuted : themeManager.theme.accentGreen)
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

// MARK: - Edit Section Sheet

struct EditSectionSheet: View {
    let section: RecruitView.EditSection
    @Binding var profile: RecruitProfile
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var graduationYear = ""
    @State private var highSchool = ""
    @State private var gpa = ""
    @State private var satScore = ""
    @State private var actScore = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var clubSponsor = ""
    @State private var ballSponsor = ""

    var title: String {
        switch section {
        case .academic: return "Edit Academic Profile"
        case .physical: return "Edit Physical Profile"
        case .contact: return "Edit Contact Info"
        case .sponsorship: return "Edit Sponsorships"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    switch section {
                    case .academic:
                        formField(label: "High School", text: $highSchool)
                        formField(label: "Graduation Year", text: $graduationYear, keyboardType: .numberPad)
                        formField(label: "GPA", text: $gpa, keyboardType: .decimalPad)
                        formField(label: "SAT Score", text: $satScore, keyboardType: .numberPad)
                        formField(label: "ACT Score", text: $actScore, keyboardType: .numberPad)

                    case .physical:
                        formField(label: "First Name", text: $firstName)
                        formField(label: "Last Name", text: $lastName)
                        formField(label: "Age", text: $age, keyboardType: .numberPad)
                        formField(label: "Height (e.g., 6'1\")", text: $height)
                        formField(label: "Weight (lbs)", text: $weight, keyboardType: .numberPad)

                    case .contact:
                        formField(label: "Phone", text: $phone, keyboardType: .phonePad)
                        formField(label: "Email", text: $email, keyboardType: .emailAddress)

                    case .sponsorship:
                        formField(label: "Club Sponsor", text: $clubSponsor)
                        formField(label: "Ball Sponsor", text: $ballSponsor)
                    }
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.theme.accentGreen)
                }
            }
        }
        .onAppear { loadValues() }
    }

    private func formField(label: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.theme.textSecondary)

            TextField("", text: text)
                .font(.system(size: 16))
                .foregroundColor(themeManager.theme.textPrimary)
                .padding(14)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .keyboardType(keyboardType)
        }
    }

    private func loadValues() {
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

    private func saveChanges() {
        switch section {
        case .academic:
            profile.highSchool = highSchool
            profile.graduationYear = Int(graduationYear) ?? profile.graduationYear
            profile.gpa = Double(gpa) ?? profile.gpa
            profile.satScore = Int(satScore)
            profile.actScore = Int(actScore)

        case .physical:
            profile.firstName = firstName
            profile.lastName = lastName
            profile.age = Int(age) ?? profile.age
            profile.height = height
            profile.weight = Int(weight) ?? profile.weight

        case .contact:
            profile.phone = phone
            profile.email = email

        case .sponsorship:
            profile.clubSponsor = clubSponsor.isEmpty ? nil : clubSponsor
            profile.ballSponsor = ballSponsor.isEmpty ? nil : ballSponsor
        }
        dismiss()
    }
}

// MARK: - Coach Profile View

struct CoachProfileView: View {
    let coach: ProfileActivity
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingMessage = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Coach header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color(hex: coach.avatarColor))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(coach.coachName.prefix(1)))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        VStack(spacing: 4) {
                            Text(coach.coachName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(themeManager.theme.textPrimary)

                            Text(coach.university)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textSecondary)

                            Text("Head Golf Coach")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textMuted)
                        }
                    }
                    .padding(.top, 24)

                    // Message button
                    Button(action: { showingMessage = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope.fill")
                            Text("Send Message")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(themeManager.theme.accentGreen)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)

                    // Coach info cards
                    VStack(spacing: 16) {
                        infoCard(title: "Program Info", items: [
                            ("Division", "NCAA Division I"),
                            ("Conference", "Pac-12"),
                            ("Location", "Stanford, CA")
                        ])

                        infoCard(title: "Recent Achievements", items: [
                            ("2024", "Conference Champions"),
                            ("2023", "NCAA Regional Finals"),
                            ("2022", "3 All-Americans")
                        ])
                    }
                    .padding(.horizontal, 20)
                }
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
            .sheet(isPresented: $showingMessage) {
                ComposeMessageView(coachName: coach.coachName, university: coach.university)
            }
        }
    }

    private func infoCard(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.theme.textSecondary)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(item.0)
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Spacer()
                        Text(item.1)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
                    .padding(14)

                    if index < items.count - 1 {
                        Divider().background(themeManager.theme.border.opacity(0.5))
                    }
                }
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Compose Message View

struct ComposeMessageView: View {
    let coachName: String
    let university: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var messageText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Recipient info
                HStack(spacing: 12) {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(coachName.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("To: \(coachName)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)
                        Text(university)
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    Spacer()
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // Message input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)

                    TextEditor(text: $messageText)
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(minHeight: 150)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Spacer()

                // Send button
                Button(action: {
                    // Send message logic
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                        Text("Send Message")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(messageText.isEmpty ? themeManager.theme.textSecondary : themeManager.theme.accentGreen)
                    .clipShape(Capsule())
                }
                .disabled(messageText.isEmpty)
            }
            .padding(20)
            .background(themeManager.theme.background)
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Messages View (Updated)

struct MessagesView: View {
    @ObservedObject var profileManager: RecruitProfileManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMessage: CoachMessage?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if profileManager.messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.open")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))
                        Text("No messages yet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                        Text("When coaches reach out, their messages will appear here.")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(profileManager.messages) { message in
                                Button(action: {
                                    profileManager.markAsRead(message.id)
                                    selectedMessage = message
                                }) {
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
                MessageConversationView(message: message, profileManager: profileManager)
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

// MARK: - Message Conversation View

struct MessageConversationView: View {
    let message: CoachMessage
    @ObservedObject var profileManager: RecruitProfileManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var replyText = ""
    @State private var sentMessages: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Coach info header
                VStack(spacing: 8) {
                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text(message.avatarInitial)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text(message.coachName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(message.university)
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                // Messages
                ScrollView {
                    VStack(spacing: 12) {
                        // Coach's message (left aligned)
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.message)
                                    .font(.system(size: 15))
                                    .foregroundColor(themeManager.theme.textPrimary)
                                    .padding(14)
                                    .background(themeManager.theme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                Text(formatDate(message.timestamp))
                                    .font(.system(size: 11))
                                    .foregroundColor(themeManager.theme.textMuted)
                                    .padding(.leading, 8)
                            }
                            .frame(maxWidth: 280, alignment: .leading)
                            Spacer()
                        }

                        // Sent messages (right aligned)
                        ForEach(sentMessages, id: \.self) { sent in
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(sent)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .padding(14)
                                        .background(themeManager.theme.accentGreen)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                    Text("Just now")
                                        .font(.system(size: 11))
                                        .foregroundColor(themeManager.theme.textMuted)
                                        .padding(.trailing, 8)
                                }
                                .frame(maxWidth: 280, alignment: .trailing)
                            }
                        }
                    }
                    .padding(16)
                }

                // Reply input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $replyText)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
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

    private func sendMessage() {
        guard !replyText.isEmpty else { return }
        withAnimation {
            sentMessages.append(replyText)
        }
        replyText = ""
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    RecruitView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
