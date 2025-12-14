import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { Session } from '../types';

interface SessionCardProps {
  session: Session;
  onPress?: () => void;
}

export const SessionCard: React.FC<SessionCardProps> = ({ session, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity style={styles.container} onPress={onPress} activeOpacity={0.7}>
      <View style={[
        styles.thumbnailContainer,
        {
          backgroundColor: theme.cardBackgroundElevated,
          shadowColor: theme.shadowColor,
        }
      ]}>
        {session.thumbnail ? (
          <Image source={{ uri: session.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail]}>
            <Ionicons name="golf" size={24} color={theme.primary} />
          </View>
        )}
      </View>
      <Text style={[styles.title, { color: theme.textPrimary }]} numberOfLines={1}>{session.title}</Text>
      <Text style={[styles.date, { color: theme.textSecondary }]}>{session.date}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: 110,
    marginRight: 12,
  },
  thumbnailContainer: {
    width: 110,
    height: 85,
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 8,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 6,
    elevation: 2,
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  placeholderThumbnail: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 13,
    fontWeight: '600',
  },
  date: {
    fontSize: 11,
    marginTop: 2,
  },
});
