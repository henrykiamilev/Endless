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

  // Mode
  isDark: boolean;
}

export const DarkTheme: Theme = {
  // Primary - Modern teal/cyan gradient feel
  primary: '#00D4AA',
  primaryLight: '#00F5C4',
  primaryDark: '#00B894',

  // Background colors - Deep, rich blacks
  background: '#0A0A0B',
  backgroundSecondary: '#111113',
  cardBackground: '#18181B',
  cardBackgroundElevated: '#1F1F23',

  // Text colors
  textPrimary: '#FFFFFF',
  textSecondary: '#A1A1AA',
  textMuted: '#71717A',
  textInverse: '#0A0A0B',

  // Accent colors
  accent: '#00D4AA',
  accentGreen: '#22C55E',
  accentYellow: '#FACC15',
  accentRed: '#EF4444',
  accentBlue: '#3B82F6',

  // Border colors
  border: '#27272A',
  borderLight: '#3F3F46',

  // Status colors
  success: '#22C55E',
  warning: '#FACC15',
  error: '#EF4444',
  info: '#3B82F6',

  // Tab bar
  tabBarBackground: '#0A0A0B',
  tabBarActive: '#00D4AA',
  tabBarInactive: '#71717A',

  // Button colors
  buttonPrimary: '#00D4AA',
  buttonPrimaryText: '#0A0A0B',
  buttonSecondary: '#27272A',
  buttonSecondaryText: '#FFFFFF',

  // Shadows
  shadowColor: '#000000',

  isDark: true,
};

export const LightTheme: Theme = {
  // Primary - Same vibrant teal
  primary: '#00B894',
  primaryLight: '#00D4AA',
  primaryDark: '#009B7D',

  // Background colors - Clean whites and grays
  background: '#FFFFFF',
  backgroundSecondary: '#F8FAFC',
  cardBackground: '#FFFFFF',
  cardBackgroundElevated: '#F1F5F9',

  // Text colors
  textPrimary: '#0F172A',
  textSecondary: '#64748B',
  textMuted: '#94A3B8',
  textInverse: '#FFFFFF',

  // Accent colors
  accent: '#00B894',
  accentGreen: '#16A34A',
  accentYellow: '#EAB308',
  accentRed: '#DC2626',
  accentBlue: '#2563EB',

  // Border colors
  border: '#E2E8F0',
  borderLight: '#CBD5E1',

  // Status colors
  success: '#16A34A',
  warning: '#EAB308',
  error: '#DC2626',
  info: '#2563EB',

  // Tab bar
  tabBarBackground: '#FFFFFF',
  tabBarActive: '#00B894',
  tabBarInactive: '#94A3B8',

  // Button colors
  buttonPrimary: '#00B894',
  buttonPrimaryText: '#FFFFFF',
  buttonSecondary: '#F1F5F9',
  buttonSecondaryText: '#0F172A',

  // Shadows
  shadowColor: '#64748B',

  isDark: false,
};
