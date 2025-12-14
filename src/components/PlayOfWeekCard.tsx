import React from 'react';
import { View, Text, StyleSheet, Image, Dimensions, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../context/ThemeContext';
import { PlayOfTheWeek } from '../types';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width * 0.8;

interface PlayOfWeekCardProps {
  play: PlayOfTheWeek;
  onPress?: () => void;
}

export const PlayOfWeekCard: React.FC<PlayOfWeekCardProps> = ({ play, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={onPress}
      activeOpacity={0.95}
    >
      {/* Background with gradient */}
      <LinearGradient
        colors={theme.isDark ? ['#1A3A2E', '#0A1A14'] : ['#C5D9CD', '#8FB09A']}
        style={styles.gradientBackground}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        {/* Golf course placeholder pattern */}
        <View style={styles.patternOverlay}>
          {play.thumbnail ? (
            <Image source={{ uri: play.thumbnail }} style={styles.thumbnail} />
          ) : (
            <View style={styles.placeholderContent}>
              <Ionicons name="golf" size={64} color={theme.primary} style={{ opacity: 0.3 }} />
            </View>
          )}
        </View>

        {/* Friends/viewers badge */}
        <View style={[styles.viewersBadge, { backgroundColor: theme.cardBackground }]}>
          <View style={styles.viewersAvatars}>
            <View style={[styles.miniAvatar, { backgroundColor: theme.primary }]}>
              <Text style={styles.miniAvatarText}>H</Text>
            </View>
            <View style={[styles.miniAvatar, styles.miniAvatarOffset, { backgroundColor: theme.accentBlue }]}>
              <Text style={styles.miniAvatarText}>J</Text>
            </View>
          </View>
          <Text style={[styles.viewersText, { color: theme.textSecondary }]}>4 FRIENDS ARE HERE</Text>
        </View>

        {/* Play button */}
        <View style={[styles.playButton, { backgroundColor: theme.primary }]}>
          <Ionicons name="play" size={28} color={theme.textInverse} style={{ marginLeft: 3 }} />
        </View>
      </LinearGradient>

      {/* Bottom info section */}
      <View style={[styles.infoSection, { backgroundColor: theme.cardBackground }]}>
        <Text style={[styles.courseName, { color: theme.textPrimary }]}>{play.location || 'Prydeland Spring'}</Text>
        <Text style={[styles.courseDescription, { color: theme.textSecondary }]} numberOfLines={2}>
          Its unique 47 holes layouts, comprising of a trio of testing nine hole circuits.
        </Text>

        <TouchableOpacity style={[styles.startButton, { backgroundColor: theme.primary }]}>
          <Ionicons name="flag" size={16} color={theme.textInverse} />
          <Text style={[styles.startButtonText, { color: theme.textInverse }]}>START ROUND</Text>
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: CARD_WIDTH,
    marginRight: 16,
    borderRadius: 28,
    overflow: 'hidden',
  },
  gradientBackground: {
    height: 240,
    position: 'relative',
    justifyContent: 'center',
    alignItems: 'center',
  },
  patternOverlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
  },
  thumbnail: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  placeholderContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  viewersBadge: {
    position: 'absolute',
    top: 16,
    left: 16,
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 12,
    paddingLeft: 8,
    borderRadius: 20,
  },
  viewersAvatars: {
    flexDirection: 'row',
    marginRight: 8,
  },
  miniAvatar: {
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#FFFFFF',
  },
  miniAvatarOffset: {
    marginLeft: -10,
  },
  miniAvatarText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  viewersText: {
    fontSize: 10,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  playButton: {
    width: 64,
    height: 64,
    borderRadius: 32,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  infoSection: {
    padding: 20,
  },
  courseName: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 8,
  },
  courseDescription: {
    fontSize: 13,
    lineHeight: 18,
    marginBottom: 18,
  },
  startButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    borderRadius: 28,
  },
  startButtonText: {
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 0.5,
    marginLeft: 8,
  },
});
