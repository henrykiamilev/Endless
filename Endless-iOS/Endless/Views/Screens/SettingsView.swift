import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject private var profileManager = RecruitProfileManager.shared
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var showingMenu = false
    @State private var showingSignOutAlert = false
    @State private var showingEditProfile = false
    @State private var showingRecruitmentProfile = false
    @State private var showingPrivacySecurity = false
    @State private var showingNotifications = false
    @State private var showingGolfSettings = false
    @State private var showingConnectedDevices = false
    @State private var showingDataStorage = false
    @State private var showingHelpCenter = false
    @State private var showingContactSupport = false
    @State private var showingTerms = false
    @State private var showingPrivacyPolicy = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Branded Header
                brandedHeader

                // Profile Section
                profileCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                // Appearance Section
                settingsSection(label: "APPEARANCE", icon: "paintbrush") {
                    themeSettingsGroup
                }

                // Account Section
                settingsSection(label: "ACCOUNT", icon: "person.circle") {
                    accountSettingsGroup
                }

                // Preferences Section
                settingsSection(label: "PREFERENCES", icon: "gearshape") {
                    preferencesSettingsGroup
                }

                // Support Section
                settingsSection(label: "SUPPORT", icon: "questionmark.circle") {
                    supportSettingsGroup
                }

                // Sign Out
                signOutButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                // Version & Branding
                footerBranding
                    .padding(.bottom, 120)
            }
        }
        .background(themeManager.theme.background)
        // All sheets
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showingRecruitmentProfile) {
            RecruitmentProfileSheet()
        }
        .sheet(isPresented: $showingPrivacySecurity) {
            PrivacySecuritySheet()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsSheet()
        }
        .sheet(isPresented: $showingGolfSettings) {
            GolfSettingsSheet()
        }
        .sheet(isPresented: $showingConnectedDevices) {
            ConnectedDevicesSheet()
        }
        .sheet(isPresented: $showingDataStorage) {
            DataStorageSheet()
        }
        .sheet(isPresented: $showingHelpCenter) {
            HelpCenterSheet()
        }
        .sheet(isPresented: $showingContactSupport) {
            ContactSupportSheet()
        }
        .sheet(isPresented: $showingTerms) {
            TermsSheet()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicySheet()
        }
    }

    // MARK: - Branded Header

    private var brandedHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { showingMenu = true }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 48, height: 48)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                Spacer()

                // Endless Logo
                EndlessLogo(size: 48, showText: false)
            }
            .padding(.bottom, 28)

            Text("SETTINGS")
                .font(.system(size: 48, weight: .heavy))
                .tracking(-2)
                .foregroundColor(themeManager.theme.textPrimary)
                .padding(.bottom, 8)

            Text("Manage your account and preferences")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .sheet(isPresented: $showingMenu) {
            MenuSheetView()
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        Button(action: { showingEditProfile = true }) {
            HStack(spacing: 18) {
                // Profile image with gradient border
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [themeManager.theme.primary, themeManager.theme.accentBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 68, height: 68)

                    Circle()
                        .fill(themeManager.theme.accentGreen)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(profileManager.profile.firstName.isEmpty ? "?" : String(profileManager.profile.firstName.prefix(1)))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(profileManager.profile.fullName.trimmingCharacters(in: .whitespaces).isEmpty ? "Set up your profile" : profileManager.profile.fullName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text(profileManager.profile.email.isEmpty ? "Tap to add your info" : profileManager.profile.email)
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)

                    // Pro badge
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                        Text("PRO MEMBER")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.5)
                    }
                    .foregroundColor(themeManager.theme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.theme.primary.opacity(0.15))
                    .cornerRadius(10)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textMuted)
            }
            .padding(20)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Theme Settings

    private var themeSettingsGroup: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    themeManager.toggleTheme()
                }
            }) {
                HStack(spacing: 16) {
                    settingsIcon(themeManager.isDark ? "moon.fill" : "sun.max.fill")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Theme")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text(themeManager.isDark ? "Dark mode enabled" : "Light mode enabled")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    Spacer()

                    // Toggle indicator
                    ZStack {
                        Capsule()
                            .fill(themeManager.isDark ? themeManager.theme.primary : themeManager.theme.border)
                            .frame(width: 52, height: 30)

                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            .offset(x: themeManager.isDark ? 10 : -10)
                    }
                }
                .padding(18)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Account Settings

    private var accountSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRowButton(icon: "person", title: "Edit Profile", subtitle: "Name, photo, bio") {
                showingEditProfile = true
            }
            divider
            settingsRowButton(icon: "graduationcap", title: "Recruitment Profile", subtitle: "Stats, achievements, videos") {
                showingRecruitmentProfile = true
            }
            divider
            settingsRowButton(icon: "shield", title: "Privacy & Security", subtitle: "Password, 2FA") {
                showingPrivacySecurity = true
            }
            divider
            settingsRowButton(icon: "bell", title: "Notifications", subtitle: "Push, email, SMS") {
                showingNotifications = true
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Preferences Settings

    private var preferencesSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRowButton(icon: "figure.golf", title: "Golf Settings", subtitle: "Handicap: 4.2, Home: Oakmont CC") {
                showingGolfSettings = true
            }
            divider
            settingsRowButton(icon: "cpu", title: "Connected Devices", subtitle: "GCQuad, Apple Watch") {
                showingConnectedDevices = true
            }
            divider
            settingsRowButton(icon: "cloud", title: "Data & Storage", subtitle: "2.3 GB used") {
                showingDataStorage = true
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Support Settings

    private var supportSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRowButton(icon: "questionmark.circle", title: "Help Center", subtitle: "FAQs & guides") {
                showingHelpCenter = true
            }
            divider
            settingsRowButton(icon: "bubble.left", title: "Contact Support", subtitle: "Get help from our team") {
                showingContactSupport = true
            }
            divider
            settingsRowButton(icon: "doc.text", title: "Terms of Service", subtitle: nil) {
                showingTerms = true
            }
            divider
            settingsRowButton(icon: "lock", title: "Privacy Policy", subtitle: nil) {
                showingPrivacyPolicy = true
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button(action: { showingSignOutAlert = true }) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .medium))
                Text("Sign Out")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(themeManager.theme.error)
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(themeManager.theme.error.opacity(0.1))
            .cornerRadius(24)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out of your Endless account?")
        }
    }

    // MARK: - Footer Branding

    private var footerBranding: some View {
        VStack(spacing: 16) {
            EndlessLogo(size: 40, showText: true, textPosition: .bottom)

            Text("Version 1.0.0")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(themeManager.theme.textMuted)

            Text("Made with love for golfers worldwide")
                .font(.system(size: 11))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    // MARK: - Helpers

    private func settingsSection<Content: View>(label: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.primary)
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(.leading, 4)

            content()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private func settingsRowButton(icon: String, title: String, subtitle: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                settingsIcon(icon)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textMuted)
            }
            .padding(18)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func settingsIcon(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(themeManager.theme.primary.opacity(0.12))
                .frame(width: 42, height: 42)

            Image(systemName: name)
                .font(.system(size: 18))
                .foregroundColor(themeManager.theme.primary)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(themeManager.theme.border)
            .frame(height: 1)
            .padding(.leading, 76)
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var profileManager = RecruitProfileManager.shared
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile header
                    VStack(spacing: 20) {
                        Button(action: { showingImagePicker = true }) {
                            ZStack {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [themeManager.theme.primary, themeManager.theme.accentBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                                    .frame(width: 104, height: 104)

                                Circle()
                                    .fill(themeManager.theme.accentGreen)
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Text(String(firstName.prefix(1)))
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(.white)
                                    )

                                // Edit button
                                Circle()
                                    .fill(themeManager.theme.cardBackground)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(themeManager.theme.primary)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    .offset(x: 36, y: 36)
                            }
                        }

                        Text("Tap to change photo")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(themeManager.theme.cardBackground)

                    VStack(spacing: 24) {
                        // Personal Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PERSONAL INFORMATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(themeManager.theme.textSecondary)

                            VStack(spacing: 0) {
                                editableField(label: "First Name", text: $firstName)
                                Divider().padding(.leading, 16)
                                editableField(label: "Last Name", text: $lastName)
                                Divider().padding(.leading, 16)
                                editableField(label: "Email", text: $email, keyboardType: .emailAddress)
                                Divider().padding(.leading, 16)
                                editableField(label: "Phone", text: $phone, keyboardType: .phonePad)
                            }
                            .background(themeManager.theme.cardBackground)
                            .cornerRadius(16)
                        }
                    }
                    .padding(20)
                }
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
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.theme.primary)
                }
            }
            .onAppear {
                // Load current profile data
                firstName = profileManager.profile.firstName
                lastName = profileManager.profile.lastName
                email = profileManager.profile.email
                phone = profileManager.profile.phone
            }
        }
    }

    private func saveProfile() {
        profileManager.profile.firstName = firstName
        profileManager.profile.lastName = lastName
        profileManager.profile.email = email
        profileManager.profile.phone = phone
        dismiss()
    }

    private func editableField(label: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(themeManager.theme.textSecondary)
                .frame(width: 90, alignment: .leading)
            TextField(label, text: text)
                .font(.system(size: 15))
                .keyboardType(keyboardType)
                .foregroundColor(themeManager.theme.textPrimary)
        }
        .padding(16)
    }
}

