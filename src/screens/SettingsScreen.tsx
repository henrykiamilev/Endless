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
    activeOpacity={0.7}
  >
    <View style={[styles.settingsItemIcon, { backgroundColor: `${theme.primary}15` }]}>
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
          <View style={styles.headerTop}>
            <TouchableOpacity style={[styles.menuButton, { backgroundColor: theme.cardBackground }]}>
              <Ionicons name="menu" size={22} color={theme.textPrimary} />
            </TouchableOpacity>
          </View>
          <Text style={[styles.heroTitle, { color: theme.textPrimary }]}>
            SETTINGS
          </Text>
        </View>

        {/* Profile Section */}
        <View style={styles.section}>
          <TouchableOpacity style={[
            styles.profileCard,
            { backgroundColor: theme.cardBackground }
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
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>APPEARANCE</Text>
          <View style={[styles.settingsGroup, { backgroundColor: theme.cardBackground }]}>
            <TouchableOpacity
              style={[styles.settingsItem, { borderBottomColor: theme.border }]}
              onPress={toggleTheme}
              activeOpacity={0.7}
            >
              <View style={[styles.settingsItemIcon, { backgroundColor: `${theme.primary}15` }]}>
                <Ionicons name={theme.isDark ? 'moon' : 'sunny'} size={20} color={theme.primary} />
              </View>
              <View style={styles.settingsItemContent}>
                <Text style={[styles.settingsItemTitle, { color: theme.textPrimary }]}>Theme</Text>
                <Text style={[styles.settingsItemSubtitle, { color: theme.textSecondary }]}>
                  {theme.isDark ? 'Dark mode' : 'Light mode'}
                </Text>
              </View>
              <View style={[styles.themeBadge, { backgroundColor: theme.backgroundSecondary }]}>
                <Text style={[styles.themeBadgeText, { color: theme.textSecondary }]}>
                  {theme.isDark ? 'DARK' : 'LIGHT'}
                </Text>
              </View>
            </TouchableOpacity>
          </View>
        </View>

        {/* Account Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>ACCOUNT</Text>
          <View style={[styles.settingsGroup, { backgroundColor: theme.cardBackground }]}>
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
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>PREFERENCES</Text>
          <View style={[styles.settingsGroup, { backgroundColor: theme.cardBackground }]}>
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
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>SUPPORT</Text>
          <View style={[styles.settingsGroup, { backgroundColor: theme.cardBackground }]}>
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
            { backgroundColor: theme.cardBackground }
          ]}>
            <Ionicons name="log-out-outline" size={20} color={theme.error} />
            <Text style={[styles.signOutText, { color: theme.error }]}>Sign Out</Text>
          </TouchableOpacity>
        </View>

        {/* App Version */}
        <View style={styles.versionContainer}>
          <View style={[styles.logoSmall, { backgroundColor: theme.cardBackground }]}>
            <Text style={[styles.logoSmallText, { color: theme.primary }]}>∞</Text>
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
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  menuButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  heroTitle: {
    fontSize: 48,
    fontWeight: '800',
    letterSpacing: -2,
  },
  section: {
    marginBottom: 28,
    paddingHorizontal: 20,
  },
  sectionLabel: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.5,
    marginBottom: 14,
    marginLeft: 4,
  },
  profileCard: {
    borderRadius: 20,
    padding: 18,
    flexDirection: 'row',
    alignItems: 'center',
  },
  profileAvatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  profileInitial: {
    fontSize: 24,
    fontWeight: '700',
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    fontSize: 18,
    fontWeight: '700',
  },
  profileEmail: {
    fontSize: 14,
    marginTop: 4,
  },
  settingsGroup: {
    borderRadius: 20,
    overflow: 'hidden',
  },
  settingsItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
  },
  settingsItemIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 14,
  },
  settingsItemContent: {
    flex: 1,
  },
  settingsItemTitle: {
    fontSize: 15,
    fontWeight: '600',
  },
  settingsItemSubtitle: {
    fontSize: 12,
    marginTop: 3,
  },
  themeBadge: {
    paddingVertical: 5,
    paddingHorizontal: 12,
    borderRadius: 10,
  },
  themeBadgeText: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  signOutButton: {
    borderRadius: 20,
    padding: 18,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  signOutText: {
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 10,
  },
  versionContainer: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  logoSmall: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  logoSmallText: {
    fontSize: 22,
    fontWeight: '300',
  },
  versionText: {
    fontSize: 12,
    fontWeight: '500',
  },
  bottomPadding: {
    height: 120,
  },
});
