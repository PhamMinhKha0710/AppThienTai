import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

/// EmergencySoundService - Handles emergency sounds and vibrations
class EmergencySoundService extends GetxService {
  static EmergencySoundService get instance => Get.find<EmergencySoundService>();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Observable state
  final isPlaying = false.obs;
  final isVibrating = false.obs;
  final hasVibrator = false.obs;
  
  // Duration settings
  static const Duration defaultVibrationDuration = Duration(seconds: 5);
  static const Duration defaultSoundDuration = Duration(seconds: 10);

  /// Initialize the service
  Future<EmergencySoundService> init() async {
    // Check if device has vibrator
    try {
      final hasVibratorResult = await Vibration.hasVibrator();
      hasVibrator.value = hasVibratorResult == true;
    } catch (e) {
      hasVibrator.value = false;
      debugPrint('[EmergencySoundService] Error checking vibrator: $e');
    }
    
    // Set audio player settings
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    debugPrint('[EmergencySoundService] Initialized. Has vibrator: ${hasVibrator.value}');
    
    return this;
  }

  /// Play emergency alert sound
  Future<void> playEmergencySound({Duration? duration}) async {
    if (isPlaying.value) return;
    
    try {
      isPlaying.value = true;
      
      // Play built-in alarm sound or use asset
      await _audioPlayer.play(
        AssetSource('images/animations/emergency_alarm.mp3'),
        volume: 1.0,
      );
      
      // Stop after duration
      final stopDuration = duration ?? defaultSoundDuration;
      Future.delayed(stopDuration, () {
        if (isPlaying.value) {
          stopSound();
        }
      });
      
      debugPrint('[EmergencySoundService] Playing emergency sound');
    } catch (e) {
      debugPrint('[EmergencySoundService] Error playing sound: $e');
      isPlaying.value = false;
      
      // Fallback: Use system notification sound
      await _playSystemSound();
    }
  }

  /// Play system notification sound as fallback
  Future<void> _playSystemSound() async {
    try {
      // Use a simple beep pattern with vibration as fallback
      await startVibration(pattern: [0, 500, 200, 500, 200, 500]);
    } catch (e) {
      debugPrint('[EmergencySoundService] Error playing system sound: $e');
    }
  }

  /// Stop emergency sound
  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      debugPrint('[EmergencySoundService] Sound stopped');
    } catch (e) {
      debugPrint('[EmergencySoundService] Error stopping sound: $e');
    }
  }

  /// Start vibration
  Future<void> startVibration({
    Duration? duration,
    List<int>? pattern,
  }) async {
    if (!hasVibrator.value || isVibrating.value) return;
    
    try {
      isVibrating.value = true;
      
      if (pattern != null) {
        // Use custom pattern: [wait, vibrate, wait, vibrate, ...]
        await Vibration.vibrate(pattern: pattern);
      } else {
        // Default emergency vibration pattern
        // Pattern: vibrate 1s, pause 0.5s, vibrate 1s, pause 0.5s...
        final emergencyPattern = [0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000];
        await Vibration.vibrate(pattern: emergencyPattern);
      }
      
      // Stop after duration
      final stopDuration = duration ?? defaultVibrationDuration;
      Future.delayed(stopDuration, () {
        if (isVibrating.value) {
          stopVibration();
        }
      });
      
      debugPrint('[EmergencySoundService] Vibration started');
    } catch (e) {
      debugPrint('[EmergencySoundService] Error starting vibration: $e');
      isVibrating.value = false;
    }
  }

  /// Stop vibration
  Future<void> stopVibration() async {
    try {
      await Vibration.cancel();
      isVibrating.value = false;
      debugPrint('[EmergencySoundService] Vibration stopped');
    } catch (e) {
      debugPrint('[EmergencySoundService] Error stopping vibration: $e');
    }
  }

  /// Trigger full emergency alert (sound + vibration)
  Future<void> triggerEmergencyAlert({
    Duration? soundDuration,
    Duration? vibrationDuration,
  }) async {
    debugPrint('[EmergencySoundService] Triggering emergency alert');
    
    // Start both simultaneously
    await Future.wait([
      playEmergencySound(duration: soundDuration),
      startVibration(duration: vibrationDuration),
    ]);
  }

  /// Stop all alerts
  Future<void> stopAllAlerts() async {
    await Future.wait([
      stopSound(),
      stopVibration(),
    ]);
    debugPrint('[EmergencySoundService] All alerts stopped');
  }

  /// Quick vibration for normal notifications
  Future<void> quickVibration() async {
    if (!hasVibrator.value) return;
    
    try {
      await Vibration.vibrate(duration: 200);
    } catch (e) {
      debugPrint('[EmergencySoundService] Error quick vibration: $e');
    }
  }

  /// Double vibration for important notifications
  Future<void> doubleVibration() async {
    if (!hasVibrator.value) return;
    
    try {
      await Vibration.vibrate(pattern: [0, 200, 100, 200]);
    } catch (e) {
      debugPrint('[EmergencySoundService] Error double vibration: $e');
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}