// MARK: - Recruitment Profile Sheet

struct RecruitmentProfileSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(themeManager.theme.accentGreen.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 36))
                        .foregroundColor(themeManager.theme.accentGreen)
                }
                .padding(.top, 32)

                Text("Recruitment Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("Your recruitment profile showcases your golf stats, achievements, and highlight videos to college coaches.")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                // Stats preview
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        statBox(value: "12", label: "Coach Views")
                        statBox(value: "4.2", label: "Handicap")
                        statBox(value: "85%", label: "Profile Complete")
                    }
                }
                .padding(20)
                .background(themeManager.theme.cardBackground)
                .cornerRadius(20)
                .padding(.horizontal, 20)

                Spacer()

                // Go to Recruit Tab button
                Button(action: {
                    dismiss()
                    navigationManager.navigateToRecruit()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.rectangle.stack")
                            .font(.system(size: 16))
                        Text("Go to Recruit Tab")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.theme.accentGreen)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
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

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Privacy & Security Sheet

struct PrivacySecuritySheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var settings = UserSettingsManager.shared
    @State private var showingChangePassword = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { showingChangePassword = true }) {
                        HStack {
                            Label("Change Password", systemImage: "key.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(themeManager.theme.textMuted)
                        }
                    }
                    .foregroundColor(themeManager.theme.textPrimary)

                    Toggle(isOn: $settings.twoFactorEnabled) {
                        Label("Two-Factor Authentication", systemImage: "lock.shield.fill")
                    }
                    .tint(themeManager.theme.accentGreen)

                    Toggle(isOn: $settings.faceIDEnabled) {
                        Label("Face ID / Touch ID", systemImage: "faceid")
                    }
                    .tint(themeManager.theme.accentGreen)
                } header: {
                    Text("Security")
                }

                Section {
                    Toggle(isOn: $settings.privateProfile) {
                        Label("Private Profile", systemImage: "eye.slash.fill")
                    }
                    .tint(themeManager.theme.accentGreen)

                    NavigationLink {
                        BlockedUsersView()
                    } label: {
                        Label("Blocked Users", systemImage: "person.crop.circle.badge.minus")
                    }

                    NavigationLink {
                        LoginActivityView()
                    } label: {
                        Label("Login Activity", systemImage: "clock.arrow.circlepath")
                    }
                } header: {
                    Text("Privacy")
                }

                Section {
                    Button(action: {}) {
                        Label("Download Your Data", systemImage: "arrow.down.doc.fill")
                    }
                    .foregroundColor(themeManager.theme.textPrimary)

                    Button(action: {}) {
                        Label("Delete Account", systemImage: "trash.fill")
                            .foregroundColor(themeManager.theme.error)
                    }
                } header: {
                    Text("Your Data")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordSheet()
            }
        }
    }
}

