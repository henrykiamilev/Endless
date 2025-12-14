import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../constants/colors';
import { Video } from '../types';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - 48) / 2;

interface VideoCardProps {
  video: Video;
  onPress?: () => void;
}

export const VideoCard: React.FC<VideoCardProps> = ({ video, onPress }) => {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <View style={styles.thumbnailContainer}>
        {video.thumbnail ? (
          <Image source={{ uri: video.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail]}>
            <Ionicons name="videocam" size={32} color={Colors.textSecondary} />
          </View>
        )}
        <View style={styles.playButton}>
          <Ionicons name="play" size={20} color={Colors.textPrimary} />
        </View>
        {video.duration && (
          <View style={styles.durationBadge}>
            <Text style={styles.durationText}>{video.duration}</Text>
          </View>
        )}
      </View>
      <Text style={styles.title} numberOfLines={1}>{video.title}</Text>
      <Text style={styles.date}>{video.date}</Text>
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
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 8,
    backgroundColor: Colors.cardBackground,
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
  playButton: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -20 }, { translateY: -20 }],
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  durationBadge: {
    position: 'absolute',
    bottom: 8,
    right: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
  },
  durationText: {
    color: Colors.textPrimary,
    fontSize: 10,
    fontWeight: '500',
  },
  title: {
    color: Colors.textPrimary,
    fontSize: 14,
    fontWeight: '600',
  },
  date: {
    color: Colors.textSecondary,
    fontSize: 12,
    marginTop: 2,
  },
});
