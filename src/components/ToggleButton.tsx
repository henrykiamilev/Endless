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
        backgroundColor: theme.cardBackgroundElevated,
        borderColor: theme.border,
      }
    ]}>
      {options.map((option, index) => (
        <TouchableOpacity
          key={option}
          style={[
            styles.option,
            index === selectedIndex && [
              styles.selectedOption,
              { backgroundColor: theme.primary }
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
            {option}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    borderRadius: 12,
    padding: 4,
    borderWidth: 1,
  },
  option: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  selectedOption: {},
  optionText: {
    fontSize: 14,
    fontWeight: '500',
  },
  selectedText: {
    fontWeight: '600',
  },
});
