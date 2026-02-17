import React from 'react';
import { View, Text, StyleSheet, Image, Dimensions, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../context/ThemeContext';
import { PlayOfTheWeek } from '../types';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width * 0.75;

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
              <Ionicons name="golf" size={56} color={theme.primary} style={{ opacity: 0.25 }} />
            </View>
          )}
        </View>

        {/* Friends/viewers badge */}
        <View style={[styles.viewersBadge, { backgroundColor: 'rgba(0,0,0,0.5)' }]}>
          <View style={styles.viewersAvatars}>
            <View style={[styles.miniAvatar, { backgroundColor: theme.primary }]}>
              <Text style={styles.miniAvatarText}>H</Text>
            </View>
            <View style={[styles.miniAvatar, styles.miniAvatarOffset, { backgroundColor: theme.accentBlue }]}>
              <Text style={styles.miniAvatarText}>J</Text>
            </View>
          </View>
          <Text style={styles.viewersText}>4 FRIENDS ARE HERE</Text>
        </View>

        {/* Play button */}
        <View style={[styles.playButton, { backgroundColor: theme.primary }]}>
          <Ionicons name="play" size={24} color={theme.textInverse} style={{ marginLeft: 2 }} />
        </View>
      </LinearGradient>

      {/* Bottom info section */}
      <View style={[styles.infoSection, { backgroundColor: theme.cardBackground }]}>
        <Text style={[styles.courseName, { color: theme.textPrimary }]}>{play.location || 'Prydeland Spring'}</Text>
        <Text style={[styles.courseDescription, { color: theme.textMuted }]} numberOfLines={2}>
          Its unique 47 holes layouts, comprising of a trio of testing nine hole circuits.
        </Text>

        <TouchableOpacity style={[styles.startButton, { backgroundColor: theme.primary }]}>
          <Ionicons name="flag" size={16} color={theme.textInverse} />
          <Text style={[styles.startButtonText, { color: theme.textInverse }]}>Start Round</Text>
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: CARD_WIDTH,
    marginRight: 14,
    borderRadius: 20,
    overflow: 'hidden',
  },
  gradientBackground: {
    height: 220,
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
    top: 14,
    left: 14,
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 7,
    paddingHorizontal: 10,
    paddingLeft: 8,
    borderRadius: 12,
  },
  viewersAvatars: {
    flexDirection: 'row',
    marginRight: 8,
  },
  miniAvatar: {
    width: 22,
    height: 22,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.3)',
  },
  miniAvatarOffset: {
    marginLeft: -8,
  },
  miniAvatarText: {
    fontSize: 9,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  viewersText: {
    fontSize: 10,
    fontWeight: '600',
    letterSpacing: 0.3,
    color: '#FFFFFF',
  },
  playButton: {
    width: 56,
    height: 56,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 10,
    elevation: 8,
  },
  infoSection: {
    padding: 18,
  },
  courseName: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 6,
    letterSpacing: -0.3,
  },
  courseDescription: {
    fontSize: 13,
    lineHeight: 18,
    marginBottom: 16,
  },
  startButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    borderRadius: 14,
  },
  startButtonText: {
    fontSize: 14,
    fontWeight: '600',
    marginLeft: 8,
  },
});
