import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/pet_repository.dart';
import '../../domain/models/pet.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

final petProvider = StateNotifierProvider<PetNotifier, Pet>((ref) {
  return PetNotifier(ref.watch(petRepositoryProvider));
});

class PetNotifier extends StateNotifier<Pet> {
  final PetRepository _repository;
  PetNotifier(this._repository) : super(_repository.pet);

  void addXp(int amount) {
    _repository.addXp(amount);
    state = _repository.pet;
  }

  void addCoins(int amount) {
    _repository.addCoins(amount);
    state = _repository.pet;
  }

  void spendCoins(int amount) {
    _repository.spendCoins(amount);
    state = _repository.pet;
  }

  void equipAccessory(String accessoryId) {
    _repository.equipAccessory(accessoryId);
    state = _repository.pet;
  }

  Future<void> setPetType(PetType petType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pet_type', petType.name);
    state = state.copyWith(
      petType: petType,
      name: petType.name,
    );
    _repository.updatePet(state);
  }
}
