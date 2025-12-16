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
        firstName: "William",
        lastName: "Anderson",
        age: 18,
        height: "6'1\"",
        weight: 175,
        graduationYear: 2025,
        highSchool: "Torrey Pines High School",
        gpa: 3.85,
        satScore: 1480,
        actScore: 32,
        phone: "(619) 555-0123",
        email: "william.anderson@email.com",
        clubSponsor: "TaylorMade",
        ballSponsor: "Titleist"
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

// Mock Data
struct MockData {
    static let sessions: [Session] = [
        Session(id: "1", title: "Oakmont CC", location: "Oakmont", date: "2 days ago"),
        Session(id: "2", title: "Pebble Beach", location: "Pebble Beach", date: "5 days ago"),
        Session(id: "3", title: "Del Mar", location: "Del Mar", date: "1 week ago")
    ]

    static let playsOfWeek: [PlayOfTheWeek] = [
        PlayOfTheWeek(id: "1", playerName: "Henry Kammler", playerTitle: "Class of 2025", location: "San Diego, CA", likes: 234, comments: []),
        PlayOfTheWeek(id: "2", playerName: "John Smith", playerTitle: "Class of 2024", location: "Los Angeles, CA", likes: 189, comments: []),
        PlayOfTheWeek(id: "3", playerName: "Sarah Johnson", playerTitle: "Class of 2025", location: "Scottsdale, AZ", likes: 312, comments: []),
        PlayOfTheWeek(id: "4", playerName: "Mike Chen", playerTitle: "Class of 2026", location: "Austin, TX", likes: 156, comments: []),
        PlayOfTheWeek(id: "5", playerName: "Emma Davis", playerTitle: "Class of 2024", location: "Miami, FL", likes: 278, comments: []),
        PlayOfTheWeek(id: "6", playerName: "Tyler Brooks", playerTitle: "Class of 2025", location: "Denver, CO", likes: 201, comments: [])
    ]

    static let videos: [Video] = [
        Video(id: "1", title: "Oakmont CC", date: "10/15/25", duration: "2:34"),
        Video(id: "2", title: "Pebble Beach", date: "10/10/25", duration: "3:12"),
        Video(id: "3", title: "Del Mar", date: "10/05/25", duration: "1:45"),
        Video(id: "4", title: "Torrey Pines", date: "10/01/25", duration: "2:58")
    ]

    static let roundHistory: [RoundHistory] = [
        RoundHistory(id: "1", course: "Oakmont CC", date: "10/15/25", score: 72),
        RoundHistory(id: "2", course: "Pebble Beach", date: "10/10/25", score: 72),
        RoundHistory(id: "3", course: "Del Mar", date: "10/05/25", score: 74),
        RoundHistory(id: "4", course: "Torrey Pines", date: "10/01/25", score: 71)
    ]

    static let swingVideos: [SwingVideo] = [
        SwingVideo(id: "1", title: "Down the Line - Current Swing", type: "DTL", date: "10/12/25", description: "Working on staying centered over the ball"),
        SwingVideo(id: "2", title: "Face On View", type: "Face On", date: "10/10/25", description: "Focusing on reducing head sway")
    ]

    static let team1Players: [Player] = [
        Player(id: "1", name: "Craig Roberts", handicap: 19.2, isCaptain: true),
        Player(id: "2", name: "Daniel Linch", handicap: 18.2, isCaptain: false)
    ]

    static let profileActivities: [ProfileActivity] = [
        ProfileActivity(id: "1", coachName: "Mike Thompson", university: "Stanford University", message: "Welcome", timestamp: Date(), avatarColor: "22C55E"),
        ProfileActivity(id: "2", coachName: "Sarah Johnson", university: "UCLA", message: "", timestamp: Date().addingTimeInterval(-86400), avatarColor: "3B82F6"),
        ProfileActivity(id: "3", coachName: "David Martinez", university: "USC", message: "Great Job", timestamp: Date().addingTimeInterval(-172800), avatarColor: "8B5CF6")
    ]

    static let coachMessages: [CoachMessage] = [
        CoachMessage(id: "1", coachName: "Mike Thompson", university: "Stanford University", message: "Hi William, I've been watching your progress and I'm impressed with your swing mechanics. Would love to chat about our program.", timestamp: Date(), isRead: false),
        CoachMessage(id: "2", coachName: "Sarah Johnson", university: "UCLA", message: "Great round at Torrey Pines! We're looking for players like you.", timestamp: Date().addingTimeInterval(-86400), isRead: true),
        CoachMessage(id: "3", coachName: "David Martinez", university: "USC", message: "Your GIR stats are excellent. Let's schedule a call to discuss opportunities.", timestamp: Date().addingTimeInterval(-172800), isRead: true)
    ]

    static let todaysDrills: [Drill] = [
        Drill(id: "1", title: "Lag Putting Drill", description: "Practice distance control from 30+ feet", duration: "15 min", category: .putting, isCompleted: false),
        Drill(id: "2", title: "Tempo Training", description: "Work on consistent swing tempo with metronome", duration: "20 min", category: .driving, isCompleted: false),
        Drill(id: "3", title: "Chip & Run", description: "Practice low running chips around the green", duration: "15 min", category: .shortGame, isCompleted: false),
        Drill(id: "4", title: "7-Iron Accuracy", description: "Hit to specific targets at varying distances", duration: "20 min", category: .irons, isCompleted: false),
        Drill(id: "5", title: "Pre-Shot Routine", description: "Establish consistent pre-shot routine", duration: "10 min", category: .mental, isCompleted: false)
    ]
}
