import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum PetMood { happy, neutral, sad, excited, sleeping }

enum PetType {
  bibu(
    name: 'Bibu',
    defaultEmoji: '🐣',
    evolvedEmoji: '🦄',
    colors: [AppColors.primaryLight, AppColors.accentLight],
    evolvedColors: [Color(0xFFFFD700), Color(0xFFFF6B8A)],
    description: 'Una criatura mágica que evoluciona contigo',
  ),
  chihuahua(
    name: 'Chihuahua',
    defaultEmoji: '🐕',
    evolvedEmoji: '🦁',
    colors: [Color(0xFFD4A574), Color(0xFFF5D6B8)],
    evolvedColors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
    description: 'Un perrito pequeño pero con gran personalidad',
  ),
  cat(
    name: 'Gato',
    defaultEmoji: '😺',
    evolvedEmoji: '🐱',
    colors: [Color(0xFF9E9E9E), Color(0xFFE0E0E0)],
    evolvedColors: [Color(0xFF616161), Color(0xFF9E9E9E)],
    description: 'Un felino curioso y elegante',
  ),
  rabbit(
    name: 'Conejo',
    defaultEmoji: '🐰',
    evolvedEmoji: '🐇',
    colors: [Color(0xFFFFB6C1), Color(0xFFFFE4E1)],
    evolvedColors: [Color(0xFFFF69B4), Color(0xFFFFB6C1)],
    description: 'Suave, rápido y siempre saltando',
  ),
  dragon(
    name: 'Dragón',
    defaultEmoji: '🐲',
    evolvedEmoji: '🐉',
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    evolvedColors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    description: 'Una bestia legendaria llena de poder',
  );

  final String name;
  final String defaultEmoji;
  final String evolvedEmoji;
  final List<Color> colors;
  final List<Color> evolvedColors;
  final String description;

  const PetType({
    required this.name,
    required this.defaultEmoji,
    required this.evolvedEmoji,
    required this.colors,
    required this.evolvedColors,
    required this.description,
  });

  String getEmoji(int level) {
    if (level >= 15) return evolvedEmoji;
    if (level >= 10) return '🐉';
    if (level >= 5) return '🐱';
    if (level >= 3) return '🐰';
    return defaultEmoji;
  }

  List<Color> getColors(int level) {
    if (level >= 10) return evolvedColors;
    if (level >= 5) return [AppColors.primary, AppColors.accent];
    if (level >= 3) return [AppColors.success, AppColors.accent];
    return colors;
  }
}

class Pet {
  final PetType petType;
  final String name;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int coins;
  final List<String> equippedAccessories;
  final PetMood mood;

  const Pet({
    this.petType = PetType.bibu,
    this.name = 'Bibu',
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.coins = 0,
    this.equippedAccessories = const [],
    this.mood = PetMood.neutral,
  });

  double get xpProgress => currentXp / xpToNextLevel;

  Pet copyWith({
    PetType? petType,
    String? name,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? coins,
    List<String>? equippedAccessories,
    PetMood? mood,
  }) {
    return Pet(
      petType: petType ?? this.petType,
      name: name ?? this.name,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      coins: coins ?? this.coins,
      equippedAccessories: equippedAccessories ?? this.equippedAccessories,
      mood: mood ?? this.mood,
    );
  }

  Pet addXp(int xp) {
    var newXp = currentXp + xp;
    var newLevel = level;
    var newXpToNext = xpToNextLevel;

    while (newXp >= newXpToNext) {
      newXp -= newXpToNext;
      newLevel++;
      newXpToNext = _calculateXpForLevel(newLevel);
    }

    return copyWith(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newXpToNext,
    );
  }

  Pet addCoins(int amount) => copyWith(coins: coins + amount);

  Pet spendCoins(int amount) {
    if (coins < amount) return this;
    return copyWith(coins: coins - amount);
  }

  Pet equipAccessory(String accessoryId) {
    final accessories = List<String>.from(equippedAccessories);
    if (accessories.contains(accessoryId)) {
      accessories.remove(accessoryId);
    } else {
      accessories.add(accessoryId);
    }
    return copyWith(equippedAccessories: accessories);
  }

  int _calculateXpForLevel(int level) => (100 * level * 1.5).round();
}