struct BlockedUsersView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.minus")
                .font(.system(size: 48))
                .foregroundColor(themeManager.theme.textMuted)
            Text("No Blocked Users")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
            Text("Users you block won't be able to see your profile or contact you.")
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.theme.background)
        .navigationTitle("Blocked Users")
    }
}

struct LoginActivityView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            Section {
                loginRow(device: "iPhone 15 Pro", location: "San Francisco, CA", time: "Active now", isCurrentDevice: true)
                loginRow(device: "MacBook Pro", location: "San Francisco, CA", time: "2 hours ago", isCurrentDevice: false)
                loginRow(device: "iPad Air", location: "Los Angeles, CA", time: "Yesterday", isCurrentDevice: false)
            } header: {
                Text("Where You're Logged In")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Login Activity")
    }

    private func loginRow(device: String, location: String, time: String, isCurrentDevice: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: device.contains("iPhone") ? "iphone" : device.contains("Mac") ? "laptopcomputer" : "ipad")
                .font(.system(size: 24))
                .foregroundColor(themeManager.theme.textSecondary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(device)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    if isCurrentDevice {
                        Text("This Device")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(themeManager.theme.accentGreen)
                            .cornerRadius(6)
                    }
                }
                Text("\(location) • \(time)")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChangePasswordSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationView {
            List {
                Section {
                    SecureField("Current Password", text: $currentPassword)
                } header: {
                    Text("Current Password")
                }

                Section {
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                } header: {
                    Text("New Password")
                } footer: {
                    Text("Password must be at least 8 characters with a number and special character.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                        .fontWeight(.semibold)
                        .disabled(newPassword.isEmpty || newPassword != confirmPassword)
                }
            }
        }
    }
}

