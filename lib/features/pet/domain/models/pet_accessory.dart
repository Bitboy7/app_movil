enum AccessoryType { hat, glasses, background, petEffect }

class PetAccessory {
  final String id;
  final String name;
  final String icon;
  final AccessoryType type;
  final int price;
  final int unlockLevel;
  final bool isOwned;

  const PetAccessory({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.price = 50,
    this.unlockLevel = 0,
    this.isOwned = false,
  });

  PetAccessory copyWith({
    String? id,
    String? name,
    String? icon,
    AccessoryType? type,
    int? price,
    int? unlockLevel,
    bool? isOwned,
  }) {
    return PetAccessory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      price: price ?? this.price,
      unlockLevel: unlockLevel ?? this.unlockLevel,
      isOwned: isOwned ?? this.isOwned,
    );
  }
}

final defaultAccessories = [
  const PetAccessory(
    id: 'hat_explorer',
    name: 'Sombrero explorador',
    icon: '🎩',
    type: AccessoryType.hat,
    price: 50,
  ),
  const PetAccessory(
    id: 'hat_crown',
    name: 'Corona real',
    icon: '👑',
    type: AccessoryType.hat,
    price: 200,
    unlockLevel: 5,
  ),
  const PetAccessory(
    id: 'hat_straw',
    name: 'Sombrero de paja',
    icon: '🤠',
    type: AccessoryType.hat,
    price: 75,
    unlockLevel: 2,
  ),
  const PetAccessory(
    id: 'glasses_cool',
    name: 'Gafas cool',
    icon: '😎',
    type: AccessoryType.glasses,
    price: 100,
  ),
  const PetAccessory(
    id: 'glasses_nerd',
    name: 'Gafas de estudio',
    icon: '🤓',
    type: AccessoryType.glasses,
    price: 80,
    unlockLevel: 1,
  ),
  const PetAccessory(
    id: 'bg_forest',
    name: 'Fondo bosque',
    icon: '🌲',
    type: AccessoryType.background,
    price: 150,
    unlockLevel: 3,
  ),
  const PetAccessory(
    id: 'bg_space',
    name: 'Fondo espacial',
    icon: '🚀',
    type: AccessoryType.background,
    price: 300,
    unlockLevel: 7,
  ),
  const PetAccessory(
    id: 'effect_sparkles',
    name: 'Brillitos',
    icon: '✨',
    type: AccessoryType.petEffect,
    price: 120,
    unlockLevel: 2,
  ),
  const PetAccessory(
    id: 'effect_rainbow',
    name: 'Arcoíris',
    icon: '🌈',
    type: AccessoryType.petEffect,
    price: 250,
    unlockLevel: 6,
  ),
];
