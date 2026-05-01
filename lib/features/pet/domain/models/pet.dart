enum PetMood { happy, neutral, sad, excited, sleeping }

class Pet {
  final String name;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int coins;
  final List<String> equippedAccessories;
  final PetMood mood;

  const Pet({
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
    String? name,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? coins,
    List<String>? equippedAccessories,
    PetMood? mood,
  }) {
    return Pet(
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
