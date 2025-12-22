import Foundation

struct Session: Identifiable {
    let id: String
    let title: String
    let location: String
    let date: String
    var thumbnail: String?
}

struct PlayOfTheWeek: Identifiable {
    let id: String
    let playerName: String
    let playerTitle: String
    let location: String
    var thumbnail: String?
    var avatar: String?
    var videoURL: String?
    var likes: Int
    var comments: [PlayComment]
}

struct PlayComment: Identifiable, Codable {
    let id: String
    let userName: String
    let text: String
    let timestamp: Date
}

struct Video: Identifiable {
    let id: String
    let title: String
    let date: String
    let duration: String
    var thumbnail: String?
    var videoFileName: String?  // The actual video file name (e.g., "swing-1.mp4")
}

struct RoundHistory: Identifiable {
    let id: String
    let course: String
    let date: String
    let score: Int
}

struct SwingVideo: Identifiable {
    let id: String
    let title: String
    let type: String
    let date: String
    let description: String
    var thumbnail: String?
}

struct Player: Identifiable {
    let id: String
    let name: String
    let handicap: Double
    let isCaptain: Bool
}

// MARK: - Recruit Profile Models

struct RecruitProfile: Codable {
    var firstName: String
    var lastName: String
    var age: Int
    var height: String  // e.g., "6'1\""
    var weight: Int     // in lbs
    var graduationYear: Int
    var highSchool: String
    var gpa: Double
    var satScore: Int?
    var actScore: Int?
    var phone: String
    var email: String
    var clubSponsor: String?
    var ballSponsor: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    static let `default` = RecruitProfile(
        firstName: "",
        lastName: "",
        age: 0,
        height: "",
        weight: 0,
        graduationYear: 2025,
        highSchool: "",
        gpa: 0.0,
        satScore: nil,
        actScore: nil,
        phone: "",
        email: "",
        clubSponsor: nil,
        ballSponsor: nil
    )
}

struct CoachMessage: Identifiable, Codable {
    let id: String
    let coachName: String
    let university: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    var avatarInitial: String {
        String(coachName.prefix(1))
    }
}

struct ProfileActivity: Identifiable {
    let id: String
    let coachName: String
    let university: String
    let message: String
    let timestamp: Date
    var avatarColor: String  // Hex color for avatar
}

struct Drill: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: String
    let category: DrillCategory
    var isCompleted: Bool

    enum DrillCategory: String {
        case putting = "Putting"
        case driving = "Driving"
        case shortGame = "Short Game"
        case irons = "Irons"
        case mental = "Mental"
    }
}

// Mock Data - Empty for new users
struct MockData {
    static let sessions: [Session] = []

    static let playsOfWeek: [PlayOfTheWeek] = []

    static let videos: [Video] = []

    static let roundHistory: [RoundHistory] = []

    static let swingVideos: [SwingVideo] = []

    static let team1Players: [Player] = []

    static let profileActivities: [ProfileActivity] = []

    static let coachMessages: [CoachMessage] = []

    static let todaysDrills: [Drill] = []
}
