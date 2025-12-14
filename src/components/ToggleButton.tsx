import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Colors } from '../constants/colors';

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
  return (
    <View style={styles.container}>
      {options.map((option, index) => (
        <TouchableOpacity
          key={option}
          style={[
            styles.option,
            index === selectedIndex && styles.selectedOption,
          ]}
          onPress={() => onSelect(index)}
        >
          <Text
            style={[
              styles.optionText,
              index === selectedIndex && styles.selectedText,
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
    backgroundColor: Colors.cardBackground,
    borderRadius: 8,
    padding: 4,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  option: {
    flex: 1,
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 6,
    alignItems: 'center',
  },
  selectedOption: {
    backgroundColor: Colors.textPrimary,
  },
  optionText: {
    color: Colors.textSecondary,
    fontSize: 14,
    fontWeight: '500',
  },
  selectedText: {
    color: Colors.background,
  },
});
