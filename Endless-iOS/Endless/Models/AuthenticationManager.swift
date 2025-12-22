import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth

// MARK: - User Model

struct AppUser: Codable {
    let uid: String
    var email: String
    var firstName: String
    var lastName: String
    var username: String
    var createdAt: Date

    var displayName: String {
        if !firstName.isEmpty {
            return firstName
        }
        return username
    }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        if first.isEmpty && last.isEmpty {
            return String(username.prefix(1)).uppercased()
        }
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Authentication State

enum AuthenticationState {
    case undefined
    case authenticated
    case unauthenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

// MARK: - Authentication Manager

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    @Published var authState: AuthenticationState = .undefined
    @Published var currentUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private init() {
        registerAuthStateHandler()
    }

    // MARK: - Auth State Handler

    private func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
                Task { @MainActor in
                    if let user = user {
                        // User is signed in
                        self?.loadUserData(uid: user.uid)
                        self?.authState = .authenticated
                    } else {
                        // User is signed out
                        self?.currentUser = nil
                        self?.authState = .unauthenticated
                    }
                }
            }
        }
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String, firstName: String, lastName: String, username: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            // Create user profile
            let newUser = AppUser(
                uid: result.user.uid,
                email: email,
                firstName: firstName,
                lastName: lastName,
                username: username,
                createdAt: Date()
            )

            // Save user data locally (and would save to Firestore in production)
            saveUserData(newUser)
            currentUser = newUser

            // Update Firebase user profile
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = "\(firstName) \(lastName)"
            try await changeRequest.commitChanges()

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = parseAuthError(error)
            throw error
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            loadUserData(uid: result.user.uid)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = parseAuthError(error)
            throw error
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            authState = .unauthenticated

            // Clear all user data
            clearAllUserData()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = parseAuthError(error)
            throw error
        }
    }

    // MARK: - User Data Management

    private func saveUserData(_ user: AppUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser_\(user.uid)")
        }

        // Also update the recruit profile with the user's name
        let profileManager = RecruitProfileManager.shared
        profileManager.profile.firstName = user.firstName
        profileManager.profile.lastName = user.lastName
        profileManager.profile.email = user.email
    }

    private func loadUserData(uid: String) {
        if let data = UserDefaults.standard.data(forKey: "currentUser_\(uid)"),
           let user = try? JSONDecoder().decode(AppUser.self, from: data) {
            currentUser = user

            // Sync with recruit profile
            let profileManager = RecruitProfileManager.shared
            if profileManager.profile.firstName.isEmpty {
                profileManager.profile.firstName = user.firstName
            }
            if profileManager.profile.lastName.isEmpty {
                profileManager.profile.lastName = user.lastName
            }
            if profileManager.profile.email.isEmpty {
                profileManager.profile.email = user.email
            }
        } else if let firebaseUser = Auth.auth().currentUser {
            // Create basic user from Firebase data
            let nameParts = (firebaseUser.displayName ?? "").split(separator: " ")
            let firstName = nameParts.first.map(String.init) ?? ""
            let lastName = nameParts.dropFirst().joined(separator: " ")

            let user = AppUser(
                uid: firebaseUser.uid,
                email: firebaseUser.email ?? "",
                firstName: firstName,
                lastName: lastName,
                username: firebaseUser.email?.components(separatedBy: "@").first ?? "",
                createdAt: Date()
            )
            saveUserData(user)
            currentUser = user
        }
    }

    func updateUserProfile(firstName: String, lastName: String, username: String) {
        guard var user = currentUser else { return }

        user.firstName = firstName
        user.lastName = lastName
        user.username = username

        saveUserData(user)
        currentUser = user
    }

    private func clearAllUserData() {
        // Reset managers to default state
        RecruitProfileManager.shared.resetToDefaults()
        WidgetPreferencesManager.shared.resetToDefaults()
        VideoStorageManager.shared.clearAllVideos()
    }

    // MARK: - Error Handling

    private func parseAuthError(_ error: Error) -> String {
        let nsError = error as NSError

        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered. Please sign in instead."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters long."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email. Please sign up."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many attempts. Please try again later."
        default:
            return error.localizedDescription
        }
    }
}

// MARK: - Validation Helpers

extension AuthenticationManager {
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: username)
    }
}
