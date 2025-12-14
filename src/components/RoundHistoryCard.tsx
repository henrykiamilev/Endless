import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { RoundHistory } from '../types';

interface RoundHistoryCardProps {
  round: RoundHistory;
  onPress?: () => void;
}

export const RoundHistoryCard: React.FC<RoundHistoryCardProps> = ({ round, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity
      style={[styles.container, { borderBottomColor: theme.border }]}
      onPress={onPress}
      activeOpacity={0.6}
    >
      <View style={styles.leftContent}>
        <Text style={[styles.course, { color: theme.textPrimary }]}>{round.course}</Text>
        <Text style={[styles.date, { color: theme.textSecondary }]}>{round.date}</Text>
      </View>
      <View style={styles.rightContent}>
        <Text style={[styles.score, { color: theme.primary }]}>{round.score}</Text>
        <Ionicons name="chevron-forward" size={16} color={theme.textMuted} />
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
  },
  leftContent: {
    flex: 1,
  },
  course: {
    fontSize: 16,
    fontWeight: '500',
  },
  date: {
    fontSize: 13,
    marginTop: 3,
  },
  rightContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  score: {
    fontSize: 20,
    fontWeight: '700',
    marginRight: 8,
  },
});