// MARK: - Notifications Sheet

struct NotificationsSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var settings = UserSettingsManager.shared

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Push Notifications", isOn: $settings.pushEnabled)
                    Toggle("Email Notifications", isOn: $settings.emailEnabled)
                    Toggle("SMS Notifications", isOn: $settings.smsEnabled)
                } header: {
                    Text("Notification Methods")
                }

                Section {
                    Toggle("Coach Messages", isOn: $settings.coachMessages)
                    Toggle("Session Reminders", isOn: $settings.sessionReminders)
                    Toggle("Weekly Progress Digest", isOn: $settings.weeklyDigest)
                    Toggle("New Features & Updates", isOn: $settings.newFeatures)
                } header: {
                    Text("What to Notify")
                }

                Section {
                    NavigationLink("Muted Conversations") {
                        MutedConversationsView()
                    }
                } header: {
                    Text("Manage")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }
}

struct MutedConversationsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(themeManager.theme.textMuted)
            Text("No Muted Conversations")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.theme.background)
        .navigationTitle("Muted")
    }
}

// MARK: - Golf Settings Sheet

struct GolfSettingsSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var settings = UserSettingsManager.shared

    @StateObject private var searchService = GolfCourseSearchService()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    let teeOptions = ["Championship", "Back", "Middle", "Forward"]
    let units = ["Yards", "Meters"]
    let hands = ["Right", "Left"]

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Handicap Index")
                        Spacer()
                        TextField("0.0", text: $settings.handicap)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(themeManager.theme.primary)
                    }

                    Picker("Preferred Tees", selection: $settings.preferredTees) {
                        ForEach(teeOptions, id: \.self) { tee in
                            Text(tee).tag(tee)
                        }
                    }
                } header: {
                    Text("Golf Profile")
                }

                Section {
                    // Current home course display
                    if !settings.homeCourse.isEmpty && searchText.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Home Course")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textSecondary)
                                Text(settings.homeCourse)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(themeManager.theme.textPrimary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(themeManager.theme.accentGreen)
                        }
                        .padding(.vertical, 4)
                    }

                    // Search text field
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.theme.textSecondary)

                        TextField("Search golf courses...", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .focused($isSearchFocused)
                            .autocorrectionDisabled()
                            .onChange(of: searchText) { _, newValue in
                                searchService.search(query: newValue)
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchService.clearResults()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.theme.textSecondary)
                            }
                        }

                        if searchService.isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.vertical, 4)

                    // Search results
                    if !searchService.searchResults.isEmpty {
                        ForEach(searchService.searchResults) { result in
                            Button(action: {
                                settings.homeCourse = result.displayName
                                searchText = ""
                                searchService.clearResults()
                                isSearchFocused = false
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(themeManager.theme.textPrimary)

                                        if !result.address.isEmpty {
                                            Text(result.address)
                                                .font(.system(size: 12))
                                                .foregroundColor(themeManager.theme.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: "location.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(themeManager.theme.primary)
                                }
                            }
                        }
                    }

                    // Empty state when searching
                    if searchText.count >= 2 && searchService.searchResults.isEmpty && !searchService.isSearching {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textMuted)

                            Text("No golf courses found")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.textSecondary)
                        }
                        .padding(.vertical, 8)
                    }

                    // Error state
                    if let error = searchService.searchError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.theme.error)

                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.theme.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Home Course")
                } footer: {
                    Text("Search for golf courses worldwide")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textMuted)
                }

                Section {
                    Picker("Distance Unit", selection: $settings.measurementUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }

                    Picker("Dominant Hand", selection: $settings.dominantHand) {
                        ForEach(hands, id: \.self) { hand in
                            Text(hand).tag(hand)
                        }
                    }
                } header: {
                    Text("Preferences")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Golf Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }
}

