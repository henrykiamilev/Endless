import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useTheme } from '../context/ThemeContext';

interface ToggleButtonProps {
  options: string[];
  selectedIndex: number;
  onSelect: (index: number) => void;
}

export const ToggleButton: React.FC<ToggleButtonProps> = ({
  options,
  selectedIndex,
  onSelect,
}) => {
  const { theme } = useTheme();

  return (
    <View style={[
      styles.container,
      {
        backgroundColor: theme.cardBackground,
      }
    ]}>
      {options.map((option, index) => (
        <TouchableOpacity
          key={option}
          style={[
            styles.option,
            index === selectedIndex && [
              styles.selectedOption,
              { backgroundColor: theme.textPrimary }
            ],
          ]}
          onPress={() => onSelect(index)}
          activeOpacity={0.7}
        >
          <Text
            style={[
              styles.optionText,
              { color: theme.textSecondary },
              index === selectedIndex && [
                styles.selectedText,
                { color: theme.textInverse }
              ],
            ]}
          >
            {option.toUpperCase()}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    borderRadius: 30,
    padding: 4,
  },
  option: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 26,
    alignItems: 'center',
  },
  selectedOption: {},
  optionText: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  selectedText: {
    fontWeight: '700',
  },
});
