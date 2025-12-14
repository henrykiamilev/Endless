import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../constants/colors';

interface PerformanceSnapshotProps {
  onPress?: () => void;
}

export const PerformanceSnapshot: React.FC<PerformanceSnapshotProps> = ({ onPress }) => {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <View style={styles.header}>
        <Text style={styles.title}>Performance Snapshot</Text>
        <Ionicons name="chevron-forward" size={20} color={Colors.textSecondary} />
      </View>
      <View style={styles.statsRow}>
        <View style={styles.statItem}>
          <Ionicons name="golf" size={20} color={Colors.accent} />
          <Text style={styles.statValue}>72%</Text>
          <Text style={styles.statLabel}>GIR</Text>
        </View>
        <View style={styles.statItem}>
          <Ionicons name="flag" size={20} color={Colors.accentGreen} />
          <Text style={styles.statValue}>65%</Text>
          <Text style={styles.statLabel}>FIR</Text>
        </View>
        <View style={styles.statItem}>
          <Ionicons name="ellipse" size={20} color={Colors.accentYellow} />
          <Text style={styles.statValue}>28.4</Text>
          <Text style={styles.statLabel}>Putts</Text>
        </View>
        <View style={styles.statItem}>
          <Ionicons name="trophy" size={20} color={Colors.primary} />
          <Text style={styles.statValue}>71.3</Text>
          <Text style={styles.statLabel}>Avg</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  title: {
    color: Colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  statItem: {
    alignItems: 'center',
  },
  statValue: {
    color: Colors.textPrimary,
    fontSize: 18,
    fontWeight: '700',
    marginTop: 8,
  },
  statLabel: {
    color: Colors.textSecondary,
    fontSize: 11,
    marginTop: 2,
  },
});
