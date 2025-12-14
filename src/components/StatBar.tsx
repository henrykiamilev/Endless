import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useTheme } from '../context/ThemeContext';

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
  const { theme } = useTheme();

  return (
    <View style={styles.container}>
      <View style={styles.labelRow}>
        <Text style={[styles.label, { color: theme.textSecondary }]}>{label}</Text>
        <Text style={[styles.value, { color: theme.textPrimary }]}>
          {value}{typeof value === 'number' && percentage !== undefined ? '%' : ''}
        </Text>
      </View>
      {showPercentageBar && percentage !== undefined && (
        <View style={[styles.barContainer, { backgroundColor: theme.cardBackgroundElevated }]}>
          <View style={[styles.bar, { width: `${percentage}%`, backgroundColor: theme.primary }]} />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 18,
  },
  labelRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  label: {
    fontSize: 14,
  },
  value: {
    fontSize: 17,
    fontWeight: '700',
  },
  barContainer: {
    height: 6,
    borderRadius: 3,
  },
  bar: {
    height: '100%',
    borderRadius: 3,
  },
});
