import React from 'react';
import { View, StyleSheet } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';
import { useTheme } from '../context/ThemeContext';

interface EndlessLogoProps {
  size?: number;
  color?: string;
  showBackground?: boolean;
}

export const EndlessLogo: React.FC<EndlessLogoProps> = ({
  size = 40,
  color,
  showBackground = true,
}) => {
  const { theme } = useTheme();
  const logoColor = color || theme.textPrimary;
  const bgColor = theme.isDark ? '#1F1F23' : '#F1F5F9';

  return (
    <View style={[
      styles.container,
      showBackground && {
        backgroundColor: bgColor,
        width: size * 1.4,
        height: size * 1.4,
        borderRadius: (size * 1.4) / 2,
      }
    ]}>
      <Svg width={size} height={size} viewBox="0 0 100 100">
        {/* Infinity symbol */}
        <Path
          d="M50 35
             C35 35 25 45 25 50
             C25 55 35 65 50 65
             C65 65 75 55 75 50
             C75 45 65 35 50 35
             M50 35
             C65 35 75 45 75 50
             C75 55 65 65 50 65
             C35 65 25 55 25 50
             C25 45 35 35 50 35"
          stroke={logoColor}
          strokeWidth="6"
          fill="none"
          strokeLinecap="round"
        />
      </Svg>
    </View>
  );
};

// Simple text-based infinity for fallback
export const EndlessLogoSimple: React.FC<EndlessLogoProps> = ({
  size = 40,
  color,
  showBackground = true,
}) => {
  const { theme } = useTheme();
  const logoColor = color || theme.textPrimary;
  const bgColor = theme.isDark ? '#27272A' : '#E2E8F0';

  return (
    <View style={[
      styles.simpleContainer,
      showBackground && {
        backgroundColor: bgColor,
        width: size,
        height: size,
        borderRadius: size / 2,
        borderWidth: 2,
        borderColor: theme.border,
      }
    ]}>
      <View style={styles.infinityContainer}>
        <View style={[styles.infinityLoop, styles.infinityLeft, { borderColor: logoColor }]} />
        <View style={[styles.infinityLoop, styles.infinityRight, { borderColor: logoColor }]} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  simpleContainer: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  infinityContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infinityLoop: {
    width: 12,
    height: 8,
    borderWidth: 2,
    borderRadius: 6,
  },
  infinityLeft: {
    marginRight: -3,
  },
  infinityRight: {
    marginLeft: -3,
  },
});
