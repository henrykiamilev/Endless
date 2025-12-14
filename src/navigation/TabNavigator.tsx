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
    <TouchableOpacity style={styles.recordButton} onPress={onPress} activeOpacity={0.8}>
      <View style={[styles.recordButtonInner, { backgroundColor: theme.primary }]}>
        <Ionicons name="add" size={30} color={theme.textInverse} />
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
            backgroundColor: theme.tabBarBackground,
            borderTopColor: theme.border,
          }
        ],
        tabBarActiveTintColor: theme.tabBarActive,
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
            <Ionicons
              name={focused ? 'home' : 'home-outline'}
              size={23}
              color={focused ? theme.tabBarActive : theme.tabBarInactive}
            />
          ),
        }}
      />
      <Tab.Screen
        name="Video"
        component={VideoLibraryScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <Ionicons
              name={focused ? 'videocam' : 'videocam-outline'}
              size={23}
              color={focused ? theme.tabBarActive : theme.tabBarInactive}
            />
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
            <Ionicons
              name={focused ? 'sparkles' : 'sparkles-outline'}
              size={23}
              color={focused ? theme.tabBarActive : theme.tabBarInactive}
            />
          ),
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <Ionicons
              name={focused ? 'settings' : 'settings-outline'}
              size={23}
              color={focused ? theme.tabBarActive : theme.tabBarInactive}
            />
          ),
        }}
      />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  tabBar: {
    borderTopWidth: 1,
    height: 88,
    paddingBottom: 28,
    paddingTop: 10,
    position: 'absolute',
  },
  tabBarLabel: {
    fontSize: 10,
    fontWeight: '500',
    marginTop: 2,
  },
  recordButton: {
    top: -22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButtonInner: {
    width: 58,
    height: 58,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 8,
  },
});
