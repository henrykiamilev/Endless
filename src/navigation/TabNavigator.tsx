import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../constants/colors';
import {
  HomeScreen,
  VideoLibraryScreen,
  RecordScreen,
  EndlessAIScreen,
  SettingsScreen,
} from '../screens';

const Tab = createBottomTabNavigator();

interface TabBarIconProps {
  name: keyof typeof Ionicons.glyphMap;
  focused: boolean;
}

const TabBarIcon: React.FC<TabBarIconProps> = ({ name, focused }) => (
  <Ionicons
    name={name}
    size={24}
    color={focused ? Colors.tabBarActive : Colors.tabBarInactive}
  />
);

interface CustomRecordButtonProps {
  onPress?: () => void;
}

const CustomRecordButton: React.FC<CustomRecordButtonProps> = ({ onPress }) => (
  <TouchableOpacity style={styles.recordButton} onPress={onPress}>
    <View style={styles.recordButtonInner}>
      <Ionicons name="add" size={32} color={Colors.textPrimary} />
    </View>
  </TouchableOpacity>
);

export const TabNavigator: React.FC = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: styles.tabBar,
        tabBarActiveTintColor: Colors.tabBarActive,
        tabBarInactiveTintColor: Colors.tabBarInactive,
        tabBarShowLabel: true,
        tabBarLabelStyle: styles.tabBarLabel,
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabBarIcon name={focused ? 'home' : 'home-outline'} focused={focused} />
          ),
        }}
      />
      <Tab.Screen
        name="Video"
        component={VideoLibraryScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabBarIcon name={focused ? 'videocam' : 'videocam-outline'} focused={focused} />
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
            <TabBarIcon name={focused ? 'sparkles' : 'sparkles-outline'} focused={focused} />
          ),
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <TabBarIcon name={focused ? 'settings' : 'settings-outline'} focused={focused} />
          ),
        }}
      />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: Colors.tabBarBackground,
    borderTopColor: Colors.border,
    borderTopWidth: 1,
    height: 85,
    paddingBottom: 25,
    paddingTop: 8,
    position: 'absolute',
  },
  tabBarLabel: {
    fontSize: 10,
    fontWeight: '500',
    marginTop: 2,
  },
  recordButton: {
    top: -20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButtonInner: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
});
