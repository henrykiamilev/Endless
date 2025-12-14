import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../context/ThemeContext';
import { Session } from '../types';

interface SessionCardProps {
  session: Session;
  onPress?: () => void;
}

export const SessionCard: React.FC<SessionCardProps> = ({ session, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity style={styles.container} onPress={onPress} activeOpacity={0.9}>
      <View style={styles.thumbnailContainer}>
        {session.thumbnail ? (
          <Image source={{ uri: session.thumbnail }} style={styles.thumbnail} />
        ) : (
          <LinearGradient
            colors={theme.isDark ? ['#1A3A2E', '#0D1F17'] : ['#D4E5DC', '#A8C5B5']}
            style={[styles.thumbnail, styles.placeholderThumbnail]}
          >
            <Ionicons name="golf" size={28} color={theme.primary} style={{ opacity: 0.6 }} />
          </LinearGradient>
        )}
        {/* Location badge */}
        <View style={[styles.locationBadge, { backgroundColor: theme.cardBackground }]}>
          <Ionicons name="location" size={10} color={theme.textSecondary} />
          <Text style={[styles.locationText, { color: theme.textSecondary }]}>{session.location}</Text>
        </View>
      </View>
      <Text style={[styles.title, { color: theme.textPrimary }]} numberOfLines={1}>{session.title}</Text>
      <Text style={[styles.date, { color: theme.textSecondary }]}>{session.date}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: 140,
    marginRight: 14,
  },
  thumbnailContainer: {
    width: 140,
    height: 100,
    borderRadius: 20,
    overflow: 'hidden',
    marginBottom: 10,
    position: 'relative',
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  placeholderThumbnail: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  locationBadge: {
    position: 'absolute',
    bottom: 8,
    left: 8,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
  },
  locationText: {
    fontSize: 9,
    fontWeight: '600',
    marginLeft: 3,
    letterSpacing: 0.3,
  },
  title: {
    fontSize: 14,
    fontWeight: '700',
  },
  date: {
    fontSize: 12,
    marginTop: 3,
  },
});
