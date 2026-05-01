import '../../domain/models/pet.dart';

class PetRepository {
  Pet _pet = const Pet();

  Pet get pet => _pet;

  void addXp(int amount) {
    _pet = _pet.addXp(amount);
    _updateMood();
  }

  void addCoins(int amount) {
    _pet = _pet.addCoins(amount);
  }

  bool spendCoins(int amount) {
    if (_pet.coins < amount) return false;
    _pet = _pet.spendCoins(amount);
    return true;
  }

  void equipAccessory(String accessoryId) {
    _pet = _pet.equipAccessory(accessoryId);
  }

  void setMood(PetMood mood) {
    _pet = _pet.copyWith(mood: mood);
  }

  void updatePet(Pet updated) {
    _pet = updated;
  }

  void _updateMood() {
    if (_pet.level >= 10) {
      _pet = _pet.copyWith(mood: PetMood.excited);
    } else if (_pet.level >= 5) {
      _pet = _pet.copyWith(mood: PetMood.happy);
    } else {
      _pet = _pet.copyWith(mood: PetMood.neutral);
    }
  }
}