// MARK: - Connected Devices Sheet

struct ConnectedDevicesSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var devices: [ConnectedDevice] = [
        ConnectedDevice(name: "GCQuad Launch Monitor", type: "Launch Monitor", isConnected: true, icon: "scope"),
        ConnectedDevice(name: "Apple Watch Series 9", type: "Wearable", isConnected: true, icon: "applewatch"),
        ConnectedDevice(name: "Arccos Sensors", type: "Shot Tracking", isConnected: false, icon: "sensor.tag.radiowaves.forward")
    ]

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(devices) { device in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(device.isConnected ? themeManager.theme.accentGreen.opacity(0.15) : themeManager.theme.textMuted.opacity(0.15))
                                    .frame(width: 44, height: 44)

                                Image(systemName: device.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(device.isConnected ? themeManager.theme.accentGreen : themeManager.theme.textMuted)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(device.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(themeManager.theme.textPrimary)
                                Text(device.type)
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textSecondary)
                            }

                            Spacer()

                            Text(device.isConnected ? "Connected" : "Disconnected")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(device.isConnected ? themeManager.theme.accentGreen : themeManager.theme.textMuted)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background((device.isConnected ? themeManager.theme.accentGreen : themeManager.theme.textMuted).opacity(0.15))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("My Devices")
                }

                Section {
                    Button(action: {}) {
                        Label("Add New Device", systemImage: "plus.circle.fill")
                    }
                    .foregroundColor(themeManager.theme.primary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Connected Devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }
}

struct ConnectedDevice: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let isConnected: Bool
    let icon: String
}

// MARK: - Data & Storage Sheet

