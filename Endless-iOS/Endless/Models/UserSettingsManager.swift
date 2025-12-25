import Foundation

/// Manages persistence of all user settings and preferences
class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()

    // MARK: - Storage Keys

    private enum Keys {
        // Golf Settings
        static let handicap = "userSettings_handicap"
        static let homeCourse = "userSettings_homeCourse"
        static let preferredTees = "userSettings_preferredTees"
        static let measurementUnit = "userSettings_measurementUnit"
        static let dominantHand = "userSettings_dominantHand"

        // Privacy Settings
        static let twoFactorEnabled = "userSettings_twoFactorEnabled"
        static let faceIDEnabled = "userSettings_faceIDEnabled"
        static let privateProfile = "userSettings_privateProfile"

        // Notification Settings
        static let pushEnabled = "userSettings_pushEnabled"
        static let emailEnabled = "userSettings_emailEnabled"
        static let smsEnabled = "userSettings_smsEnabled"
        static let coachMessages = "userSettings_coachMessages"
        static let sessionReminders = "userSettings_sessionReminders"
        static let weeklyDigest = "userSettings_weeklyDigest"
        static let newFeatures = "userSettings_newFeatures"
    }

    // MARK: - Golf Settings

    @Published var handicap: String {
        didSet { UserDefaults.standard.set(handicap, forKey: Keys.handicap) }
    }

    @Published var homeCourse: String {
        didSet { UserDefaults.standard.set(homeCourse, forKey: Keys.homeCourse) }
    }

    @Published var preferredTees: String {
        didSet { UserDefaults.standard.set(preferredTees, forKey: Keys.preferredTees) }
    }

    @Published var measurementUnit: String {
        didSet { UserDefaults.standard.set(measurementUnit, forKey: Keys.measurementUnit) }
    }

    @Published var dominantHand: String {
        didSet { UserDefaults.standard.set(dominantHand, forKey: Keys.dominantHand) }
    }

    // MARK: - Privacy Settings

    @Published var twoFactorEnabled: Bool {
        didSet { UserDefaults.standard.set(twoFactorEnabled, forKey: Keys.twoFactorEnabled) }
    }

    @Published var faceIDEnabled: Bool {
        didSet { UserDefaults.standard.set(faceIDEnabled, forKey: Keys.faceIDEnabled) }
    }

    @Published var privateProfile: Bool {
        didSet { UserDefaults.standard.set(privateProfile, forKey: Keys.privateProfile) }
    }

    // MARK: - Notification Settings

    @Published var pushEnabled: Bool {
        didSet { UserDefaults.standard.set(pushEnabled, forKey: Keys.pushEnabled) }
    }

    @Published var emailEnabled: Bool {
        didSet { UserDefaults.standard.set(emailEnabled, forKey: Keys.emailEnabled) }
    }

    @Published var smsEnabled: Bool {
        didSet { UserDefaults.standard.set(smsEnabled, forKey: Keys.smsEnabled) }
    }

    @Published var coachMessages: Bool {
        didSet { UserDefaults.standard.set(coachMessages, forKey: Keys.coachMessages) }
    }

    @Published var sessionReminders: Bool {
        didSet { UserDefaults.standard.set(sessionReminders, forKey: Keys.sessionReminders) }
    }

    @Published var weeklyDigest: Bool {
        didSet { UserDefaults.standard.set(weeklyDigest, forKey: Keys.weeklyDigest) }
    }

    @Published var newFeatures: Bool {
        didSet { UserDefaults.standard.set(newFeatures, forKey: Keys.newFeatures) }
    }

    // MARK: - Initialization

    private init() {
        let defaults = UserDefaults.standard

        // Load Golf Settings
        self.handicap = defaults.string(forKey: Keys.handicap) ?? "0.0"
        self.homeCourse = defaults.string(forKey: Keys.homeCourse) ?? ""
        self.preferredTees = defaults.string(forKey: Keys.preferredTees) ?? "Championship"
        self.measurementUnit = defaults.string(forKey: Keys.measurementUnit) ?? "Yards"
        self.dominantHand = defaults.string(forKey: Keys.dominantHand) ?? "Right"

        // Load Privacy Settings
        self.twoFactorEnabled = defaults.bool(forKey: Keys.twoFactorEnabled)
        self.faceIDEnabled = defaults.object(forKey: Keys.faceIDEnabled) as? Bool ?? true
        self.privateProfile = defaults.bool(forKey: Keys.privateProfile)

        // Load Notification Settings
        self.pushEnabled = defaults.object(forKey: Keys.pushEnabled) as? Bool ?? true
        self.emailEnabled = defaults.object(forKey: Keys.emailEnabled) as? Bool ?? true
        self.smsEnabled = defaults.bool(forKey: Keys.smsEnabled)
        self.coachMessages = defaults.object(forKey: Keys.coachMessages) as? Bool ?? true
        self.sessionReminders = defaults.object(forKey: Keys.sessionReminders) as? Bool ?? true
        self.weeklyDigest = defaults.object(forKey: Keys.weeklyDigest) as? Bool ?? true
        self.newFeatures = defaults.bool(forKey: Keys.newFeatures)
    }

    // MARK: - Clear All Settings (for logout)

    func clearAllSettings() {
        let defaults = UserDefaults.standard

        // Clear Golf Settings
        defaults.removeObject(forKey: Keys.handicap)
        defaults.removeObject(forKey: Keys.homeCourse)
        defaults.removeObject(forKey: Keys.preferredTees)
        defaults.removeObject(forKey: Keys.measurementUnit)
        defaults.removeObject(forKey: Keys.dominantHand)

        // Clear Privacy Settings
        defaults.removeObject(forKey: Keys.twoFactorEnabled)
        defaults.removeObject(forKey: Keys.faceIDEnabled)
        defaults.removeObject(forKey: Keys.privateProfile)

        // Clear Notification Settings
        defaults.removeObject(forKey: Keys.pushEnabled)
        defaults.removeObject(forKey: Keys.emailEnabled)
        defaults.removeObject(forKey: Keys.smsEnabled)
        defaults.removeObject(forKey: Keys.coachMessages)
        defaults.removeObject(forKey: Keys.sessionReminders)
        defaults.removeObject(forKey: Keys.weeklyDigest)
        defaults.removeObject(forKey: Keys.newFeatures)

        // Reset to defaults
        handicap = "0.0"
        homeCourse = ""
        preferredTees = "Championship"
        measurementUnit = "Yards"
        dominantHand = "Right"

        twoFactorEnabled = false
        faceIDEnabled = true
        privateProfile = false

        pushEnabled = true
        emailEnabled = true
        smsEnabled = false
        coachMessages = true
        sessionReminders = true
        weeklyDigest = true
        newFeatures = false
    }
}
