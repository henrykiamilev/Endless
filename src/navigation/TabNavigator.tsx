import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';
import {
  HomeScreen,
  VideoLibraryScreen,
  RecordScreen,
  EndlessAIScreen,
  SettingsScreen,
} from '../screens';

const Tab = createBottomTabNavigator();

export const TabNavigator: React.FC = () => {
  const { theme } = useTheme();

  const CustomRecordButton = ({ onPress }: { onPress?: () => void }) => (
    <TouchableOpacity style={styles.recordButton} onPress={onPress} activeOpacity={0.85}>
      <View style={[styles.recordButtonInner, { backgroundColor: theme.primary }]}>
        <Ionicons name="add" size={28} color={theme.textInverse} />
      </View>
    </TouchableOpacity>
  );

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: [
          styles.tabBar,
          {
            backgroundColor: theme.cardBackground,
            borderTopColor: 'transparent',
            borderColor: theme.border,
          }
        ],
        tabBarActiveTintColor: theme.primary,
        tabBarInactiveTintColor: theme.tabBarInactive,
        tabBarShowLabel: true,
        tabBarLabelStyle: styles.tabBarLabel,
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}15` }]}>
              <Ionicons
                name={focused ? 'home' : 'home-outline'}
                size={22}
                color={focused ? theme.primary : theme.tabBarInactive}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Video"
        component={VideoLibraryScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}15` }]}>
              <Ionicons
                name={focused ? 'videocam' : 'videocam-outline'}
                size={22}
                color={focused ? theme.primary : theme.tabBarInactive}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Record"
        component={RecordScreen}
        options={{
          tabBarIcon: () => null,
          tabBarButton: (props) => (
            <CustomRecordButton onPress={props.onPress} />
          ),
          tabBarLabel: () => null,
        }}
      />
      <Tab.Screen
        name="AI"
        component={EndlessAIScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}15` }]}>
              <Ionicons
                name={focused ? 'sparkles' : 'sparkles-outline'}
                size={22}
                color={focused ? theme.primary : theme.tabBarInactive}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}15` }]}>
              <Ionicons
                name={focused ? 'settings' : 'settings-outline'}
                size={22}
                color={focused ? theme.primary : theme.tabBarInactive}
              />
            </View>
          ),
        }}
      />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  tabBar: {
    borderTopWidth: 0,
    height: 88,
    paddingBottom: 28,
    paddingTop: 10,
    position: 'absolute',
    marginHorizontal: 20,
    marginBottom: 10,
    borderRadius: 20,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 24,
    elevation: 12,
  },
  tabBarLabel: {
    fontSize: 10,
    fontWeight: '600',
    marginTop: 2,
    letterSpacing: 0.2,
  },
  tabIconContainer: {
    width: 38,
    height: 38,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButton: {
    top: -22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButtonInner: {
    width: 56,
    height: 56,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#00D4AA',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.35,
    shadowRadius: 14,
    elevation: 10,
  },
});
