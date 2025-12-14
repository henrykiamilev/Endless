import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  FlatList,
  TouchableOpacity,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import {
  QuickActionCard,
  PlayOfWeekCard,
  SessionCard,
  PerformanceSnapshot,
} from '../components';
import { PlayOfTheWeek, Session } from '../types';

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

export const HomeScreen: React.FC = () => {
  const { theme, toggleTheme } = useTheme();

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
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerTop}>
            <View style={styles.headerLeft}>
              <View style={[styles.logoContainer, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
                <Text style={[styles.logoText, { color: theme.textPrimary }]}>∞</Text>
              </View>
              <View>
                <Text style={[styles.welcomeText, { color: theme.textPrimary }]}>Welcome back, Will</Text>
                <Text style={[styles.dateText, { color: theme.textSecondary }]}>{formattedDate}</Text>
              </View>
            </View>
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
        </View>

        {/* Quick Actions */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Quick Actions</Text>
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
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Plays of the Week</Text>
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
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Recent Sessions</Text>
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
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 24,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logoContainer: {
    width: 44,
    height: 44,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
    borderWidth: 1,
  },
  logoText: {
    fontSize: 24,
    fontWeight: '300',
  },
  welcomeText: {
    fontSize: 20,
    fontWeight: '700',
  },
  dateText: {
    fontSize: 13,
    marginTop: 2,
  },
  themeToggle: {
    width: 40,
    height: 40,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  section: {
    marginBottom: 28,
    paddingHorizontal: 20,
  },
  sectionTitle: {
    fontSize: 19,
    fontWeight: '700',
    marginBottom: 14,
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
