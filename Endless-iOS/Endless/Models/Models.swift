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

// Mock Data
struct MockData {
    static let sessions: [Session] = [
        Session(id: "1", title: "Oakmont CC", location: "Oakmont", date: "2 days ago"),
        Session(id: "2", title: "Pebble Beach", location: "Pebble Beach", date: "5 days ago"),
        Session(id: "3", title: "Del Mar", location: "Del Mar", date: "1 week ago")
    ]

    static let playsOfWeek: [PlayOfTheWeek] = [
        PlayOfTheWeek(id: "1", playerName: "Henry Kammler", playerTitle: "Class of 2025", location: "San Diego, CA"),
        PlayOfTheWeek(id: "2", playerName: "John Smith", playerTitle: "Class of 2024", location: "Los Angeles, CA")
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
}
