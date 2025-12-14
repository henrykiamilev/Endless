import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                headerView

                // Profile Section
                profileCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                // Appearance Section
                settingsSection(label: "APPEARANCE") {
                    themeSettingsGroup
                }

                // Account Section
                settingsSection(label: "ACCOUNT") {
                    accountSettingsGroup
                }

                // Preferences Section
                settingsSection(label: "PREFERENCES") {
                    preferencesSettingsGroup
                }

                // Support Section
                settingsSection(label: "SUPPORT") {
                    supportSettingsGroup
                }

                // Sign Out
                signOutButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                // Version
                versionInfo
                    .padding(.bottom, 120)
            }
        }
        .background(themeManager.theme.background)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(Circle())
                }

                Spacer()
            }
            .padding(.bottom, 20)

            Text("SETTINGS")
                .font(.system(size: 48, weight: .heavy))
                .tracking(-2)
                .foregroundColor(themeManager.theme.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Circle()
                    .fill(themeManager.theme.primary)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("W")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.theme.textInverse)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Will Johnson")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("will.johnson@email.com")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textMuted)
            }
            .padding(18)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)
        }
    }

    // MARK: - Theme Settings

    private var themeSettingsGroup: some View {
        VStack(spacing: 0) {
            Button(action: { themeManager.toggleTheme() }) {
                HStack(spacing: 14) {
                    settingsIcon(themeManager.isDark ? "moon.fill" : "sun.max.fill")

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Theme")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.theme.textPrimary)

                        Text(themeManager.isDark ? "Dark mode" : "Light mode")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }

                    Spacer()

                    Text(themeManager.isDark ? "DARK" : "LIGHT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 12)
                        .background(themeManager.theme.backgroundSecondary)
                        .cornerRadius(10)
                }
                .padding(16)
            }
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(20)
    }

    // MARK: - Account Settings

    private var accountSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "person", title: "Edit Profile", subtitle: "Name, photo, bio")
            divider
            settingsRow(icon: "graduationcap", title: "Recruitment Profile", subtitle: "Stats, achievements, videos")
            divider
            settingsRow(icon: "shield", title: "Privacy & Security", subtitle: nil)
            divider
            settingsRow(icon: "bell", title: "Notifications", subtitle: nil)
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(20)
    }

    // MARK: - Preferences Settings

    private var preferencesSettingsGroup: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "figure.golf", title: "Golf Settings", subtitle: "Handicap, home course")
            divider
            settingsRow(icon: "cpu", title: "Connected Devices", subtitle: "Launch monitors, sensors")
            divider
            settingsRow(icon: "cloud", title: "Data & Storage", subtitle: nil)
        }
        .background(themeManager.theme.cardBackground)
        .cornerRadius(20)
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
        .cornerRadius(20)
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18))
                Text("Sign Out")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(themeManager.theme.error)
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(themeManager.theme.cardBackground)
            .cornerRadius(20)
        }
    }

    // MARK: - Version Info

    private var versionInfo: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(themeManager.theme.cardBackground)
                    .frame(width: 44, height: 44)

                Text("∞")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(themeManager.theme.primary)
            }

            Text("Endless v1.0.0")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func settingsSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)
                .padding(.leading, 4)

            content()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private func settingsRow(icon: String, title: String, subtitle: String?) -> some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                settingsIcon(icon)

                VStack(alignment: .leading, spacing: 3) {
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
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textMuted)
            }
            .padding(16)
        }
    }

    private func settingsIcon(_ name: String) -> some View {
        Circle()
            .fill(themeManager.theme.primary.opacity(0.15))
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: name)
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.theme.primary)
            )
    }

    private var divider: some View {
        Divider()
            .background(themeManager.theme.border)
            .padding(.leading, 70)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
