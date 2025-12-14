import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  Alert,
} from 'react-native';
import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeContext';

export const RecordScreen: React.FC = () => {
  const { theme } = useTheme();
  const [facing, setFacing] = useState<CameraType>('back');
  const [isRecording, setIsRecording] = useState(false);
  const [permission, requestPermission] = useCameraPermissions();
  const cameraRef = useRef<CameraView>(null);

  if (!permission) {
    return (
      <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
        <View style={styles.permissionContainer}>
          <Text style={[styles.permissionText, { color: theme.textSecondary }]}>Loading camera...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (!permission.granted) {
    return (
      <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
        <View style={styles.permissionContainer}>
          <View style={[styles.permissionIconBg, { backgroundColor: `${theme.primary}20` }]}>
            <Ionicons name="camera" size={48} color={theme.primary} />
          </View>
          <Text style={[styles.permissionTitle, { color: theme.textPrimary }]}>Camera Access Required</Text>
          <Text style={[styles.permissionText, { color: theme.textSecondary }]}>
            We need camera access to record your golf swings and practice sessions.
          </Text>
          <TouchableOpacity
            style={[styles.permissionButton, { backgroundColor: theme.primary }]}
            onPress={requestPermission}
          >
            <Text style={[styles.permissionButtonText, { color: theme.textInverse }]}>Grant Permission</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  const toggleCameraFacing = () => {
    setFacing(current => (current === 'back' ? 'front' : 'back'));
  };

  const handleRecord = async () => {
    if (isRecording) {
      setIsRecording(false);
      Alert.alert('Recording Stopped', 'Your video has been saved.');
    } else {
      setIsRecording(true);
    }
  };

  return (
    <View style={styles.container}>
      <CameraView
        ref={cameraRef}
        style={styles.camera}
        facing={facing}
        mode="video"
      >
        {/* Top Controls */}
        <SafeAreaView style={styles.topControls}>
          <TouchableOpacity style={styles.topButton}>
            <Ionicons name="close" size={26} color="#FFFFFF" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.topButton}>
            <Ionicons name="flash-off" size={22} color="#FFFFFF" />
          </TouchableOpacity>
        </SafeAreaView>

        {/* Recording Indicator */}
        {isRecording && (
          <View style={styles.recordingIndicator}>
            <View style={styles.recordingDot} />
            <Text style={styles.recordingText}>REC</Text>
          </View>
        )}

        {/* Bottom Controls */}
        <View style={styles.bottomControls}>
          {/* Gallery Button */}
          <TouchableOpacity style={styles.sideButton}>
            <Ionicons name="images" size={26} color="#FFFFFF" />
          </TouchableOpacity>

          {/* Record Button */}
          <TouchableOpacity
            style={[
              styles.recordButton,
              isRecording && styles.recordButtonActive,
            ]}
            onPress={handleRecord}
          >
            <View
              style={[
                styles.recordButtonInner,
                { backgroundColor: theme.error },
                isRecording && styles.recordButtonInnerActive,
              ]}
            />
          </TouchableOpacity>

          {/* Flip Camera Button */}
          <TouchableOpacity style={styles.sideButton} onPress={toggleCameraFacing}>
            <Ionicons name="camera-reverse" size={26} color="#FFFFFF" />
          </TouchableOpacity>
        </View>

        {/* Mode Selector */}
        <View style={styles.modeSelector}>
          <TouchableOpacity style={styles.modeButton}>
            <Text style={styles.modeTextInactive}>Photo</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.modeButton, styles.modeButtonActive]}>
            <Text style={styles.modeText}>Video</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.modeButton}>
            <Text style={styles.modeTextInactive}>Slo-Mo</Text>
          </TouchableOpacity>
        </View>
      </CameraView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
  },
  camera: {
    flex: 1,
  },
  permissionContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  permissionIconBg: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  permissionTitle: {
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 12,
    textAlign: 'center',
  },
  permissionText: {
    fontSize: 15,
    textAlign: 'center',
    marginBottom: 32,
    lineHeight: 22,
  },
  permissionButton: {
    paddingVertical: 14,
    paddingHorizontal: 36,
    borderRadius: 12,
  },
  permissionButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  topControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 12,
  },
  topButton: {
    width: 46,
    height: 46,
    borderRadius: 23,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordingIndicator: {
    position: 'absolute',
    top: 110,
    alignSelf: 'center',
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingVertical: 8,
    paddingHorizontal: 14,
    borderRadius: 20,
  },
  recordingDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: '#EF4444',
    marginRight: 8,
  },
  recordingText: {
    color: '#EF4444',
    fontSize: 13,
    fontWeight: '700',
  },
  bottomControls: {
    position: 'absolute',
    bottom: 130,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  sideButton: {
    width: 54,
    height: 54,
    borderRadius: 27,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 36,
  },
  recordButton: {
    width: 84,
    height: 84,
    borderRadius: 42,
    borderWidth: 4,
    borderColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButtonActive: {
    borderColor: '#EF4444',
  },
  recordButtonInner: {
    width: 68,
    height: 68,
    borderRadius: 34,
  },
  recordButtonInnerActive: {
    width: 34,
    height: 34,
    borderRadius: 6,
  },
  modeSelector: {
    position: 'absolute',
    bottom: 60,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modeButton: {
    paddingVertical: 10,
    paddingHorizontal: 18,
  },
  modeButtonActive: {
    borderBottomWidth: 2,
    borderBottomColor: '#FFFFFF',
  },
  modeText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
  },
  modeTextInactive: {
    color: 'rgba(255, 255, 255, 0.6)',
    fontSize: 15,
  },
});
