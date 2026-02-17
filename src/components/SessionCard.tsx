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
            <Ionicons name="golf" size={24} color={theme.primary} style={{ opacity: 0.5 }} />
          </LinearGradient>
        )}
        {/* Location badge */}
        <View style={[styles.locationBadge, { backgroundColor: 'rgba(0,0,0,0.5)' }]}>
          <Ionicons name="location" size={9} color="#FFFFFF" />
          <Text style={styles.locationText}>{session.location}</Text>
        </View>
      </View>
      <Text style={[styles.title, { color: theme.textPrimary }]} numberOfLines={1}>{session.title}</Text>
      <Text style={[styles.date, { color: theme.textMuted }]}>{session.date}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: 150,
    marginRight: 12,
  },
  thumbnailContainer: {
    width: 150,
    height: 110,
    borderRadius: 16,
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
    borderRadius: 8,
  },
  locationText: {
    fontSize: 9,
    fontWeight: '600',
    marginLeft: 3,
    letterSpacing: 0.2,
    color: '#FFFFFF',
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
  },
  date: {
    fontSize: 12,
    marginTop: 3,
  },
});
