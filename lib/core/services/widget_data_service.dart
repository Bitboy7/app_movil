import 'package:flutter/services.dart';

class WidgetDataService {
  static const _channel = MethodChannel('bibu.app/widget');

  static Future<void> updatePetData({
    required String petName,
    required int level,
    required String emoji,
    required int coins,
    required int streak,
    required String mood,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'petName': petName,
        'level': level,
        'emoji': emoji,
        'coins': coins,
        'streak': streak,
        'mood': mood,
      });
    } catch (_) {}
  }
}
