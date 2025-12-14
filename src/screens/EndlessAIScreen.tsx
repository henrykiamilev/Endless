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
import { useTheme } from '../context/ThemeContext';
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
  const { theme } = useTheme();
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
    <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerRow}>
            <View style={[styles.logoContainer, { backgroundColor: theme.cardBackground, borderColor: theme.border }]}>
              <Text style={[styles.logoText, { color: theme.textPrimary }]}>∞</Text>
            </View>
            <Text style={[styles.title, { color: theme.textPrimary }]}>Endless AI</Text>
          </View>
        </View>

        {/* Create Highlight Reel Section */}
        <View style={styles.section}>
          <View style={[
            styles.highlightCard,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
            }
          ]}>
            <View style={styles.highlightHeader}>
              <View style={[styles.aiIconContainer, { backgroundColor: `${theme.primary}20` }]}>
                <Ionicons name="sparkles" size={24} color={theme.primary} />
              </View>
              <View style={styles.highlightTitleContainer}>
                <Text style={[styles.highlightTitle, { color: theme.textPrimary }]}>Create Highlight Reel</Text>
                <Text style={[styles.highlightSubtitle, { color: theme.textSecondary }]}>Powered by AI</Text>
              </View>
            </View>

            <TextInput
              style={[
                styles.promptInput,
                {
                  backgroundColor: theme.backgroundSecondary,
                  color: theme.textPrimary,
                  borderColor: theme.border,
                }
              ]}
              placeholder='Describe your perfect highlight reel... (e.g., "Create a 2-minute reel focusing on my short game and driving accuracy from my last 5 matches.")'
              placeholderTextColor={theme.textMuted}
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
                    { backgroundColor: theme.cardBackgroundElevated, borderColor: theme.border },
                    selectedCourses.includes(course) && { backgroundColor: theme.primary, borderColor: theme.primary },
                  ]}
                  onPress={() => toggleCourse(course)}
                >
                  <Text
                    style={[
                      styles.courseChipText,
                      { color: theme.textSecondary },
                      selectedCourses.includes(course) && { color: theme.textInverse },
                    ]}
                  >
                    {course}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <TouchableOpacity style={[styles.generateButton, { backgroundColor: theme.primary }]}>
              <Ionicons name="sparkles" size={18} color={theme.textInverse} style={{ marginRight: 8 }} />
              <Text style={[styles.generateButtonText, { color: theme.textInverse }]}>Generate Highlight Reel</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* My Swing Videos Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>My Swing Videos</Text>
            <TouchableOpacity style={[styles.addButton, { backgroundColor: theme.primary }]}>
              <Ionicons name="add" size={22} color={theme.textInverse} />
            </TouchableOpacity>
          </View>
          <Text style={[styles.sectionSubtitle, { color: theme.textSecondary }]}>
            Upload up to 5 swing videos with annotations
          </Text>

          <View style={styles.swingVideosList}>
            {mockSwingVideos.map((video) => (
              <SwingVideoCard key={video.id} video={video} />
            ))}
          </View>

          {/* Add More Videos CTA */}
          <TouchableOpacity style={[
            styles.addVideoCard,
            {
              backgroundColor: theme.cardBackground,
              borderColor: theme.border,
            }
          ]}>
            <View style={[styles.addVideoIconBg, { backgroundColor: `${theme.primary}20` }]}>
              <Ionicons name="add" size={28} color={theme.primary} />
            </View>
            <Text style={[styles.addVideoText, { color: theme.textSecondary }]}>Add Swing Video</Text>
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
  },
  scrollView: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 24,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logoContainer: {
    width: 44,
    height: 44,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
    borderWidth: 1,
  },
  logoText: {
    fontSize: 24,
    fontWeight: '300',
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
  },
  section: {
    marginBottom: 28,
    paddingHorizontal: 20,
  },
  highlightCard: {
    borderRadius: 20,
    padding: 20,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 4,
  },
  highlightHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 18,
  },
  aiIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 14,
  },
  highlightTitleContainer: {
    flex: 1,
  },
  highlightTitle: {
    fontSize: 18,
    fontWeight: '700',
  },
  highlightSubtitle: {
    fontSize: 13,
    marginTop: 3,
  },
  promptInput: {
    borderRadius: 14,
    padding: 14,
    fontSize: 14,
    minHeight: 110,
    textAlignVertical: 'top',
    borderWidth: 1,
    marginBottom: 14,
    lineHeight: 20,
  },
  courseFilters: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 18,
  },
  courseChip: {
    paddingVertical: 8,
    paddingHorizontal: 14,
    borderRadius: 20,
    marginRight: 8,
    marginBottom: 8,
    borderWidth: 1,
  },
  courseChipText: {
    fontSize: 13,
    fontWeight: '500',
  },
  generateButton: {
    flexDirection: 'row',
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  generateButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  sectionTitle: {
    fontSize: 19,
    fontWeight: '700',
  },
  addButton: {
    width: 34,
    height: 34,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sectionSubtitle: {
    fontSize: 13,
    marginBottom: 18,
  },
  swingVideosList: {
    marginBottom: 14,
  },
  addVideoCard: {
    borderRadius: 16,
    padding: 28,
    alignItems: 'center',
    borderWidth: 1,
    borderStyle: 'dashed',
  },
  addVideoIconBg: {
    width: 52,
    height: 52,
    borderRadius: 26,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  addVideoText: {
    fontSize: 14,
    fontWeight: '500',
  },
  bottomPadding: {
    height: 100,
  },
});
