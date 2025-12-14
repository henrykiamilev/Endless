import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  TouchableOpacity,
  Image,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../constants/colors';

interface SettingsItemProps {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  subtitle?: string;
  onPress?: () => void;
  showChevron?: boolean;
}

const SettingsItem: React.FC<SettingsItemProps> = ({
  icon,
  title,
  subtitle,
  onPress,
  showChevron = true,
}) => (
  <TouchableOpacity style={styles.settingsItem} onPress={onPress}>
    <View style={styles.settingsItemIcon}>
      <Ionicons name={icon} size={22} color={Colors.textPrimary} />
    </View>
    <View style={styles.settingsItemContent}>
      <Text style={styles.settingsItemTitle}>{title}</Text>
      {subtitle && <Text style={styles.settingsItemSubtitle}>{subtitle}</Text>}
    </View>
    {showChevron && (
      <Ionicons name="chevron-forward" size={20} color={Colors.textSecondary} />
    )}
  </TouchableOpacity>
);

export const SettingsScreen: React.FC = () => {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Settings</Text>
        </View>

        {/* Profile Section */}
        <View style={styles.section}>
          <TouchableOpacity style={styles.profileCard}>
            <View style={styles.profileAvatar}>
              <Text style={styles.profileInitial}>W</Text>
            </View>
            <View style={styles.profileInfo}>
              <Text style={styles.profileName}>Will Johnson</Text>
              <Text style={styles.profileEmail}>will.johnson@email.com</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color={Colors.textSecondary} />
          </TouchableOpacity>
        </View>

        {/* Account Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Account</Text>
          <View style={styles.settingsGroup}>
            <SettingsItem
              icon="person-outline"
              title="Edit Profile"
              subtitle="Name, photo, bio"
            />
            <SettingsItem
              icon="school-outline"
              title="Recruitment Profile"
              subtitle="Stats, achievements, videos"
            />
            <SettingsItem
              icon="shield-outline"
              title="Privacy & Security"
            />
            <SettingsItem
              icon="notifications-outline"
              title="Notifications"
            />
          </View>
        </View>

        {/* Preferences Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Preferences</Text>
          <View style={styles.settingsGroup}>
            <SettingsItem
              icon="golf-outline"
              title="Golf Settings"
              subtitle="Handicap, home course"
            />
            <SettingsItem
              icon="hardware-chip-outline"
              title="Connected Devices"
              subtitle="Launch monitors, sensors"
            />
            <SettingsItem
              icon="cloud-outline"
              title="Data & Storage"
            />
          </View>
        </View>

        {/* Support Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Support</Text>
          <View style={styles.settingsGroup}>
            <SettingsItem
              icon="help-circle-outline"
              title="Help Center"
            />
            <SettingsItem
              icon="chatbubble-outline"
              title="Contact Support"
            />
            <SettingsItem
              icon="document-text-outline"
              title="Terms of Service"
            />
            <SettingsItem
              icon="lock-closed-outline"
              title="Privacy Policy"
            />
          </View>
        </View>

        {/* Sign Out */}
        <View style={styles.section}>
          <TouchableOpacity style={styles.signOutButton}>
            <Ionicons name="log-out-outline" size={22} color={Colors.error} />
            <Text style={styles.signOutText}>Sign Out</Text>
          </TouchableOpacity>
        </View>

        {/* App Version */}
        <View style={styles.versionContainer}>
          <Text style={styles.versionText}>Golf Recruit App v1.0.0</Text>
        </View>

        <View style={styles.bottomPadding} />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 20,
  },
  title: {
    color: Colors.textPrimary,
    fontSize: 24,
    fontWeight: '700',
  },
  section: {
    marginBottom: 24,
    paddingHorizontal: 16,
  },
  sectionTitle: {
    color: Colors.textSecondary,
    fontSize: 13,
    fontWeight: '600',
    textTransform: 'uppercase',
    marginBottom: 8,
    marginLeft: 4,
  },
  profileCard: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.border,
  },
  profileAvatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  profileInitial: {
    color: Colors.textPrimary,
    fontSize: 24,
    fontWeight: '600',
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    color: Colors.textPrimary,
    fontSize: 18,
    fontWeight: '600',
  },
  profileEmail: {
    color: Colors.textSecondary,
    fontSize: 14,
    marginTop: 2,
  },
  settingsGroup: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: Colors.border,
    overflow: 'hidden',
  },
  settingsItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 14,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  settingsItemIcon: {
    width: 36,
    height: 36,
    borderRadius: 8,
    backgroundColor: Colors.cardBackgroundLight,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  settingsItemContent: {
    flex: 1,
  },
  settingsItemTitle: {
    color: Colors.textPrimary,
    fontSize: 15,
    fontWeight: '500',
  },
  settingsItemSubtitle: {
    color: Colors.textSecondary,
    fontSize: 12,
    marginTop: 2,
  },
  signOutButton: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: Colors.border,
  },
  signOutText: {
    color: Colors.error,
    fontSize: 16,
    fontWeight: '500',
    marginLeft: 8,
  },
  versionContainer: {
    alignItems: 'center',
    paddingVertical: 16,
  },
  versionText: {
    color: Colors.textMuted,
    fontSize: 12,
  },
  bottomPadding: {
    height: 100,
  },
});
