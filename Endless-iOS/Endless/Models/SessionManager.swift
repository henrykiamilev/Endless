import Foundation

/// Manages persistence of upcoming session data
class SessionManager: ObservableObject {
    static let shared = SessionManager()

    private static let sessionDateKey = "upcomingSessionDate"
    private static let sessionTimeKey = "upcomingSessionTime"
    private static let sessionLocationKey = "upcomingSessionLocation"

    @Published var sessionDate: Date {
        didSet { saveSessionDate() }
    }

    @Published var sessionTime: Date {
        didSet { saveSessionTime() }
    }

    @Published var sessionLocation: String {
        didSet { saveSessionLocation() }
    }

    private init() {
        // Load saved session date or default to today
        if let savedDate = UserDefaults.standard.object(forKey: Self.sessionDateKey) as? Date {
            self.sessionDate = savedDate
        } else {
            self.sessionDate = Date()
        }

        // Load saved session time or default to current time
        if let savedTime = UserDefaults.standard.object(forKey: Self.sessionTimeKey) as? Date {
            self.sessionTime = savedTime
        } else {
            self.sessionTime = Date()
        }

        // Load saved location or default to empty
        self.sessionLocation = UserDefaults.standard.string(forKey: Self.sessionLocationKey) ?? ""
    }

    private func saveSessionDate() {
        UserDefaults.standard.set(sessionDate, forKey: Self.sessionDateKey)
    }

    private func saveSessionTime() {
        UserDefaults.standard.set(sessionTime, forKey: Self.sessionTimeKey)
    }

    private func saveSessionLocation() {
        UserDefaults.standard.set(sessionLocation, forKey: Self.sessionLocationKey)
    }

    /// Clear all session data (useful for logout)
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: Self.sessionDateKey)
        UserDefaults.standard.removeObject(forKey: Self.sessionTimeKey)
        UserDefaults.standard.removeObject(forKey: Self.sessionLocationKey)

        sessionDate = Date()
        sessionTime = Date()
        sessionLocation = ""
    }
}
