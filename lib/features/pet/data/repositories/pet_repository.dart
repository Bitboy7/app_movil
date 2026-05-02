import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/pet.dart';

class PetRepository {
  late final Box<Pet> _petBox;
  late final Box<List<dynamic>> _ownedBox;
  Pet _pet = const Pet();
  List<String> _ownedAccessoryIds = [];

  PetRepository() {
    _petBox = Hive.box<Pet>('pet');
    _ownedBox = Hive.box<List<dynamic>>('accessories');
    _loadFromHive();
  }

  void _loadFromHive() {
    _pet = _petBox.get('main') ?? const Pet();
    _ownedAccessoryIds =
        (_ownedBox.get('owned') ?? []).cast<String>();
  }

  void _savePet() => _petBox.put('main', _pet);
  void _saveOwned() => _ownedBox.put('owned', _ownedAccessoryIds);

  Pet get pet => _pet;
  List<String> get ownedAccessoryIds => List.unmodifiable(_ownedAccessoryIds);

  void addXp(int amount) {
    _pet = _pet.addXp(amount);
    _updateMood();
    _savePet();
  }

  void addCoins(int amount) {
    _pet = _pet.addCoins(amount);
    _savePet();
  }

  bool spendCoins(int amount) {
    if (_pet.coins < amount) return false;
    _pet = _pet.spendCoins(amount);
    _savePet();
    return true;
  }

  void equipAccessory(String accessoryId) {
    _pet = _pet.equipAccessory(accessoryId);
    _savePet();
  }

  void ownAccessory(String accessoryId) {
    if (!_ownedAccessoryIds.contains(accessoryId)) {
      _ownedAccessoryIds = [..._ownedAccessoryIds, accessoryId];
      _saveOwned();
    }
  }

  bool isAccessoryOwned(String id) => _ownedAccessoryIds.contains(id);

  void setMood(PetMood mood) {
    _pet = _pet.copyWith(mood: mood);
    _savePet();
  }

  void updatePet(Pet updated) {
    _pet = updated;
    _savePet();
  }

  void _updateMood() {
    if (_pet.level >= 10) {
      _pet = _pet.copyWith(mood: PetMood.excited);
    } else if (_pet.level >= 5) {
      _pet = _pet.copyWith(mood: PetMood.happy);
    } else {
      _pet = _pet.copyWith(mood: PetMood.neutral);
    }
    _savePet();
  }
}
