import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../constants/colors';
import { RoundHistory } from '../types';

interface RoundHistoryCardProps {
  round: RoundHistory;
  onPress?: () => void;
}

export const RoundHistoryCard: React.FC<RoundHistoryCardProps> = ({ round, onPress }) => {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <View style={styles.leftContent}>
        <Text style={styles.course}>{round.course}</Text>
        <Text style={styles.date}>{round.date}</Text>
      </View>
      <View style={styles.rightContent}>
        <Text style={styles.score}>{round.score}</Text>
        <Ionicons name="chevron-forward" size={16} color={Colors.textSecondary} />
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  leftContent: {
    flex: 1,
  },
  course: {
    color: Colors.textPrimary,
    fontSize: 15,
    fontWeight: '500',
  },
  date: {
    color: Colors.textSecondary,
    fontSize: 12,
    marginTop: 2,
  },
  rightContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  score: {
    color: Colors.textPrimary,
    fontSize: 18,
    fontWeight: '700',
    marginRight: 8,
  },
});
