import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { ThemeProvider, useTheme } from './src/context/ThemeContext';
import { TabNavigator } from './src/navigation';

function AppContent() {
  const { theme } = useTheme();

  return (
    <NavigationContainer>
      <StatusBar style={theme.isDark ? 'light' : 'dark'} />
      <TabNavigator />
    </NavigationContainer>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  );
}
