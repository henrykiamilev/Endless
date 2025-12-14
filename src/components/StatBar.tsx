import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors } from '../constants/colors';

interface StatBarProps {
  label: string;
  value: string | number;
  percentage?: number;
  showPercentageBar?: boolean;
}

export const StatBar: React.FC<StatBarProps> = ({
  label,
  value,
  percentage,
  showPercentageBar = true
}) => {
  return (
    <View style={styles.container}>
      <View style={styles.labelRow}>
        <Text style={styles.label}>{label}</Text>
        <Text style={styles.value}>{value}{typeof value === 'number' && percentage !== undefined ? '%' : ''}</Text>
      </View>
      {showPercentageBar && percentage !== undefined && (
        <View style={styles.barContainer}>
          <View style={[styles.bar, { width: `${percentage}%` }]} />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  labelRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  label: {
    color: Colors.textSecondary,
    fontSize: 14,
  },
  value: {
    color: Colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },
  barContainer: {
    height: 4,
    backgroundColor: Colors.cardBackgroundLight,
    borderRadius: 2,
  },
  bar: {
    height: '100%',
    backgroundColor: Colors.accent,
    borderRadius: 2,
  },
});
