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
    var otherSponsor: String?

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
        ballSponsor: nil,
        otherSponsor: nil
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

    /// Pool of all available drills to randomly select from each day
    static let allDrills: [Drill] = [
        // Putting drills
        Drill(id: "drill-1", title: "Gate Putting", description: "Set up two tees just wider than your putter head about 6 inches in front of the ball. Practice putting through the gate to improve your stroke path and face alignment.", duration: "10 min", category: .putting, isCompleted: false),
        Drill(id: "drill-2", title: "Clock Drill", description: "Place 4 balls around the hole at 3-foot intervals like a clock. Make all 4 putts, then move back to 6 feet. Builds confidence and consistency from short range.", duration: "15 min", category: .putting, isCompleted: false),
        Drill(id: "drill-3", title: "Lag Putting Challenge", description: "From 30+ feet, try to get each putt within a 3-foot circle around the hole. Focus on distance control rather than making the putt.", duration: "10 min", category: .putting, isCompleted: false),
        Drill(id: "drill-4", title: "One-Handed Putting", description: "Practice putting with just your trail hand to develop feel and prevent the wrists from breaking down through impact.", duration: "8 min", category: .putting, isCompleted: false),

        // Driving drills
        Drill(id: "drill-5", title: "Alignment Stick Drill", description: "Place an alignment stick on the ground pointing at your target. Practice hitting drives while ensuring your feet, hips, and shoulders are parallel to the stick.", duration: "15 min", category: .driving, isCompleted: false),
        Drill(id: "drill-6", title: "Tee Height Variation", description: "Hit 10 drives with the ball teed high, 10 with it teed low. Notice how tee height affects launch angle and spin. Find your optimal tee height.", duration: "12 min", category: .driving, isCompleted: false),
        Drill(id: "drill-7", title: "Slow Motion Swings", description: "Make 10 slow-motion driver swings focusing on positions at address, top of backswing, impact, and finish. Build muscle memory for proper sequencing.", duration: "10 min", category: .driving, isCompleted: false),
        Drill(id: "drill-8", title: "Target Focus", description: "Pick a specific target in the fairway and hit 10 drives trying to land within 20 yards of it. Track your accuracy percentage.", duration: "15 min", category: .driving, isCompleted: false),

        // Short game drills
        Drill(id: "drill-9", title: "Up and Down Challenge", description: "Drop 5 balls around the green in different lies. Try to get up and down from each spot. Track your success rate and work on weak areas.", duration: "20 min", category: .shortGame, isCompleted: false),
        Drill(id: "drill-10", title: "Landing Spot Practice", description: "Place a towel on the green as your landing spot. Practice chips that land on the towel and release to the hole. Develops trajectory and spin control.", duration: "15 min", category: .shortGame, isCompleted: false),
        Drill(id: "drill-11", title: "Bunker Ladder", description: "Draw lines in the bunker at 5, 10, and 15 feet. Practice landing shots between each set of lines to develop distance control from sand.", duration: "15 min", category: .shortGame, isCompleted: false),
        Drill(id: "drill-12", title: "Flop Shot Practice", description: "Set up with an open clubface and practice high, soft flop shots that land softly. Start with easier lies before progressing to tight ones.", duration: "12 min", category: .shortGame, isCompleted: false),

        // Iron drills
        Drill(id: "drill-13", title: "9-to-3 Drill", description: "Make half swings where your arms go from 9 o'clock to 3 o'clock. Focus on solid contact and controlling trajectory with abbreviated swings.", duration: "12 min", category: .irons, isCompleted: false),
        Drill(id: "drill-14", title: "Divot Pattern Check", description: "Hit 10 iron shots and examine your divot pattern. Divots should start at or slightly after the ball position and point at your target.", duration: "10 min", category: .irons, isCompleted: false),
        Drill(id: "drill-15", title: "Distance Ladder", description: "Hit your 7-iron at 75%, 85%, and 100% power. Note the distance differences. This builds versatility and helps with in-between yardages.", duration: "15 min", category: .irons, isCompleted: false),
        Drill(id: "drill-16", title: "Punch Shot Practice", description: "Practice keeping the ball low by finishing with hands below shoulder height. Essential for windy conditions and trouble shots.", duration: "10 min", category: .irons, isCompleted: false),

        // Mental drills
        Drill(id: "drill-17", title: "Pre-Shot Routine", description: "Develop and practice a consistent pre-shot routine. Include visualization, practice swing, and setup. Time yourself to ensure consistency.", duration: "10 min", category: .mental, isCompleted: false),
        Drill(id: "drill-18", title: "Breathing Exercise", description: "Practice 4-7-8 breathing: inhale for 4 seconds, hold for 7, exhale for 8. Use this between shots to stay calm and focused under pressure.", duration: "5 min", category: .mental, isCompleted: false),
        Drill(id: "drill-19", title: "Visualization Session", description: "Close your eyes and visualize playing your home course hole by hole. See each shot, feel the swing, and imagine positive outcomes.", duration: "10 min", category: .mental, isCompleted: false),
        Drill(id: "drill-20", title: "Process Goal Setting", description: "Write down 3 process goals for your next round (e.g., complete pre-shot routine every time). Focus on what you can control, not score.", duration: "8 min", category: .mental, isCompleted: false)
    ]
}
