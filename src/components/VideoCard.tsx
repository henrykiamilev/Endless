import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { Video } from '../types';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - 56) / 2;

interface VideoCardProps {
  video: Video;
  onPress?: () => void;
}

export const VideoCard: React.FC<VideoCardProps> = ({ video, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity style={styles.container} onPress={onPress} activeOpacity={0.8}>
      <View style={[
        styles.thumbnailContainer,
        {
          backgroundColor: theme.cardBackground,
        }
      ]}>
        {video.thumbnail ? (
          <Image source={{ uri: video.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail, { backgroundColor: theme.cardBackgroundElevated }]}>
            <Ionicons name="videocam" size={28} color={theme.primary} />
          </View>
        )}
        <View style={[styles.playButton, { backgroundColor: theme.primary }]}>
          <Ionicons name="play" size={16} color={theme.textInverse} />
        </View>
        {video.duration && (
          <View style={styles.durationBadge}>
            <Text style={styles.durationText}>{video.duration}</Text>
          </View>
        )}
      </View>
      <Text style={[styles.title, { color: theme.textPrimary }]} numberOfLines={1}>{video.title}</Text>
      <Text style={[styles.date, { color: theme.textMuted }]}>{video.date}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: CARD_WIDTH,
    marginBottom: 16,
  },
  thumbnailContainer: {
    width: '100%',
    height: CARD_WIDTH * 0.75,
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 10,
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
    top: '50%',
    left: '50%',
    transform: [{ translateX: -16 }, { translateY: -16 }],
    width: 32,
    height: 32,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 2,
  },
  durationBadge: {
    position: 'absolute',
    bottom: 8,
    right: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  durationText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '600',
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
