export interface Theme {
  // Primary colors
  primary: string;
  primaryLight: string;
  primaryDark: string;

  // Background colors
  background: string;
  backgroundSecondary: string;
  cardBackground: string;
  cardBackgroundElevated: string;

  // Text colors
  textPrimary: string;
  textSecondary: string;
  textMuted: string;
  textInverse: string;

  // Accent colors
  accent: string;
  accentGreen: string;
  accentYellow: string;
  accentRed: string;
  accentBlue: string;
  accentOlive: string;

  // Border colors
  border: string;
  borderLight: string;

  // Status colors
  success: string;
  warning: string;
  error: string;
  info: string;

  // Tab bar
  tabBarBackground: string;
  tabBarActive: string;
  tabBarInactive: string;

  // Button colors
  buttonPrimary: string;
  buttonPrimaryText: string;
  buttonSecondary: string;
  buttonSecondaryText: string;

  // Shadows
  shadowColor: string;

  // Overlay colors
  overlayDark: string;
  overlayLight: string;

  // Mode
  isDark: boolean;
}

export const DarkTheme: Theme = {
  // Primary - Modern teal/cyan gradient feel
  primary: '#00D4AA',
  primaryLight: '#00F5C4',
  primaryDark: '#00B894',

  // Background colors - Deep, rich blacks with warmth
  background: '#0C0C0C',
  backgroundSecondary: '#141414',
  cardBackground: '#1A1A1A',
  cardBackgroundElevated: '#222222',

  // Text colors
  textPrimary: '#FFFFFF',
  textSecondary: '#9CA3AF',
  textMuted: '#6B7280',
  textInverse: '#0C0C0C',

  // Accent colors
  accent: '#00D4AA',
  accentGreen: '#22C55E',
  accentYellow: '#FACC15',
  accentRed: '#EF4444',
  accentBlue: '#3B82F6',
  accentOlive: '#4A5D23',

  // Border colors
  border: '#2A2A2A',
  borderLight: '#3A3A3A',

  // Status colors
  success: '#22C55E',
  warning: '#FACC15',
  error: '#EF4444',
  info: '#3B82F6',

  // Tab bar
  tabBarBackground: '#0C0C0C',
  tabBarActive: '#00D4AA',
  tabBarInactive: '#6B7280',

  // Button colors
  buttonPrimary: '#00D4AA',
  buttonPrimaryText: '#0C0C0C',
  buttonSecondary: '#2A2A2A',
  buttonSecondaryText: '#FFFFFF',

  // Shadows
  shadowColor: '#000000',

  // Overlay colors
  overlayDark: 'rgba(0, 0, 0, 0.7)',
  overlayLight: 'rgba(0, 0, 0, 0.4)',

  isDark: true,
};

export const LightTheme: Theme = {
  // Primary - Same vibrant teal
  primary: '#00B894',
  primaryLight: '#00D4AA',
  primaryDark: '#009B7D',

  // Background colors - Warm cream/off-white tones
  background: '#F5F3EF',
  backgroundSecondary: '#EEEBE5',
  cardBackground: '#FFFFFF',
  cardBackgroundElevated: '#F8F6F2',

  // Text colors
  textPrimary: '#1A1A1A',
  textSecondary: '#5C5C5C',
  textMuted: '#8A8A8A',
  textInverse: '#FFFFFF',

  // Accent colors
  accent: '#00B894',
  accentGreen: '#4A5D23',
  accentYellow: '#C9A227',
  accentRed: '#C53030',
  accentBlue: '#2563EB',
  accentOlive: '#4A5D23',

  // Border colors
  border: '#E5E2DC',
  borderLight: '#D1CEC6',

  // Status colors
  success: '#4A5D23',
  warning: '#C9A227',
  error: '#C53030',
  info: '#2563EB',

  // Tab bar
  tabBarBackground: '#F5F3EF',
  tabBarActive: '#00B894',
  tabBarInactive: '#8A8A8A',

  // Button colors
  buttonPrimary: '#00B894',
  buttonPrimaryText: '#FFFFFF',
  buttonSecondary: '#E5E2DC',
  buttonSecondaryText: '#1A1A1A',

  // Shadows
  shadowColor: '#5C5C5C',

  // Overlay colors
  overlayDark: 'rgba(0, 0, 0, 0.6)',
  overlayLight: 'rgba(0, 0, 0, 0.3)',

  isDark: false,
};
