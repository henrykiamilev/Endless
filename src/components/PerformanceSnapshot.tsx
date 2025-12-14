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
          borderColor: theme.border,
          shadowColor: theme.shadowColor,
        }
      ]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={styles.header}>
        <Text style={[styles.title, { color: theme.textPrimary }]}>Performance Snapshot</Text>
        <Ionicons name="chevron-forward" size={20} color={theme.textSecondary} />
      </View>
      <View style={styles.statsRow}>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.accentBlue}20` }]}>
            <Ionicons name="golf" size={18} color={theme.accentBlue} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>72%</Text>
          <Text style={[styles.statLabel, { color: theme.textSecondary }]}>GIR</Text>
        </View>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.accentGreen}20` }]}>
            <Ionicons name="flag" size={18} color={theme.accentGreen} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>65%</Text>
          <Text style={[styles.statLabel, { color: theme.textSecondary }]}>FIR</Text>
        </View>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.accentYellow}20` }]}>
            <Ionicons name="ellipse" size={18} color={theme.accentYellow} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>28.4</Text>
          <Text style={[styles.statLabel, { color: theme.textSecondary }]}>Putts</Text>
        </View>
        <View style={styles.statItem}>
          <View style={[styles.iconBg, { backgroundColor: `${theme.primary}20` }]}>
            <Ionicons name="trophy" size={18} color={theme.primary} />
          </View>
          <Text style={[styles.statValue, { color: theme.textPrimary }]}>71.3</Text>
          <Text style={[styles.statLabel, { color: theme.textSecondary }]}>Avg</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 16,
    padding: 18,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 18,
  },
  title: {
    fontSize: 17,
    fontWeight: '600',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  statItem: {
    alignItems: 'center',
  },
  iconBg: {
    width: 36,
    height: 36,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statValue: {
    fontSize: 20,
    fontWeight: '700',
    marginTop: 8,
  },
  statLabel: {
    fontSize: 12,
    marginTop: 2,
  },
});
