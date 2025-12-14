import React from 'react';
import { View, Text, StyleSheet, Image, Dimensions, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
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
      style={[
        styles.container,
        {
          backgroundColor: theme.cardBackground,
          shadowColor: theme.shadowColor,
        }
      ]}
      onPress={onPress}
      activeOpacity={0.9}
    >
      <View style={styles.thumbnailContainer}>
        {play.thumbnail ? (
          <Image source={{ uri: play.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail, { backgroundColor: theme.cardBackgroundElevated }]}>
            <Ionicons name="golf" size={40} color={theme.primary} />
          </View>
        )}
        <View style={styles.playButton}>
          <Ionicons name="play" size={24} color="#FFFFFF" />
        </View>
      </View>
      <View style={[styles.overlay, { backgroundColor: theme.isDark ? 'rgba(0, 0, 0, 0.75)' : 'rgba(0, 0, 0, 0.65)' }]}>
        <View style={styles.playerInfo}>
          <View style={styles.avatarContainer}>
            {play.avatar ? (
              <Image source={{ uri: play.avatar }} style={styles.avatar} />
            ) : (
              <View style={[styles.avatar, styles.avatarPlaceholder, { backgroundColor: theme.primary }]}>
                <Text style={[styles.avatarText, { color: theme.textInverse }]}>{play.playerName.charAt(0)}</Text>
              </View>
            )}
          </View>
          <View style={styles.textContainer}>
            <Text style={styles.playerName}>{play.playerName}</Text>
            <Text style={styles.playerTitle}>{play.playerTitle}</Text>
            <Text style={styles.location}>{play.location}</Text>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: CARD_WIDTH,
    height: 220,
    marginRight: 12,
    borderRadius: 20,
    overflow: 'hidden',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 5,
  },
  thumbnailContainer: {
    flex: 1,
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  placeholderThumbnail: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  playButton: {
    position: 'absolute',
    top: '40%',
    left: '50%',
    transform: [{ translateX: -28 }, { translateY: -28 }],
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(0, 212, 170, 0.9)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 4,
  },
  overlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: 14,
  },
  playerInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatarContainer: {
    marginRight: 12,
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
  },
  avatarPlaceholder: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 18,
    fontWeight: '600',
  },
  textContainer: {
    flex: 1,
  },
  playerName: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
  },
  playerTitle: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 12,
    marginTop: 1,
  },
  location: {
    color: 'rgba(255, 255, 255, 0.7)',
    fontSize: 12,
  },
});
