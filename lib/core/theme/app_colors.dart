import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFF7C5CFC);
  static const primaryLight = Color(0xFFB19DFF);
  static const primaryDark = Color(0xFF5A3FCF);

  static const secondary = Color(0xFFFF6B8A);
  static const secondaryLight = Color(0xFFFFA3B5);

  static const accent = Color(0xFF36D6E7);
  static const accentLight = Color(0xFF7DE8F3);

  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFB923C);
  static const error = Color(0xFFF87171);

  static const backgroundLight = Color(0xFFF8F7FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);

  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textTertiaryLight = Color(0xFF9CA3AF);

  static const backgroundDark = Color(0xFF0F0F1A);
  static const surfaceDark = Color(0xFF1A1A2E);
  static const cardDark = Color(0xFF242442);

  static const textPrimaryDark = Color(0xFFF1F1F6);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const textTertiaryDark = Color(0xFF6B7280);

  static const gradientWarm = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCool = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
