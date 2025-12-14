import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showingMenu = false
    @State private var showingSignOutAlert = false
    @State private var showingEditProfile = false

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
                        .fill(themeManager.theme.primary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("W")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Will Johnson")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("will.johnson@email.com")
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
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheetView()
        }
    }

    // MARK: - Theme Settings

    private var themeSettingsGroup: some View {
        VStack(spacing: 0) {
            Button(action: { themeManager.toggleTheme() }) {
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
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Account Settings

    private var accountSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "person", title: "Edit Profile", subtitle: "Name, photo, bio")
            divider
            settingsRow(icon: "graduationcap", title: "Recruitment Profile", subtitle: "Stats, achievements, videos")
            divider
            settingsRow(icon: "shield", title: "Privacy & Security", subtitle: "Password, 2FA")
            divider
            settingsRow(icon: "bell", title: "Notifications", subtitle: "Push, email, SMS")
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Preferences Settings

    private var preferencesSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "figure.golf", title: "Golf Settings", subtitle: "Handicap: 4.2, Home: Oakmont CC")
            divider
            settingsRow(icon: "cpu", title: "Connected Devices", subtitle: "GCQuad, Apple Watch")
            divider
            settingsRow(icon: "cloud", title: "Data & Storage", subtitle: "2.3 GB used")
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Support Settings

    private var supportSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "questionmark.circle", title: "Help Center", subtitle: nil)
            divider
            settingsRow(icon: "bubble.left", title: "Contact Support", subtitle: nil)
            divider
            settingsRow(icon: "doc.text", title: "Terms of Service", subtitle: nil)
            divider
            settingsRow(icon: "lock", title: "Privacy Policy", subtitle: nil)
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
                navigationManager.navigateToHome()
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

    private func settingsRow(icon: String, title: String, subtitle: String?) -> some View {
        Button(action: {}) {
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

struct EditProfileSheetView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile header
                VStack(spacing: 20) {
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
                            .fill(themeManager.theme.primary)
                            .frame(width: 96, height: 96)
                            .overlay(
                                Text("W")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        // Edit button
                        Button(action: {}) {
                            Circle()
                                .fill(themeManager.theme.cardBackground)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(themeManager.theme.primary)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .offset(x: 36, y: 36)
                    }

                    Text("Tap to change photo")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                List {
                    Section("Personal Information") {
                        profileField(label: "Name", value: "Will Johnson")
                        profileField(label: "Email", value: "will.johnson@email.com")
                        profileField(label: "Phone", value: "+1 (555) 123-4567")
                    }

                    Section("Golf Profile") {
                        profileField(label: "Handicap", value: "4.2")
                        profileField(label: "Home Course", value: "Oakmont CC")
                        profileField(label: "Years Playing", value: "8 years")
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.theme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.theme.primary)
                }
            }
        }
    }

    private func profileField(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(themeManager.theme.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(themeManager.theme.textPrimary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(NavigationManager())
}
