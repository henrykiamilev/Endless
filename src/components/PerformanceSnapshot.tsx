import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';

interface PerformanceSnapshotProps {
  onPress?: () => void;
}

export const PerformanceSnapshot: React.FC<PerformanceSnapshotProps> = ({ onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity
      style={[
        styles.container,
        {
          backgroundColor: theme.cardBackground,
        }
      ]}
      onPress={onPress}
      activeOpacity={0.85}
    >
      <View style={styles.header}>
        <Text style={[styles.title, { color: theme.textPrimary }]}>Performance Snapshot</Text>
        <View style={[styles.viewButton, { backgroundColor: `${theme.primary}15` }]}>
          <Text style={[styles.viewButtonText, { color: theme.primary }]}>VIEW ALL</Text>
        </View>
      </View>
      <View style={styles.statsRow}>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.accentBlue}15` }]}>
            <Ionicons name="golf" size={20} color={theme.accentBlue} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>72%</Text>
          <Text style={[styles.statLabel, { color: theme.textMuted }]}>GIR</Text>
        </View>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.accentGreen}15` }]}>
            <Ionicons name="flag" size={20} color={theme.accentGreen} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>65%</Text>
          <Text style={[styles.statLabel, { color: theme.textMuted }]}>FIR</Text>
        </View>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.accentYellow}15` }]}>
            <Ionicons name="ellipse" size={20} color={theme.accentYellow} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>28.4</Text>
          <Text style={[styles.statLabel, { color: theme.textMuted }]}>Putts</Text>
        </View>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.primary}15` }]}>
            <Ionicons name="trophy" size={20} color={theme.primary} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>71.3</Text>
          <Text style={[styles.statLabel, { color: theme.textMuted }]}>Avg</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 24,
    padding: 22,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 22,
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
  },
  viewButton: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 14,
  },
  viewButtonText: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  statItem: {
    alignItems: 'center',
  },
  iconBg: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statValue: {
    fontSize: 22,
    fontWeight: '800',
    marginTop: 10,
  },
  statLabel: {
    fontSize: 11,
    fontWeight: '600',
    marginTop: 3,
    letterSpacing: 0.3,
  },
});
