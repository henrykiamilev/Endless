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
import { Colors } from '../constants/colors';
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
        <Text style={styles.filterText}>Showing matches from October 2025</Text>
        <TouchableOpacity style={styles.filterButton}>
          <Ionicons name="options" size={20} color={Colors.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Match Videos Section */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Match Videos</Text>
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
        <Text style={styles.sectionTitle}>Recent Round Stats</Text>
        <View style={styles.statsCard}>
          <StatBar label="Greens in Regulation" value="72" percentage={72} />
          <StatBar label="Fairways Hit" value="65" percentage={65} />
          <StatBar label="Avg Putts per Round" value="28.4" percentage={71} />
          <StatBar label="Scoring Average" value="71.3" percentage={90} showPercentageBar={false} />
        </View>
      </View>

      {/* Launch Monitor Data */}
      <View style={styles.statsSection}>
        <Text style={styles.sectionTitle}>Launch Monitor Data</Text>
        <View style={styles.launchMonitorCard}>
          <Text style={styles.launchMonitorText}>
            Connect your launch monitor to track club data
          </Text>
          <TouchableOpacity style={styles.connectButton}>
            <Text style={styles.connectButtonText}>Connect GCQuad</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Round History */}
      <View style={styles.statsSection}>
        <Text style={styles.sectionTitle}>Round History</Text>
        <View style={styles.roundHistoryCard}>
          {mockRoundHistory.map((round) => (
            <RoundHistoryCard key={round.id} round={round} />
          ))}
        </View>
      </View>

      <View style={styles.bottomPadding} />
    </ScrollView>
  );

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <Text style={styles.title}>Video Library</Text>
          <TouchableOpacity style={styles.profileButton}>
            <Text style={styles.profileInitial}>W</Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.dateText}>{formattedDate}</Text>
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
    backgroundColor: Colors.background,
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 16,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    color: Colors.textPrimary,
    fontSize: 24,
    fontWeight: '700',
  },
  profileButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  profileInitial: {
    color: Colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },
  dateText: {
    color: Colors.textSecondary,
    fontSize: 14,
    marginTop: 4,
  },
  toggleContainer: {
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  content: {
    flex: 1,
    paddingHorizontal: 16,
  },
  filterHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  filterText: {
    color: Colors.textSecondary,
    fontSize: 13,
  },
  filterButton: {
    padding: 8,
  },
  sectionHeader: {
    marginBottom: 12,
  },
  sectionTitle: {
    color: Colors.textPrimary,
    fontSize: 18,
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
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 16,
    marginTop: 12,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  launchMonitorCard: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 16,
    marginTop: 12,
    borderWidth: 1,
    borderColor: Colors.border,
    alignItems: 'center',
  },
  launchMonitorText: {
    color: Colors.textSecondary,
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 12,
  },
  connectButton: {
    backgroundColor: Colors.cardBackgroundLight,
    paddingVertical: 10,
    paddingHorizontal: 24,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  connectButtonText: {
    color: Colors.textPrimary,
    fontSize: 14,
    fontWeight: '500',
  },
  roundHistoryCard: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 16,
    marginTop: 12,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  bottomPadding: {
    height: 100,
  },
});
