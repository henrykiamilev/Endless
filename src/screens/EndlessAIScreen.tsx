import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  TouchableOpacity,
  TextInput,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../constants/colors';
import { SwingVideoCard } from '../components';
import { SwingVideo } from '../types';

const mockSwingVideos: SwingVideo[] = [
  {
    id: '1',
    title: 'Down the Line - Current Swing',
    type: 'DTL',
    date: '10/12/25',
    description: 'Working on staying centered over the ball',
  },
  {
    id: '2',
    title: 'Face On View',
    type: 'Face On',
    date: '10/10/25',
    description: 'Focusing on reducing head sway',
  },
];

const courseFilters = ['Oakmont CC', 'Pebble Beach', 'Del Mar'];

export const EndlessAIScreen: React.FC = () => {
  const [prompt, setPrompt] = useState('');
  const [selectedCourses, setSelectedCourses] = useState<string[]>([]);

  const toggleCourse = (course: string) => {
    if (selectedCourses.includes(course)) {
      setSelectedCourses(selectedCourses.filter(c => c !== course));
    } else {
      setSelectedCourses([...selectedCourses, course]);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Endless AI</Text>
        </View>

        {/* Create Highlight Reel Section */}
        <View style={styles.section}>
          <View style={styles.highlightCard}>
            <View style={styles.highlightHeader}>
              <View style={styles.aiIconContainer}>
                <Ionicons name="sparkles" size={24} color={Colors.accent} />
              </View>
              <View style={styles.highlightTitleContainer}>
                <Text style={styles.highlightTitle}>Create Highlight Reel</Text>
                <Text style={styles.highlightSubtitle}>Powered by AI</Text>
              </View>
            </View>

            <TextInput
              style={styles.promptInput}
              placeholder='Describe your perfect highlight reel... (e.g., "Create a 2-minute reel focusing on my short game and driving accuracy from my last 5 matches.")'
              placeholderTextColor={Colors.textMuted}
              multiline
              numberOfLines={4}
              value={prompt}
              onChangeText={setPrompt}
            />

            {/* Course Filters */}
            <View style={styles.courseFilters}>
              {courseFilters.map((course) => (
                <TouchableOpacity
                  key={course}
                  style={[
                    styles.courseChip,
                    selectedCourses.includes(course) && styles.courseChipSelected,
                  ]}
                  onPress={() => toggleCourse(course)}
                >
                  <Text
                    style={[
                      styles.courseChipText,
                      selectedCourses.includes(course) && styles.courseChipTextSelected,
                    ]}
                  >
                    {course}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <TouchableOpacity style={styles.generateButton}>
              <Text style={styles.generateButtonText}>Generate Highlight Reel</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* My Swing Videos Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>My Swing Videos</Text>
            <TouchableOpacity style={styles.addButton}>
              <Ionicons name="add" size={24} color={Colors.textPrimary} />
            </TouchableOpacity>
          </View>
          <Text style={styles.sectionSubtitle}>
            Upload up to 5 swing videos with annotations
          </Text>

          <View style={styles.swingVideosList}>
            {mockSwingVideos.map((video) => (
              <SwingVideoCard key={video.id} video={video} />
            ))}
          </View>

          {/* Add More Videos CTA */}
          <TouchableOpacity style={styles.addVideoCard}>
            <Ionicons name="add-circle-outline" size={32} color={Colors.textSecondary} />
            <Text style={styles.addVideoText}>Add Swing Video</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.bottomPadding} />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 20,
  },
  title: {
    color: Colors.textPrimary,
    fontSize: 24,
    fontWeight: '700',
  },
  section: {
    marginBottom: 24,
    paddingHorizontal: 16,
  },
  highlightCard: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  highlightHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  aiIconContainer: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(88, 166, 255, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  highlightTitleContainer: {
    flex: 1,
  },
  highlightTitle: {
    color: Colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },
  highlightSubtitle: {
    color: Colors.textSecondary,
    fontSize: 12,
    marginTop: 2,
  },
  promptInput: {
    backgroundColor: Colors.background,
    borderRadius: 12,
    padding: 12,
    color: Colors.textPrimary,
    fontSize: 14,
    minHeight: 100,
    textAlignVertical: 'top',
    borderWidth: 1,
    borderColor: Colors.border,
    marginBottom: 12,
  },
  courseFilters: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 16,
  },
  courseChip: {
    backgroundColor: Colors.cardBackgroundLight,
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 16,
    marginRight: 8,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  courseChipSelected: {
    backgroundColor: Colors.accent,
    borderColor: Colors.accent,
  },
  courseChipText: {
    color: Colors.textSecondary,
    fontSize: 12,
    fontWeight: '500',
  },
  courseChipTextSelected: {
    color: Colors.textPrimary,
  },
  generateButton: {
    backgroundColor: Colors.buttonPrimary,
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  generateButtonText: {
    color: Colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  sectionTitle: {
    color: Colors.textPrimary,
    fontSize: 18,
    fontWeight: '600',
  },
  addButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.cardBackgroundLight,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sectionSubtitle: {
    color: Colors.textSecondary,
    fontSize: 13,
    marginBottom: 16,
  },
  swingVideosList: {
    marginBottom: 12,
  },
  addVideoCard: {
    backgroundColor: Colors.cardBackground,
    borderRadius: 12,
    padding: 24,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.border,
    borderStyle: 'dashed',
  },
  addVideoText: {
    color: Colors.textSecondary,
    fontSize: 14,
    marginTop: 8,
  },
  bottomPadding: {
    height: 100,
  },
});
