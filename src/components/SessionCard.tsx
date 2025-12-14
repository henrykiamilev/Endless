import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Colors } from '../constants/colors';
import { Session } from '../types';

interface SessionCardProps {
  session: Session;
  onPress?: () => void;
}

export const SessionCard: React.FC<SessionCardProps> = ({ session, onPress }) => {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <View style={styles.thumbnailContainer}>
        {session.thumbnail ? (
          <Image source={{ uri: session.thumbnail }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.placeholderThumbnail]}>
            <Text style={styles.placeholderText}>Session</Text>
          </View>
        )}
      </View>
      <Text style={styles.title} numberOfLines={1}>{session.title}</Text>
      <Text style={styles.date}>{session.date}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: 100,
    marginRight: 12,
  },
  thumbnailContainer: {
    width: 100,
    height: 80,
    borderRadius: 8,
    overflow: 'hidden',
    marginBottom: 6,
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
    fontSize: 10,
  },
  title: {
    color: Colors.textPrimary,
    fontSize: 12,
    fontWeight: '500',
  },
  date: {
    color: Colors.textSecondary,
    fontSize: 10,
  },
});