struct DataStorageSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var showingClearCacheAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Label("Videos", systemImage: "video.fill")
                        Spacer()
                        Text("1.8 GB")
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    HStack {
                        Label("Swing Data", systemImage: "waveform.path.ecg")
                        Spacer()
                        Text("320 MB")
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    HStack {
                        Label("Cache", systemImage: "internaldrive")
                        Spacer()
                        Text("180 MB")
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                } header: {
                    Text("Storage Usage")
                } footer: {
                    Text("Total: 2.3 GB of 5 GB used")
                }

                Section {
                    Button(action: { showingClearCacheAlert = true }) {
                        Label("Clear Cache", systemImage: "trash")
                    }
                    .foregroundColor(themeManager.theme.error)

                    Button(action: {}) {
                        Label("Manage Downloads", systemImage: "arrow.down.circle")
                    }
                    .foregroundColor(themeManager.theme.textPrimary)
                } header: {
                    Text("Manage Storage")
                }

                Section {
                    Toggle("Auto-Download Videos on WiFi", isOn: .constant(true))
                    Toggle("High Quality Uploads", isOn: .constant(true))
                } header: {
                    Text("Data Saver")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Data & Storage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
            .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) { }
            } message: {
                Text("This will free up 180 MB of storage. Your videos and data will not be affected.")
            }
        }
    }
}

// MARK: - Help Center Sheet

struct HelpCenterSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    let faqs = [
        FAQ(question: "How do I record my swing?", category: "Recording"),
        FAQ(question: "How does AI swing analysis work?", category: "AI Features"),
        FAQ(question: "How do I share videos with coaches?", category: "Recruiting"),
        FAQ(question: "How do I connect my launch monitor?", category: "Devices"),
        FAQ(question: "How do I change my handicap?", category: "Profile"),
        FAQ(question: "How do I cancel my subscription?", category: "Billing")
    ]

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.theme.textSecondary)
                        TextField("Search help articles...", text: $searchText)
                    }
                    .padding(12)
                    .background(themeManager.theme.background)
                    .cornerRadius(12)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section {
                    ForEach(faqs) { faq in
                        NavigationLink {
                            FAQDetailView(faq: faq)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(faq.question)
                                    .font(.system(size: 15))
                                    .foregroundColor(themeManager.theme.textPrimary)
                                Text(faq.category)
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textSecondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Frequently Asked Questions")
                }

                Section {
                    NavigationLink {
                        GettingStartedView()
                    } label: {
                        Label("Getting Started Guide", systemImage: "book.fill")
                    }

                    NavigationLink {
                        VideoTutorialsView()
                    } label: {
                        Label("Video Tutorials", systemImage: "play.rectangle.fill")
                    }
                } header: {
                    Text("Guides")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Help Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let category: String
}

struct FAQDetailView: View {
    let faq: FAQ
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(faq.question)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("This is a detailed answer to the frequently asked question. It provides step-by-step instructions and helpful tips for users.")
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .lineSpacing(6)

                Text("If you need more help, please contact our support team.")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textMuted)
                    .padding(.top, 16)
            }
            .padding(20)
        }
        .background(themeManager.theme.background)
        .navigationTitle(faq.category)
    }
}

struct GettingStartedView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Endless! This guide will help you get started with recording and analyzing your golf swing.")
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .padding(20)
        }
        .background(themeManager.theme.background)
        .navigationTitle("Getting Started")
    }
}

struct VideoTutorialsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            ForEach(["Recording Your First Swing", "Understanding AI Analysis", "Sharing with Coaches", "Using Launch Monitor Data"], id: \.self) { tutorial in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.theme.primary.opacity(0.15))
                            .frame(width: 60, height: 40)
                        Image(systemName: "play.fill")
                            .foregroundColor(themeManager.theme.primary)
                    }
                    Text(tutorial)
                        .font(.system(size: 15))
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Tutorials")
    }
}

