import 'package:flutter/material.dart';
import '../../features/pet/domain/models/pet_accessory.dart';

enum SeasonalThemeType {
  none,
  halloween,
  christmas,
  valentine,
  easter,
}

class SeasonalTheme {
  final SeasonalThemeType type;
  final String name;
  final String icon;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final Color accentColor;
  final List<PetAccessory> specialAccessories;

  const SeasonalTheme({
    required this.type,
    required this.name,
    required this.icon,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.accentColor,
    required this.specialAccessories,
  });

  bool isActive(DateTime date) {
    final start = DateTime(date.year, startMonth, startDay);
    final end = DateTime(date.year, endMonth, endDay);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  static const all = [
    SeasonalTheme(
      type: SeasonalThemeType.halloween,
      name: 'Halloween',
      icon: '🎃',
      startMonth: 10,
      startDay: 25,
      endMonth: 11,
      endDay: 2,
      accentColor: Color(0xFFFF6D00),
      specialAccessories: [
        PetAccessory(
          id: 'seasonal_halloween_hat',
          name: 'Sombrero bruja',
          icon: '🎩',
          type: AccessoryType.hat,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
        PetAccessory(
          id: 'seasonal_halloween_bg',
          name: 'Fondo terrorífico',
          icon: '👻',
          type: AccessoryType.background,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
      ],
    ),
    SeasonalTheme(
      type: SeasonalThemeType.christmas,
      name: 'Navidad',
      icon: '🎄',
      startMonth: 12,
      startDay: 15,
      endMonth: 1,
      endDay: 2,
      accentColor: Color(0xFFE53935),
      specialAccessories: [
        PetAccessory(
          id: 'seasonal_xmas_hat',
          name: 'Gorro navideño',
          icon: '🎅',
          type: AccessoryType.hat,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
        PetAccessory(
          id: 'seasonal_xmas_bg',
          name: 'Fondo nevado',
          icon: '❄️',
          type: AccessoryType.background,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
      ],
    ),
    SeasonalTheme(
      type: SeasonalThemeType.valentine,
      name: 'San Valentín',
      icon: '💝',
      startMonth: 2,
      startDay: 10,
      endMonth: 2,
      endDay: 16,
      accentColor: Color(0xFFFF6B8A),
      specialAccessories: [
        PetAccessory(
          id: 'seasonal_val_glasses',
          name: 'Gafas corazón',
          icon: '😍',
          type: AccessoryType.glasses,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
        PetAccessory(
          id: 'seasonal_val_bg',
          name: 'Fondo romántico',
          icon: '💕',
          type: AccessoryType.background,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
      ],
    ),
    SeasonalTheme(
      type: SeasonalThemeType.easter,
      name: 'Pascua',
      icon: '🐰',
      startMonth: 3,
      startDay: 25,
      endMonth: 4,
      endDay: 10,
      accentColor: Color(0xFF66BB6A),
      specialAccessories: [
        PetAccessory(
          id: 'seasonal_easter_hat',
          name: 'Orejas conejo',
          icon: '🐰',
          type: AccessoryType.hat,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
        PetAccessory(
          id: 'seasonal_easter_bg',
          name: 'Fondo primaveral',
          icon: '🌸',
          type: AccessoryType.background,
          price: 0,
          unlockLevel: 0,
          isOwned: true,
        ),
      ],
    ),
  ];

  static SeasonalTheme? current(DateTime date) {
    for (final theme in all) {
      if (theme.isActive(date)) return theme;
    }
    return null;
  }

  static bool isSeasonalAccessory(String id) {
    return id.startsWith('seasonal_');
  }
}
