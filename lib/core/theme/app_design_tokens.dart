import 'package:flutter/material.dart';

class AppDesignTokens extends ThemeExtension<AppDesignTokens> {
  // Spacing scale (8px base)
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double space2xl;

  // Elevation
  final double elevationNone;
  final double elevationCard;
  final double elevationOverlay;

  const AppDesignTokens({
    this.spaceXs = 4,
    this.spaceSm = 8,
    this.spaceMd = 16,
    this.spaceLg = 24,
    this.spaceXl = 32,
    this.space2xl = 48,
    this.elevationNone = 0,
    this.elevationCard = 2,
    this.elevationOverlay = 8,
  });

  static const light = AppDesignTokens();

  static const dark = AppDesignTokens();

  @override
  AppDesignTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? space2xl,
    double? elevationNone,
    double? elevationCard,
    double? elevationOverlay,
  }) {
    return AppDesignTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      space2xl: space2xl ?? this.space2xl,
      elevationNone: elevationNone ?? this.elevationNone,
      elevationCard: elevationCard ?? this.elevationCard,
      elevationOverlay: elevationOverlay ?? this.elevationOverlay,
    );
  }

  @override
  AppDesignTokens lerp(ThemeExtension<AppDesignTokens>? other, double t) {
    if (other is! AppDesignTokens) return this;
    return AppDesignTokens(
      spaceXs: spaceXs + (other.spaceXs - spaceXs) * t,
      spaceSm: spaceSm + (other.spaceSm - spaceSm) * t,
      spaceMd: spaceMd + (other.spaceMd - spaceMd) * t,
      spaceLg: spaceLg + (other.spaceLg - spaceLg) * t,
      spaceXl: spaceXl + (other.spaceXl - spaceXl) * t,
      space2xl: space2xl + (other.space2xl - space2xl) * t,
      elevationNone: elevationNone,
      elevationCard: elevationCard,
      elevationOverlay: elevationOverlay,
    );
  }
}
