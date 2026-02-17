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
  TextInput,
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
        {/* Modern Header with Greeting */}
        <View style={styles.header}>
          <View style={styles.headerRow}>
            <View style={styles.headerLeft}>
              <TouchableOpacity style={[styles.menuButton, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
                <Ionicons name="menu" size={20} color={theme.textPrimary} />
              </TouchableOpacity>
            </View>
            <View style={styles.headerRight}>
              <TouchableOpacity
                style={[styles.iconButton, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}
                onPress={toggleTheme}
              >
                <Ionicons
                  name={theme.isDark ? 'sunny' : 'moon'}
                  size={18}
                  color={theme.primary}
                />
              </TouchableOpacity>
              <TouchableOpacity style={[styles.avatarButton, { backgroundColor: theme.primary }]}>
                <Text style={[styles.avatarText, { color: theme.textInverse }]}>W</Text>
              </TouchableOpacity>
            </View>
          </View>
          <View style={styles.greetingSection}>
            <Text style={[styles.greeting, { color: theme.textMuted }]}>
              {formattedDate}
            </Text>
            <Text style={[styles.greetingName, { color: theme.textPrimary }]}>
              Hello, Will
            </Text>
          </View>
        </View>

        {/* Search Bar */}
        <View style={styles.searchContainer}>
          <View style={[styles.searchBar, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
            <Ionicons name="search" size={20} color={theme.textMuted} />
            <TextInput
              style={[styles.searchInput, { color: theme.textPrimary }]}
              placeholder="Search courses, sessions..."
              placeholderTextColor={theme.textMuted}
            />
            <TouchableOpacity style={[styles.searchFilterBtn, { backgroundColor: theme.primary }]}>
              <Ionicons name="options-outline" size={16} color={theme.textInverse} />
            </TouchableOpacity>
          </View>
        </View>

        {/* Pill Navigation Tabs */}
        <View style={styles.navTabsContainer}>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.navTabsScroll}>
            {navTabs.map((tab, index) => (
              <TouchableOpacity
                key={tab}
                style={[
                  styles.navTab,
                  { backgroundColor: theme.cardBackground, borderColor: theme.border },
                  selectedTab === index && { backgroundColor: theme.primary, borderColor: theme.primary },
                ]}
                onPress={() => setSelectedTab(index)}
              >
                <Text
                  style={[
                    styles.navTabText,
                    { color: theme.textSecondary },
                    selectedTab === index && { color: theme.textInverse },
                  ]}
                >
                  {tab}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Featured Session Card */}
        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Upcoming Session</Text>
            <TouchableOpacity>
              <Text style={[styles.seeAll, { color: theme.primary }]}>See all</Text>
            </TouchableOpacity>
          </View>
          <View style={[styles.featuredCard, { backgroundColor: theme.cardBackground }]}>
            <View style={styles.featuredImagePlaceholder}>
              <LinearGradient
                colors={theme.isDark ? ['#1A3A2E', '#0D1F17'] : ['#D4E5DC', '#A8C5B5']}
                style={styles.featuredGradient}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
              >
                <Ionicons name="golf" size={44} color={theme.primary} style={{ opacity: 0.4 }} />
              </LinearGradient>
              <View style={[styles.playByBadge, { backgroundColor: 'rgba(0,0,0,0.55)' }]}>
                <Text style={styles.playByText}>PLAY BY MAY 15</Text>
              </View>
              <View style={styles.featuredDateOverlay}>
                <View style={[styles.featuredDateBadge, { backgroundColor: 'rgba(0,0,0,0.55)' }]}>
                  <Ionicons name="calendar-outline" size={12} color="#FFFFFF" />
                  <Text style={styles.featuredDateText}>May 6 at 09:00</Text>
                </View>
              </View>
            </View>
            <View style={styles.featuredContent}>
              <View style={styles.featuredRow}>
                <View>
                  <Text style={[styles.featuredName, { color: theme.textPrimary }]}>Birchwood Park</Text>
                  <View style={styles.locationRow}>
                    <Ionicons name="location-outline" size={14} color={theme.textMuted} />
                    <Text style={[styles.locationText, { color: theme.textMuted }]}>
                      Main Course, Birchwood
                    </Text>
                  </View>
                </View>
              </View>
              <View style={[styles.divider, { backgroundColor: theme.border }]} />
              <View style={styles.teamSection}>
                <View style={styles.playerRow}>
                  <View style={[styles.playerAvatar, { backgroundColor: theme.primary }]}>
                    <Text style={[styles.playerAvatarText, { color: theme.textInverse }]}>C</Text>
                  </View>
                  <View style={styles.playerInfo}>
                    <Text style={[styles.playerName, { color: theme.textPrimary }]}>Craig Roberts</Text>
                    <Text style={[styles.playerHandicap, { color: theme.textMuted }]}>HCP: 19.2</Text>
                  </View>
                  <View style={[styles.captainBadge, { backgroundColor: `${theme.primary}15` }]}>
                    <Text style={[styles.captainText, { color: theme.primary }]}>CAPTAIN</Text>
                  </View>
                </View>
                <View style={[styles.playerRow, { marginBottom: 0 }]}>
                  <View style={[styles.playerAvatar, { backgroundColor: theme.accentBlue }]}>
                    <Text style={[styles.playerAvatarText, { color: '#FFFFFF' }]}>D</Text>
                  </View>
                  <View style={styles.playerInfo}>
                    <Text style={[styles.playerName, { color: theme.textPrimary }]}>Daniel Linch</Text>
                    <Text style={[styles.playerHandicap, { color: theme.textMuted }]}>HCP: 18.2</Text>
                  </View>
                </View>
              </View>
            </View>
          </View>
        </View>

        {/* Quick Actions */}
        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Quick Actions</Text>
          </View>
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
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Plays of the Week</Text>
            <TouchableOpacity>
              <Text style={[styles.seeAll, { color: theme.primary }]}>See all</Text>
            </TouchableOpacity>
          </View>
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
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Recent Sessions</Text>
            <TouchableOpacity>
              <Text style={[styles.seeAll, { color: theme.primary }]}>See all</Text>
            </TouchableOpacity>
          </View>
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
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Performance</Text>
            <TouchableOpacity>
              <Text style={[styles.seeAll, { color: theme.primary }]}>View all</Text>
            </TouchableOpacity>
          </View>
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
  header: {
    paddingHorizontal: 24,
    paddingTop: 8,
    paddingBottom: 4,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  menuButton: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
  },
  iconButton: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
  },
  avatarButton: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 17,
    fontWeight: '700',
  },
  greetingSection: {
    marginBottom: 4,
  },
  greeting: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 4,
  },
  greetingName: {
    fontSize: 28,
    fontWeight: '700',
    letterSpacing: -0.5,
  },
  searchContainer: {
    paddingHorizontal: 24,
    marginBottom: 20,
    marginTop: 16,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 16,
    paddingHorizontal: 16,
    height: 52,
    borderWidth: 1,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    marginLeft: 12,
    fontWeight: '400',
  },
  searchFilterBtn: {
    width: 34,
    height: 34,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  navTabsContainer: {
    marginBottom: 24,
  },
  navTabsScroll: {
    paddingHorizontal: 24,
    gap: 10,
  },
  navTab: {
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 12,
    borderWidth: 1,
  },
  navTabText: {
    fontSize: 14,
    fontWeight: '600',
  },
  section: {
    marginBottom: 28,
    paddingHorizontal: 24,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    letterSpacing: -0.3,
  },
  seeAll: {
    fontSize: 14,
    fontWeight: '600',
  },
  featuredCard: {
    borderRadius: 20,
    overflow: 'hidden',
  },
  featuredImagePlaceholder: {
    height: 170,
    position: 'relative',
  },
  featuredGradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playByBadge: {
    position: 'absolute',
    top: 14,
    left: 14,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 10,
  },
  playByText: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.5,
    color: '#FFFFFF',
  },
  featuredDateOverlay: {
    position: 'absolute',
    bottom: 14,
    right: 14,
  },
  featuredDateBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 8,
    gap: 5,
  },
  featuredDateText: {
    fontSize: 11,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  featuredContent: {
    padding: 18,
  },
  featuredRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  featuredName: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 5,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  locationText: {
    fontSize: 13,
    fontWeight: '400',
  },
  divider: {
    height: 1,
    marginVertical: 14,
  },
  teamSection: {},
  playerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  playerAvatar: {
    width: 38,
    height: 38,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  playerAvatarText: {
    fontSize: 15,
    fontWeight: '600',
  },
  playerInfo: {
    flex: 1,
  },
  playerName: {
    fontSize: 14,
    fontWeight: '600',
  },
  playerHandicap: {
    fontSize: 12,
    marginTop: 2,
  },
  captainBadge: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 8,
  },
  captainText: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.3,
  },
  quickActionsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 10,
  },
  playsListContainer: {
    paddingRight: 24,
  },
  sessionsContainer: {
    paddingRight: 24,
  },
  bottomPadding: {
    height: 100,
  },
});
