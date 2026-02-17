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

  const renderVideoTab = () => (
    <ScrollView showsVerticalScrollIndicator={false}>
      {/* Filter Header */}
      <View style={styles.filterHeader}>
        <Text style={[styles.filterText, { color: theme.textMuted }]}>Showing matches from October 2025</Text>
        <TouchableOpacity style={[styles.filterButton, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
          <Ionicons name="options" size={18} color={theme.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Match Videos Section */}
      <View style={styles.sectionHeader}>
        <View style={styles.sectionHeaderRow}>
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Match Videos</Text>
          <TouchableOpacity>
            <Text style={[styles.seeAll, { color: theme.primary }]}>See all</Text>
          </TouchableOpacity>
        </View>
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
        <View style={styles.sectionHeaderRow}>
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Recent Round Stats</Text>
        </View>
        <View style={[styles.statsCard, { backgroundColor: theme.cardBackground }]}>
          <StatBar label="Greens in Regulation" value="72" percentage={72} />
          <StatBar label="Fairways Hit" value="65" percentage={65} />
          <StatBar label="Avg Putts per Round" value="28.4" percentage={71} />
          <StatBar label="Scoring Average" value="71.3" percentage={90} showPercentageBar={false} />
        </View>
      </View>

      {/* Launch Monitor Data */}
      <View style={styles.statsSection}>
        <View style={styles.sectionHeaderRow}>
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Launch Monitor</Text>
        </View>
        <View style={[styles.launchMonitorCard, { backgroundColor: theme.cardBackground }]}>
          <View style={[styles.launchMonitorIcon, { backgroundColor: `${theme.primary}15` }]}>
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
        <View style={styles.sectionHeaderRow}>
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Round History</Text>
          <TouchableOpacity>
            <Text style={[styles.seeAll, { color: theme.primary }]}>See all</Text>
          </TouchableOpacity>
        </View>
        <View style={[styles.roundHistoryCard, { backgroundColor: theme.cardBackground }]}>
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
          <TouchableOpacity style={[styles.menuButton, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
            <Ionicons name="menu" size={20} color={theme.textPrimary} />
          </TouchableOpacity>
          <TouchableOpacity style={[styles.profileButton, { backgroundColor: theme.primary }]}>
            <Text style={[styles.profileInitial, { color: theme.textInverse }]}>W</Text>
          </TouchableOpacity>
        </View>
        <Text style={[styles.screenTitle, { color: theme.textPrimary }]}>
          Video Library
        </Text>
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
    paddingHorizontal: 24,
    paddingTop: 8,
    paddingBottom: 16,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  menuButton: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
  },
  screenTitle: {
    fontSize: 28,
    fontWeight: '700',
    letterSpacing: -0.5,
  },
  profileButton: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },
  profileInitial: {
    fontSize: 17,
    fontWeight: '700',
  },
  toggleContainer: {
    paddingHorizontal: 24,
    marginBottom: 20,
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
  },
  filterHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  filterText: {
    fontSize: 13,
    fontWeight: '500',
  },
  filterButton: {
    padding: 10,
    borderRadius: 12,
    borderWidth: 1,
  },
  sectionHeader: {
    marginBottom: 4,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
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
  videosGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  statsSection: {
    marginBottom: 24,
  },
  statsCard: {
    borderRadius: 18,
    padding: 20,
  },
  launchMonitorCard: {
    borderRadius: 18,
    padding: 28,
    alignItems: 'center',
  },
  launchMonitorIcon: {
    width: 64,
    height: 64,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  launchMonitorText: {
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 20,
    lineHeight: 20,
  },
  connectButton: {
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 14,
  },
  connectButtonText: {
    fontSize: 14,
    fontWeight: '600',
  },
  roundHistoryCard: {
    borderRadius: 18,
    padding: 18,
  },
  bottomPadding: {
    height: 100,
  },
});
