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
        <Ionicons name="add" size={32} color={theme.textInverse} />
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
          }
        ],
        tabBarActiveTintColor: theme.textPrimary,
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
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}20` }]}>
              <Ionicons
                name={focused ? 'home' : 'home-outline'}
                size={22}
                color={focused ? theme.textPrimary : theme.tabBarInactive}
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
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}20` }]}>
              <Ionicons
                name={focused ? 'videocam' : 'videocam-outline'}
                size={22}
                color={focused ? theme.textPrimary : theme.tabBarInactive}
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
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}20` }]}>
              <Ionicons
                name={focused ? 'sparkles' : 'sparkles-outline'}
                size={22}
                color={focused ? theme.textPrimary : theme.tabBarInactive}
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
            <View style={[styles.tabIconContainer, focused && { backgroundColor: `${theme.primary}20` }]}>
              <Ionicons
                name={focused ? 'settings' : 'settings-outline'}
                size={22}
                color={focused ? theme.textPrimary : theme.tabBarInactive}
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
    height: 90,
    paddingBottom: 28,
    paddingTop: 12,
    position: 'absolute',
    marginHorizontal: 16,
    marginBottom: 8,
    borderRadius: 28,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 8,
  },
  tabBarLabel: {
    fontSize: 10,
    fontWeight: '600',
    marginTop: 4,
    letterSpacing: 0.3,
  },
  tabIconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButton: {
    top: -24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButtonInner: {
    width: 62,
    height: 62,
    borderRadius: 31,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#00D4AA',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
    elevation: 10,
  },
});
