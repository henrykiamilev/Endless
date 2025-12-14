import React from 'react';
import { View, Text, StyleSheet, Image, Dimensions, TouchableOpacity } from 'react-native';
import { Colors } from '../constants/colors';
import { PlayOfTheWeek } from '../types';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width * 0.75;

interface PlayOfWeekCardProps {
  play: PlayOfTheWeek;
  onPress?: () => void;
}

export const PlayOfWeekCard: React.FC<PlayOfWeekCardProps> = ({ play, onPress }) => {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <View style={styles.thumbnailContainer}>
        {play.thumbnail ? (
          <Image source={{ uri: play.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail]}>
            <Text style={styles.placeholderText}>Golf Video</Text>
          </View>
        )}
      </View>
      <View style={styles.overlay}>
        <View style={styles.playerInfo}>
          <View style={styles.avatarContainer}>
            {play.avatar ? (
              <Image source={{ uri: play.avatar }} style={styles.avatar} />
            ) : (
              <View style={[styles.avatar, styles.avatarPlaceholder]}>
                <Text style={styles.avatarText}>{play.playerName.charAt(0)}</Text>
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
    height: 200,
    marginRight: 12,
    borderRadius: 16,
    overflow: 'hidden',
    backgroundColor: Colors.cardBackground,
  },
  thumbnailContainer: {
    flex: 1,
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  placeholderThumbnail: {
    backgroundColor: Colors.cardBackgroundLight,
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholderText: {
    color: Colors.textSecondary,
    fontSize: 14,
  },
  overlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: 12,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
  },
  playerInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatarContainer: {
    marginRight: 10,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
  },
  avatarPlaceholder: {
    backgroundColor: Colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    color: Colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },
  textContainer: {
    flex: 1,
  },
  playerName: {
    color: Colors.textPrimary,
    fontSize: 14,
    fontWeight: '600',
  },
  playerTitle: {
    color: Colors.textSecondary,
    fontSize: 11,
  },
  location: {
    color: Colors.textSecondary,
    fontSize: 11,
  },
});
