import SwiftUI

// MARK: - Main Authentication View

struct AuthenticationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingSignUp = false

    var body: some View {
        ZStack {
            // Background
            themeManager.theme.background
                .ignoresSafeArea()

            if showingSignUp {
                SignUpView(showingSignUp: $showingSignUp)
                    .environmentObject(themeManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
            } else {
                LoginView(showingSignUp: $showingSignUp)
                    .environmentObject(themeManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSignUp)
    }
}

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var authManager = AuthenticationManager.shared
    @Binding var showingSignUp: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Logo and Welcome
                VStack(spacing: 16) {
                    EndlessLogo(size: 80, showText: true)
                        .padding(.top, 60)

                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("Sign in to continue your golf journey")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.bottom, 48)

                // Form Fields
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)

                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textMuted)

                            TextField("Enter your email", text: $email)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textPrimary)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                        }
                        .padding(16)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(focusedField == .email ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                        )
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textMuted)

                            SecureField("Enter your password", text: $password)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textPrimary)
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)
                        }
                        .padding(16)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(focusedField == .password ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                        )
                    }

                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: { showingForgotPassword = true }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.theme.accentGreen)
                        }
                    }

                    // Error Message
                    if let error = authManager.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                            Text(error)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(themeManager.theme.error)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(themeManager.theme.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    // Sign In Button
                    Button(action: signIn) {
                        HStack(spacing: 8) {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [themeManager.theme.accentGreen, themeManager.theme.accentGreen.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: themeManager.theme.accentGreen.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .disabled(!isFormValid || authManager.isLoading)
                    .opacity(isFormValid ? 1 : 0.6)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)

                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme.textSecondary)

                    Button(action: { showingSignUp = true }) {
                        Text("Sign Up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(themeManager.theme.accentGreen)
                    }
                }
                .padding(.top, 32)

                Spacer(minLength: 40)
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
                .environmentObject(themeManager)
        }
    }

    private var isFormValid: Bool {
        authManager.isValidEmail(email) && !password.isEmpty
    }

    private func signIn() {
        focusedField = nil
        Task {
            try? await authManager.signIn(email: email, password: password)
        }
    }
}

// MARK: - Sign Up View

struct SignUpView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var authManager = AuthenticationManager.shared
    @Binding var showingSignUp: Bool

    @State private var currentStep = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case firstName, lastName, email, username, password, confirmPassword
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header with Back Button
                HStack {
                    Button(action: goBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(Circle())
                    }
                    Spacer()

                    // Progress Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<2) { step in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(step <= currentStep ? themeManager.theme.accentGreen : themeManager.theme.cardBackground)
                                .frame(width: step <= currentStep ? 32 : 24, height: 6)
                        }
                    }

                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Title
                VStack(spacing: 8) {
                    Text(currentStep == 0 ? "Create Account" : "Choose Credentials")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(currentStep == 0 ? "Tell us about yourself" : "Secure your account")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.top, 32)
                .padding(.bottom, 40)

                // Form Steps
                if currentStep == 0 {
                    step1View
                } else {
                    step2View
                }

                // Sign In Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme.textSecondary)

                    Button(action: { showingSignUp = false }) {
                        Text("Sign In")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(themeManager.theme.accentGreen)
                    }
                }
                .padding(.top, 32)

                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Step 1: Name & Email

    private var step1View: some View {
        VStack(spacing: 20) {
            // First Name
            VStack(alignment: .leading, spacing: 8) {
                Text("First Name")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textMuted)

                    TextField("Enter your first name", text: $firstName)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .firstName)
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == .firstName ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                )
            }

            // Last Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Name")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textMuted)

                    TextField("Enter your last name", text: $lastName)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .lastName)
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == .lastName ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                )
            }

            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textMuted)

                    TextField("Enter your email", text: $email)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == .email ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                )

                if !email.isEmpty && !authManager.isValidEmail(email) {
                    Text("Please enter a valid email address")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.error)
                }
            }

            // Continue Button
            Button(action: { withAnimation { currentStep = 1 } }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [themeManager.theme.accentGreen, themeManager.theme.accentGreen.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: themeManager.theme.accentGreen.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(!isStep1Valid)
            .opacity(isStep1Valid ? 1 : 0.6)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 2: Username & Password

    private var step2View: some View {
        VStack(spacing: 20) {
            // Username
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "at")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textMuted)

                    TextField("Choose a username", text: $username)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .username)
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == .username ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                )

                if !username.isEmpty && !authManager.isValidUsername(username) {
                    Text("Username must be 3-20 characters (letters, numbers, underscores)")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.error)
                }
            }

            // Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textMuted)

                    SecureField("Create a password", text: $password)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .password)
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == .password ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                )

                if !password.isEmpty && !authManager.isValidPassword(password) {
                    Text("Password must be at least 6 characters")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.error)
                }
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textMuted)

                    SecureField("Confirm your password", text: $confirmPassword)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .confirmPassword)
                }
                .padding(16)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == .confirmPassword ? themeManager.theme.accentGreen : Color.clear, lineWidth: 2)
                )

                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords do not match")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.error)
                }
            }

            // Error Message
            if let error = authManager.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                    Text(error)
                        .font(.system(size: 13))
                }
                .foregroundColor(themeManager.theme.error)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.error.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            // Create Account Button
            Button(action: signUp) {
                HStack(spacing: 8) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Text("Create Account")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [themeManager.theme.accentGreen, themeManager.theme.accentGreen.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: themeManager.theme.accentGreen.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(!isStep2Valid || authManager.isLoading)
            .opacity(isStep2Valid ? 1 : 0.6)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Validation

    private var isStep1Valid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && authManager.isValidEmail(email)
    }

    private var isStep2Valid: Bool {
        authManager.isValidUsername(username) &&
        authManager.isValidPassword(password) &&
        password == confirmPassword
    }

    // MARK: - Actions

    private func goBack() {
        if currentStep > 0 {
            withAnimation { currentStep -= 1 }
        } else {
            showingSignUp = false
        }
    }

    private func signUp() {
        focusedField = nil
        Task {
            try? await authManager.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                username: username
            )
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var emailSent = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(themeManager.theme.accentGreen.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: emailSent ? "checkmark.circle.fill" : "envelope.fill")
                        .font(.system(size: 36))
                        .foregroundColor(themeManager.theme.accentGreen)
                }
                .padding(.top, 40)

                // Title
                VStack(spacing: 8) {
                    Text(emailSent ? "Email Sent!" : "Reset Password")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(emailSent ?
                         "Check your inbox for password reset instructions" :
                         "Enter your email and we'll send you a reset link")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                if !emailSent {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textMuted)

                            TextField("Enter your email", text: $email)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.theme.textPrimary)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding(16)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 24)

                    // Error Message
                    if let error = authManager.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme.error)
                            .padding(.horizontal, 24)
                    }

                    // Send Button
                    Button(action: resetPassword) {
                        HStack(spacing: 8) {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Send Reset Link")
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(themeManager.theme.accentGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(!authManager.isValidEmail(email) || authManager.isLoading)
                    .opacity(authManager.isValidEmail(email) ? 1 : 0.6)
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Done Button (shown after email sent)
                if emailSent {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(themeManager.theme.accentGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
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
        }
    }

    private func resetPassword() {
        Task {
            do {
                try await authManager.resetPassword(email: email)
                withAnimation {
                    emailSent = true
                }
            } catch {
                // Error is handled by authManager
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(ThemeManager())
}
