import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import { SwingVideo } from '../types';

interface SwingVideoCardProps {
  video: SwingVideo;
  onPress?: () => void;
}

export const SwingVideoCard: React.FC<SwingVideoCardProps> = ({ video, onPress }) => {
  const { theme } = useTheme();

  return (
    <TouchableOpacity
      style={[
        styles.container,
        {
          backgroundColor: theme.cardBackground,
          borderColor: theme.border,
          shadowColor: theme.shadowColor,
        }
      ]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      <View style={[styles.thumbnailContainer, { backgroundColor: theme.cardBackgroundElevated }]}>
        {video.thumbnail ? (
          <Image source={{ uri: video.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail]}>
            <Ionicons name="videocam" size={22} color={theme.primary} />
          </View>
        )}
      </View>
      <View style={styles.content}>
        <Text style={[styles.title, { color: theme.textPrimary }]} numberOfLines={1}>{video.title}</Text>
        <Text style={[styles.type, { color: theme.textSecondary }]}>{video.type} • {video.date}</Text>
        <Text style={[styles.description, { color: theme.textMuted }]} numberOfLines={2}>{video.description}</Text>
      </View>
      <TouchableOpacity style={styles.moreButton}>
        <Ionicons name="ellipsis-vertical" size={18} color={theme.textSecondary} />
      </TouchableOpacity>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    borderRadius: 14,
    padding: 14,
    marginBottom: 12,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 2,
  },
  thumbnailContainer: {
    width: 64,
    height: 64,
    borderRadius: 10,
    overflow: 'hidden',
    marginRight: 14,
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  placeholderThumbnail: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  title: {
    fontSize: 15,
    fontWeight: '600',
    marginBottom: 3,
  },
  type: {
    fontSize: 12,
    marginBottom: 4,
  },
  description: {
    fontSize: 12,
    lineHeight: 16,
  },
  moreButton: {
    justifyContent: 'center',
    paddingLeft: 8,
  },
});
