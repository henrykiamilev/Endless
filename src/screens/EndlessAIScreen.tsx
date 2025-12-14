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
import { LinearGradient } from 'expo-linear-gradient';
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
          <View style={styles.headerTop}>
            <TouchableOpacity style={[styles.menuButton, { backgroundColor: theme.cardBackground }]}>
              <Ionicons name="menu" size={22} color={theme.textPrimary} />
            </TouchableOpacity>
            <View style={[styles.logoContainer, { backgroundColor: theme.cardBackground }]}>
              <Text style={[styles.logoText, { color: theme.primary }]}>∞</Text>
            </View>
          </View>
          <Text style={[styles.heroTitle, { color: theme.textPrimary }]}>
            ENDLESS{'\n'}AI
          </Text>
        </View>

        {/* Create Highlight Reel Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>CREATE HIGHLIGHT REEL</Text>
          <View style={[styles.highlightCard, { backgroundColor: theme.cardBackground }]}>
            <LinearGradient
              colors={theme.isDark ? ['#1A3A2E', '#0A1A14'] : ['#D4E5DC', '#A8C5B5']}
              style={styles.highlightGradient}
            >
              <View style={[styles.aiIconContainer, { backgroundColor: 'rgba(255,255,255,0.15)' }]}>
                <Ionicons name="sparkles" size={32} color="#FFFFFF" />
              </View>
              <Text style={styles.highlightBadge}>POWERED BY AI</Text>
            </LinearGradient>

            <View style={styles.highlightContent}>
              <TextInput
                style={[
                  styles.promptInput,
                  {
                    backgroundColor: theme.backgroundSecondary,
                    color: theme.textPrimary,
                  }
                ]}
                placeholder='Describe your perfect highlight reel...'
                placeholderTextColor={theme.textMuted}
                multiline
                numberOfLines={3}
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
                      { backgroundColor: theme.backgroundSecondary },
                      selectedCourses.includes(course) && { backgroundColor: theme.primary },
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
                <Text style={[styles.generateButtonText, { color: theme.textInverse }]}>GENERATE REEL</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* My Swing Videos Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={[styles.sectionLabel, { color: theme.textSecondary }]}>MY SWING VIDEOS</Text>
            <TouchableOpacity style={[styles.addButton, { backgroundColor: theme.primary }]}>
              <Ionicons name="add" size={20} color={theme.textInverse} />
            </TouchableOpacity>
          </View>
          <Text style={[styles.sectionSubtitle, { color: theme.textMuted }]}>
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
            }
          ]}>
            <View style={[styles.addVideoIconBg, { backgroundColor: `${theme.primary}15` }]}>
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
    paddingBottom: 20,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  menuButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoText: {
    fontSize: 24,
    fontWeight: '300',
  },
  heroTitle: {
    fontSize: 48,
    fontWeight: '800',
    letterSpacing: -2,
    lineHeight: 48,
  },
  section: {
    marginBottom: 32,
    paddingHorizontal: 20,
  },
  sectionLabel: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.5,
    marginBottom: 14,
  },
  highlightCard: {
    borderRadius: 24,
    overflow: 'hidden',
  },
  highlightGradient: {
    padding: 28,
    alignItems: 'center',
  },
  aiIconContainer: {
    width: 72,
    height: 72,
    borderRadius: 36,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  highlightBadge: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1,
    color: 'rgba(255,255,255,0.8)',
  },
  highlightContent: {
    padding: 20,
  },
  promptInput: {
    borderRadius: 16,
    padding: 16,
    fontSize: 14,
    minHeight: 80,
    textAlignVertical: 'top',
    marginBottom: 16,
    lineHeight: 20,
  },
  courseFilters: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 18,
  },
  courseChip: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 20,
    marginRight: 8,
    marginBottom: 8,
  },
  courseChipText: {
    fontSize: 12,
    fontWeight: '600',
  },
  generateButton: {
    flexDirection: 'row',
    paddingVertical: 16,
    borderRadius: 28,
    alignItems: 'center',
    justifyContent: 'center',
  },
  generateButtonText: {
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  addButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
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
    borderRadius: 20,
    padding: 32,
    alignItems: 'center',
  },
  addVideoIconBg: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  addVideoText: {
    fontSize: 14,
    fontWeight: '600',
  },
  bottomPadding: {
    height: 120,
  },
});
