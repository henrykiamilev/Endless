import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  TouchableOpacity,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { Theme } from '../constants/theme';

interface SettingsItemProps {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  subtitle?: string;
  onPress?: () => void;
  showChevron?: boolean;
  theme: Theme;
}

const SettingsItem: React.FC<SettingsItemProps> = ({
  icon,
  title,
  subtitle,
  onPress,
  showChevron = true,
  theme,
}) => (
  <TouchableOpacity
    style={[styles.settingsItem, { borderBottomColor: theme.border }]}
    onPress={onPress}
    activeOpacity={0.6}
  >
    <View style={[styles.settingsItemIcon, { backgroundColor: theme.cardBackgroundElevated }]}>
      <Ionicons name={icon} size={20} color={theme.primary} />
    </View>
    <View style={styles.settingsItemContent}>
      <Text style={[styles.settingsItemTitle, { color: theme.textPrimary }]}>{title}</Text>
      {subtitle && <Text style={[styles.settingsItemSubtitle, { color: theme.textSecondary }]}>{subtitle}</Text>}
    </View>
    {showChevron && (
      <Ionicons name="chevron-forward" size={18} color={theme.textMuted} />
    )}
  </TouchableOpacity>
);

export const SettingsScreen: React.FC = () => {
  const { theme, themeMode, setThemeMode, toggleTheme } = useTheme();

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={[styles.title, { color: theme.textPrimary }]}>Settings</Text>
        </View>

        {/* Profile Section */}
        <View style={styles.section}>
          <TouchableOpacity style={[
            styles.profileCard,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
            }
          ]}>
            <View style={[styles.profileAvatar, { backgroundColor: theme.primary }]}>
              <Text style={[styles.profileInitial, { color: theme.textInverse }]}>W</Text>
            </View>
            <View style={styles.profileInfo}>
              <Text style={[styles.profileName, { color: theme.textPrimary }]}>Will Johnson</Text>
              <Text style={[styles.profileEmail, { color: theme.textSecondary }]}>will.johnson@email.com</Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={theme.textMuted} />
          </TouchableOpacity>
        </View>

        {/* Theme Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>Appearance</Text>
          <View style={[
            styles.settingsGroup,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
            }
          ]}>
            <TouchableOpacity
              style={[styles.settingsItem, { borderBottomColor: theme.border }]}
              onPress={toggleTheme}
              activeOpacity={0.6}
            >
              <View style={[styles.settingsItemIcon, { backgroundColor: theme.cardBackgroundElevated }]}>
                <Ionicons name={theme.isDark ? 'moon' : 'sunny'} size={20} color={theme.primary} />
              </View>
              <View style={styles.settingsItemContent}>
                <Text style={[styles.settingsItemTitle, { color: theme.textPrimary }]}>Theme</Text>
                <Text style={[styles.settingsItemSubtitle, { color: theme.textSecondary }]}>
                  {theme.isDark ? 'Dark mode' : 'Light mode'}
                </Text>
              </View>
              <View style={[styles.themeBadge, { backgroundColor: theme.cardBackgroundElevated }]}>
                <Text style={[styles.themeBadgeText, { color: theme.textSecondary }]}>
                  {theme.isDark ? 'Dark' : 'Light'}
                </Text>
              </View>
            </TouchableOpacity>
          </View>
        </View>

        {/* Account Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>Account</Text>
          <View style={[
            styles.settingsGroup,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
            }
          ]}>
            <SettingsItem
              icon="person-outline"
              title="Edit Profile"
              subtitle="Name, photo, bio"
              theme={theme}
            />
            <SettingsItem
              icon="school-outline"
              title="Recruitment Profile"
              subtitle="Stats, achievements, videos"
              theme={theme}
            />
            <SettingsItem
              icon="shield-outline"
              title="Privacy & Security"
              theme={theme}
            />
            <SettingsItem
              icon="notifications-outline"
              title="Notifications"
              theme={theme}
            />
          </View>
        </View>

        {/* Preferences Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>Preferences</Text>
          <View style={[
            styles.settingsGroup,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
            }
          ]}>
            <SettingsItem
              icon="golf-outline"
              title="Golf Settings"
              subtitle="Handicap, home course"
              theme={theme}
            />
            <SettingsItem
              icon="hardware-chip-outline"
              title="Connected Devices"
              subtitle="Launch monitors, sensors"
              theme={theme}
            />
            <SettingsItem
              icon="cloud-outline"
              title="Data & Storage"
              theme={theme}
            />
          </View>
        </View>

        {/* Support Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>Support</Text>
          <View style={[
            styles.settingsGroup,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
            }
          ]}>
            <SettingsItem
              icon="help-circle-outline"
              title="Help Center"
              theme={theme}
            />
            <SettingsItem
              icon="chatbubble-outline"
              title="Contact Support"
              theme={theme}
            />
            <SettingsItem
              icon="document-text-outline"
              title="Terms of Service"
              theme={theme}
            />
            <SettingsItem
              icon="lock-closed-outline"
              title="Privacy Policy"
              theme={theme}
            />
          </View>
        </View>

        {/* Sign Out */}
        <View style={styles.section}>
          <TouchableOpacity style={[
            styles.signOutButton,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
            }
          ]}>
            <Ionicons name="log-out-outline" size={20} color={theme.error} />
            <Text style={[styles.signOutText, { color: theme.error }]}>Sign Out</Text>
          </TouchableOpacity>
        </View>

        {/* App Version */}
        <View style={styles.versionContainer}>
          <View style={[styles.logoSmall, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
            <Text style={[styles.logoSmallText, { color: theme.textPrimary }]}>∞</Text>
          </View>
          <Text style={[styles.versionText, { color: theme.textMuted }]}>Endless v1.0.0</Text>
        </View>

        <View style={styles.bottomPadding} />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 24,
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
  },
  section: {
    marginBottom: 28,
    paddingHorizontal: 20,
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: '600',
    textTransform: 'uppercase',
    marginBottom: 10,
    marginLeft: 4,
    letterSpacing: 0.5,
  },
  profileCard: {
    borderRadius: 16,
    padding: 18,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  profileAvatar: {
    width: 58,
    height: 58,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 14,
  },
  profileInitial: {
    fontSize: 24,
    fontWeight: '600',
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    fontSize: 18,
    fontWeight: '600',
  },
  profileEmail: {
    fontSize: 14,
    marginTop: 3,
  },
  settingsGroup: {
    borderRadius: 16,
    borderWidth: 1,
    overflow: 'hidden',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  settingsItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 14,
    borderBottomWidth: 1,
  },
  settingsItemIcon: {
    width: 38,
    height: 38,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 14,
  },
  settingsItemContent: {
    flex: 1,
  },
  settingsItemTitle: {
    fontSize: 15,
    fontWeight: '500',
  },
  settingsItemSubtitle: {
    fontSize: 12,
    marginTop: 2,
  },
  themeBadge: {
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 6,
  },
  themeBadgeText: {
    fontSize: 12,
    fontWeight: '500',
  },
  signOutButton: {
    borderRadius: 14,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
  },
  signOutText: {
    fontSize: 16,
    fontWeight: '500',
    marginLeft: 10,
  },
  versionContainer: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  logoSmall: {
    width: 36,
    height: 36,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
    borderWidth: 1,
  },
  logoSmallText: {
    fontSize: 18,
    fontWeight: '300',
  },
  versionText: {
    fontSize: 12,
  },
  bottomPadding: {
    height: 100,
  },
});
