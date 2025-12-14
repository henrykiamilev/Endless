import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  FlatList,
} from 'react-native';
import { Colors } from '../constants/colors';
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
  const currentDate = new Date();
  const formattedDate = currentDate.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.welcomeText}>Welcome back, Will</Text>
          <Text style={styles.dateText}>{formattedDate}</Text>
        </View>

        {/* Quick Actions */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Quick Actions</Text>
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
          <Text style={styles.sectionTitle}>Plays of the Week</Text>
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
          <Text style={styles.sectionTitle}>Recent Sessions</Text>
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
  welcomeText: {
    color: Colors.textPrimary,
    fontSize: 24,
    fontWeight: '700',
  },
  dateText: {
    color: Colors.textSecondary,
    fontSize: 14,
    marginTop: 4,
  },
  section: {
    marginBottom: 24,
    paddingHorizontal: 16,
  },
  sectionTitle: {
    color: Colors.textPrimary,
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  quickActionsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  playsListContainer: {
    paddingRight: 16,
  },
  sessionsContainer: {
    paddingRight: 16,
  },
  bottomPadding: {
    height: 100,
  },
});
