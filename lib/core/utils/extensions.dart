import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  String toFormattedString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
