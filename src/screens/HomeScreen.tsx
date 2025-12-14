import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  FlatList,
  TouchableOpacity,
  Dimensions,
  ImageBackground,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../context/ThemeContext';
import {
  QuickActionCard,
  PlayOfWeekCard,
  SessionCard,
  PerformanceSnapshot,
} from '../components';
import { PlayOfTheWeek, Session } from '../types';

const { width } = Dimensions.get('window');

const mockPlaysOfWeek: PlayOfTheWeek[] = [
  {
    id: '1',
    playerName: 'Henry Kammler',
    playerTitle: 'Class of 2025',
    location: 'San Diego, CA',
  },
  {
    id: '2',
    playerName: 'John Smith',
    playerTitle: 'Class of 2024',
    location: 'Los Angeles, CA',
  },
];

const mockSessions: Session[] = [
  { id: '1', title: 'Oakmont CC', location: 'Oakmont', date: '2 days ago' },
  { id: '2', title: 'Pebble Beach', location: 'Pebble Beach', date: '5 days ago' },
  { id: '3', title: 'Del Mar', location: 'Del Mar', date: '1 week ago' },
];

const navTabs = ['Sessions', 'Team', 'Profile'];

export const HomeScreen: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const [selectedTab, setSelectedTab] = useState(0);

  const currentDate = new Date();
  const formattedDate = currentDate.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  });

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        {/* Hero Header */}
        <View style={styles.heroHeader}>
          <View style={styles.heroTopRow}>
            <TouchableOpacity style={[styles.menuButton, { backgroundColor: theme.cardBackground }]}>
              <Ionicons name="menu" size={22} color={theme.textPrimary} />
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.themeToggle, { backgroundColor: theme.cardBackground }]}
              onPress={toggleTheme}
            >
              <Ionicons
                name={theme.isDark ? 'sunny' : 'moon'}
                size={20}
                color={theme.primary}
              />
            </TouchableOpacity>
          </View>

          <Text style={[styles.heroTitle, { color: theme.textPrimary }]}>
            ALL{'\n'}SESSIONS
          </Text>

          <TouchableOpacity style={styles.standingsButton}>
            <Text style={[styles.standingsText, { color: theme.textSecondary }]}>STANDINGS</Text>
            <Ionicons name="chevron-down" size={16} color={theme.textSecondary} />
          </TouchableOpacity>
        </View>

        {/* Pill Navigation Tabs */}
        <View style={styles.navTabsContainer}>
          <View style={[styles.navTabsWrapper, { backgroundColor: theme.cardBackground }]}>
            {navTabs.map((tab, index) => (
              <TouchableOpacity
                key={tab}
                style={[
                  styles.navTab,
                  selectedTab === index && { backgroundColor: theme.textPrimary },
                ]}
                onPress={() => setSelectedTab(index)}
              >
                <Text
                  style={[
                    styles.navTabText,
                    { color: selectedTab === index ? theme.textInverse : theme.textSecondary },
                  ]}
                >
                  {tab.toUpperCase()}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Featured Session Card */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>UPCOMING SESSION</Text>
          <View style={[styles.featuredCard, { backgroundColor: theme.cardBackground }]}>
            <View style={styles.featuredImagePlaceholder}>
              <LinearGradient
                colors={theme.isDark ? ['#1A3A2E', '#0D1F17'] : ['#D4E5DC', '#A8C5B5']}
                style={styles.featuredGradient}
              >
                <Ionicons name="golf" size={48} color={theme.primary} />
              </LinearGradient>
              <View style={[styles.playByBadge, { backgroundColor: theme.primary }]}>
                <Text style={[styles.playByText, { color: theme.textInverse }]}>PLAY BY MAY 15</Text>
              </View>
            </View>
            <View style={styles.featuredContent}>
              <View style={styles.featuredMeta}>
                <View style={styles.metaItem}>
                  <Ionicons name="calendar" size={14} color={theme.textSecondary} />
                  <Text style={[styles.metaText, { color: theme.textSecondary }]}>May 6</Text>
                </View>
                <View style={styles.metaItem}>
                  <Ionicons name="time" size={14} color={theme.textSecondary} />
                  <Text style={[styles.metaText, { color: theme.textSecondary }]}>09:00</Text>
                </View>
              </View>
              <View style={styles.locationRow}>
                <Ionicons name="location" size={14} color={theme.textSecondary} />
                <Text style={[styles.locationText, { color: theme.textSecondary }]}>
                  Main, Birchwood Park Golf Centre
                </Text>
              </View>
            </View>
            <View style={[styles.divider, { backgroundColor: theme.border }]} />
            <View style={styles.teamSection}>
              <Text style={[styles.teamLabel, { color: theme.textMuted }]}>TEAM 1</Text>
              <View style={styles.playerRow}>
                <View style={[styles.playerAvatar, { backgroundColor: theme.primary }]}>
                  <Text style={[styles.avatarText, { color: theme.textInverse }]}>C</Text>
                </View>
                <View style={styles.playerInfo}>
                  <Text style={[styles.playerName, { color: theme.textPrimary }]}>Craig Roberts</Text>
                  <Text style={[styles.playerHandicap, { color: theme.textSecondary }]}>HCP: 19.2</Text>
                </View>
                <View style={[styles.captainBadge, { backgroundColor: theme.cardBackgroundElevated }]}>
                  <Text style={[styles.captainText, { color: theme.textSecondary }]}>CAPTAIN</Text>
                </View>
              </View>
              <View style={styles.playerRow}>
                <View style={[styles.playerAvatar, { backgroundColor: theme.accentBlue }]}>
                  <Text style={[styles.avatarText, { color: theme.textInverse }]}>D</Text>
                </View>
                <View style={styles.playerInfo}>
                  <Text style={[styles.playerName, { color: theme.textPrimary }]}>Daniel Linch</Text>
                  <Text style={[styles.playerHandicap, { color: theme.textSecondary }]}>HCP: 18.2</Text>
                </View>
              </View>
            </View>
          </View>
        </View>

        {/* Quick Actions */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>QUICK ACTIONS</Text>
          <View style={styles.quickActionsRow}>
            <QuickActionCard
              title="Today's Drills"
              subtitle="5 remaining"
              icon="golf"
            />
            <QuickActionCard
              title="Last Session"
              subtitle="2 days ago"
              icon="time"
            />
            <QuickActionCard
              title="Recruit Views"
              subtitle="12 coaches"
              icon="eye"
            />
          </View>
        </View>

        {/* Plays of the Week */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>PLAYS OF THE WEEK</Text>
          <FlatList
            data={mockPlaysOfWeek}
            horizontal
            showsHorizontalScrollIndicator={false}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => <PlayOfWeekCard play={item} />}
            contentContainerStyle={styles.playsListContainer}
          />
        </View>

        {/* Recent Sessions */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>RECENT SESSIONS</Text>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.sessionsContainer}
          >
            {mockSessions.map((session) => (
              <SessionCard key={session.id} session={session} />
            ))}
          </ScrollView>
        </View>

        {/* Performance Snapshot */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>PERFORMANCE</Text>
          <PerformanceSnapshot />
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
  heroHeader: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 20,
  },
  heroTopRow: {
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
  themeToggle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  heroTitle: {
    fontSize: 52,
    fontWeight: '800',
    letterSpacing: -2,
    lineHeight: 52,
    marginBottom: 12,
  },
  standingsButton: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
  },
  standingsText: {
    fontSize: 13,
    fontWeight: '600',
    letterSpacing: 1,
    marginRight: 4,
  },
  navTabsContainer: {
    paddingHorizontal: 20,
    marginBottom: 28,
  },
  navTabsWrapper: {
    flexDirection: 'row',
    borderRadius: 30,
    padding: 4,
  },
  navTab: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 26,
    alignItems: 'center',
  },
  navTabText: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  section: {
    marginBottom: 32,
    paddingHorizontal: 20,
  },
  sectionLabel: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.5,
    marginBottom: 14,
  },
  featuredCard: {
    borderRadius: 24,
    overflow: 'hidden',
  },
  featuredImagePlaceholder: {
    height: 180,
    position: 'relative',
  },
  featuredGradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playByBadge: {
    position: 'absolute',
    top: 16,
    left: 16,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 14,
  },
  playByText: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  featuredContent: {
    padding: 18,
  },
  featuredMeta: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  metaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 20,
  },
  metaText: {
    fontSize: 13,
    marginLeft: 6,
    fontWeight: '500',
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  locationText: {
    fontSize: 13,
    marginLeft: 6,
  },
  divider: {
    height: 1,
    marginHorizontal: 18,
  },
  teamSection: {
    padding: 18,
  },
  teamLabel: {
    fontSize: 11,
    fontWeight: '600',
    letterSpacing: 1,
    marginBottom: 14,
  },
  playerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  playerAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: {
    fontSize: 16,
    fontWeight: '600',
  },
  playerInfo: {
    flex: 1,
  },
  playerName: {
    fontSize: 15,
    fontWeight: '600',
  },
  playerHandicap: {
    fontSize: 12,
    marginTop: 2,
  },
  captainBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  captainText: {
    fontSize: 10,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  quickActionsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  playsListContainer: {
    paddingRight: 20,
  },
  sessionsContainer: {
    paddingRight: 20,
  },
  bottomPadding: {
    height: 100,
  },
});
