import React, { useState } from 'react';
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
import { ToggleButton, VideoCard, StatBar, RoundHistoryCard } from '../components';
import { Video, RoundHistory } from '../types';

const mockVideos: Video[] = [
  { id: '1', title: 'Oakmont CC', date: '10/15/25', duration: '2:34' },
  { id: '2', title: 'Pebble Beach', date: '10/10/25', duration: '3:12' },
  { id: '3', title: 'Del Mar', date: '10/05/25', duration: '1:45' },
  { id: '4', title: 'Torrey Pines', date: '10/01/25', duration: '2:58' },
];

const mockRoundHistory: RoundHistory[] = [
  { id: '1', course: 'Oakmont CC', date: '10/15/25', score: 72 },
  { id: '2', course: 'Pebble Beach', date: '10/10/25', score: 72 },
  { id: '3', course: 'Del Mar', date: '10/05/25', score: 74 },
  { id: '4', course: 'Torrey Pines', date: '10/01/25', score: 71 },
];

export const VideoLibraryScreen: React.FC = () => {
  const { theme } = useTheme();
  const [selectedTab, setSelectedTab] = useState(0);

  const currentDate = new Date();
  const formattedDate = currentDate.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  });

  const renderVideoTab = () => (
    <ScrollView showsVerticalScrollIndicator={false}>
      {/* Filter Header */}
      <View style={styles.filterHeader}>
        <Text style={[styles.filterText, { color: theme.textSecondary }]}>Showing matches from October 2025</Text>
        <TouchableOpacity style={[styles.filterButton, { backgroundColor: theme.cardBackground }]}>
          <Ionicons name="options" size={18} color={theme.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Match Videos Section */}
      <View style={styles.sectionHeader}>
        <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Match Videos</Text>
      </View>

      <View style={styles.videosGrid}>
        {mockVideos.map((video) => (
          <VideoCard key={video.id} video={video} />
        ))}
      </View>

      <View style={styles.bottomPadding} />
    </ScrollView>
  );

  const renderStatsTab = () => (
    <ScrollView showsVerticalScrollIndicator={false}>
      {/* Recent Round Stats */}
      <View style={styles.statsSection}>
        <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Recent Round Stats</Text>
        <View style={[
          styles.statsCard,
          {
            backgroundColor: theme.cardBackground,
            borderColor: theme.border,
            shadowColor: theme.shadowColor,
          }
        ]}>
          <StatBar label="Greens in Regulation" value="72" percentage={72} />
          <StatBar label="Fairways Hit" value="65" percentage={65} />
          <StatBar label="Avg Putts per Round" value="28.4" percentage={71} />
          <StatBar label="Scoring Average" value="71.3" percentage={90} showPercentageBar={false} />
        </View>
      </View>

      {/* Launch Monitor Data */}
      <View style={styles.statsSection}>
        <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Launch Monitor Data</Text>
        <View style={[
          styles.launchMonitorCard,
          {
            backgroundColor: theme.cardBackground,
            borderColor: theme.border,
            shadowColor: theme.shadowColor,
          }
        ]}>
          <View style={[styles.launchMonitorIcon, { backgroundColor: `${theme.primary}20` }]}>
            <Ionicons name="hardware-chip" size={28} color={theme.primary} />
          </View>
          <Text style={[styles.launchMonitorText, { color: theme.textSecondary }]}>
            Connect your launch monitor to track club data
          </Text>
          <TouchableOpacity style={[styles.connectButton, { backgroundColor: theme.primary }]}>
            <Text style={[styles.connectButtonText, { color: theme.textInverse }]}>Connect GCQuad</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Round History */}
      <View style={styles.statsSection}>
        <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Round History</Text>
        <View style={[
          styles.roundHistoryCard,
          {
            backgroundColor: theme.cardBackground,
            borderColor: theme.border,
            shadowColor: theme.shadowColor,
          }
        ]}>
          {mockRoundHistory.map((round) => (
            <RoundHistoryCard key={round.id} round={round} />
          ))}
        </View>
      </View>

      <View style={styles.bottomPadding} />
    </ScrollView>
  );

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View>
            <Text style={[styles.title, { color: theme.textPrimary }]}>Video Library</Text>
            <Text style={[styles.dateText, { color: theme.textSecondary }]}>{formattedDate}</Text>
          </View>
          <TouchableOpacity style={[styles.profileButton, { backgroundColor: theme.primary }]}>
            <Text style={[styles.profileInitial, { color: theme.textInverse }]}>W</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Toggle */}
      <View style={styles.toggleContainer}>
        <ToggleButton
          options={['Video', 'Stats']}
          selectedIndex={selectedTab}
          onSelect={setSelectedTab}
        />
      </View>

      {/* Content */}
      <View style={styles.content}>
        {selectedTab === 0 ? renderVideoTab() : renderStatsTab()}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 20,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
  },
  profileButton: {
    width: 40,
    height: 40,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  profileInitial: {
    fontSize: 17,
    fontWeight: '600',
  },
  dateText: {
    fontSize: 13,
    marginTop: 4,
  },
  toggleContainer: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  content: {
    flex: 1,
    paddingHorizontal: 20,
  },
  filterHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 18,
  },
  filterText: {
    fontSize: 13,
  },
  filterButton: {
    padding: 8,
    borderRadius: 8,
  },
  sectionHeader: {
    marginBottom: 14,
  },
  sectionTitle: {
    fontSize: 19,
    fontWeight: '700',
  },
  videosGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  statsSection: {
    marginBottom: 28,
  },
  statsCard: {
    borderRadius: 16,
    padding: 18,
    marginTop: 14,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  launchMonitorCard: {
    borderRadius: 16,
    padding: 24,
    marginTop: 14,
    borderWidth: 1,
    alignItems: 'center',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  launchMonitorIcon: {
    width: 56,
    height: 56,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 14,
  },
  launchMonitorText: {
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 16,
    lineHeight: 20,
  },
  connectButton: {
    paddingVertical: 12,
    paddingHorizontal: 28,
    borderRadius: 10,
  },
  connectButtonText: {
    fontSize: 15,
    fontWeight: '600',
  },
  roundHistoryCard: {
    borderRadius: 16,
    padding: 16,
    marginTop: 14,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  bottomPadding: {
    height: 100,
  },
});
