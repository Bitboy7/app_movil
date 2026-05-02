import 'package:flutter/services.dart';

enum SoundEvent {
  taskComplete,
  levelUp,
  allDone,
  petInteraction,
  buyAccessory,
  equipAccessory,
  loginSuccess,
  taskPostpone,
  error,
}

class SoundService {
  static bool _enabled = true;

  static bool get enabled => _enabled;
  static set enabled(bool value) => _enabled = value;

  static void play(SoundEvent event) {
    if (!_enabled) return;
    switch (event) {
      case SoundEvent.taskComplete:
        SystemSound.play(SystemSoundType.click);
      case SoundEvent.levelUp:
        HapticFeedback.heavyImpact();
      case SoundEvent.allDone:
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
      case SoundEvent.petInteraction:
        HapticFeedback.lightImpact();
      case SoundEvent.buyAccessory:
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
      case SoundEvent.equipAccessory:
        HapticFeedback.selectionClick();
      case SoundEvent.loginSuccess:
        SystemSound.play(SystemSoundType.click);
      case SoundEvent.taskPostpone:
        HapticFeedback.lightImpact();
      case SoundEvent.error:
        HapticFeedback.heavyImpact();
    }
  }
}