// MARK: - Contact Support Sheet

struct ContactSupportSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var showingSubmitAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(themeManager.theme.primary.opacity(0.15))
                                .frame(width: 72, height: 72)
                            Image(systemName: "headphones")
                                .font(.system(size: 32))
                                .foregroundColor(themeManager.theme.primary)
                        }

                        Text("How can we help?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text("We typically respond within 24 hours")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                    .padding(.top, 24)

                    // Form
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subject")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.theme.textSecondary)

                            TextField("What's this about?", text: $subject)
                                .padding(14)
                                .background(themeManager.theme.cardBackground)
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.theme.textSecondary)

                            TextEditor(text: $message)
                                .frame(height: 150)
                                .padding(10)
                                .background(themeManager.theme.cardBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Submit button
                    Button(action: { showingSubmitAlert = true }) {
                        Text("Send Message")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeManager.theme.primary)
                            .cornerRadius(16)
                    }
                    .disabled(subject.isEmpty || message.isEmpty)
                    .opacity(subject.isEmpty || message.isEmpty ? 0.6 : 1)
                    .padding(.horizontal, 20)

                    // Other contact options
                    VStack(spacing: 12) {
                        Text("Or reach us at")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textMuted)

                        HStack(spacing: 20) {
                            contactOption(icon: "envelope.fill", label: "Email")
                            contactOption(icon: "bubble.left.fill", label: "Chat")
                            contactOption(icon: "phone.fill", label: "Call")
                        }
                    }
                    .padding(.top, 16)

                    Spacer(minLength: 40)
                }
            }
            .background(themeManager.theme.background)
            .navigationTitle("Contact Support")
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
            .alert("Message Sent", isPresented: $showingSubmitAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Thanks for reaching out! We'll get back to you within 24 hours.")
            }
        }
    }

    private func contactOption(icon: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.cardBackground)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.theme.primary)
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(themeManager.theme.textSecondary)
        }
    }
}

// MARK: - Terms Sheet

struct TermsSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("Last updated: December 2025")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)

                    Group {
                        sectionTitle("1. Acceptance of Terms")
                        sectionText("By accessing or using the Endless Golf app, you agree to be bound by these Terms of Service and all applicable laws and regulations.")

                        sectionTitle("2. Use License")
                        sectionText("Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.")

                        sectionTitle("3. User Account")
                        sectionText("You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device.")

                        sectionTitle("4. Privacy")
                        sectionText("Your use of the app is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the app and informs users of our data collection practices.")

                        sectionTitle("5. Modifications")
                        sectionText("Endless reserves the right to modify or discontinue the app or any features without notice. We shall not be liable to you or any third party should we exercise such right.")
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(themeManager.theme.textPrimary)
            .padding(.top, 8)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(themeManager.theme.textSecondary)
            .lineSpacing(4)
    }
}

// MARK: - Privacy Policy Sheet

struct PrivacyPolicySheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("Last updated: December 2025")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)

                    Group {
                        sectionTitle("Information We Collect")
                        sectionText("We collect information you provide directly to us, such as when you create an account, record a video, or contact us for support.")

                        sectionTitle("How We Use Your Information")
                        sectionText("We use the information we collect to provide, maintain, and improve our services, to process transactions, and to communicate with you.")

                        sectionTitle("Information Sharing")
                        sectionText("We do not share your personal information with third parties except as described in this policy or with your consent.")

                        sectionTitle("Data Security")
                        sectionText("We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.")

                        sectionTitle("Your Rights")
                        sectionText("You have the right to access, correct, or delete your personal information. You can also object to processing of your information or request data portability.")

                        sectionTitle("Contact Us")
                        sectionText("If you have any questions about this Privacy Policy, please contact us at privacy@endlessgolf.com")
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(themeManager.theme.textPrimary)
            .padding(.top, 8)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(themeManager.theme.textSecondary)
            .lineSpacing(4)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
