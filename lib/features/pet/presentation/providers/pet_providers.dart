import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/pet_repository.dart';
import '../../domain/models/pet.dart';
import '../../../../core/services/widget_data_service.dart';
import '../../../../core/services/seasonal_theme.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

final petProvider = StateNotifierProvider<PetNotifier, Pet>((ref) {
  return PetNotifier(ref.watch(petRepositoryProvider));
});

final petReactionProvider = StateProvider<int>((ref) => 0);

final seasonalThemeProvider = Provider<SeasonalTheme?>((ref) {
  ref.watch(petProvider);
  return SeasonalTheme.current(DateTime.now());
});

class PetNotifier extends StateNotifier<Pet> {
  final PetRepository _repository;
  PetNotifier(this._repository) : super(_repository.pet) {
    _init();
  }

  Future<void> _init() async {
    await _restorePetType();
    _applySeasonalTheme();
  }

  Future<void> _restorePetType() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('pet_type');
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < PetType.values.length) {
      final petType = PetType.values[savedIndex];
      if (state.petType != petType) {
        state = state.copyWith(petType: petType, name: petType.name);
        _repository.updatePet(state);
      }
    }
  }

  List<String> get ownedAccessoryIds => _repository.ownedAccessoryIds;

  void _applySeasonalTheme() {
    final theme = SeasonalTheme.current(DateTime.now());
    if (theme == null) return;
    var pet = state;
    for (final acc in theme.specialAccessories) {
      if (!_repository.ownedAccessoryIds.contains(acc.id)) {
        _repository.ownAccessory(acc.id);
      }
      if (!pet.equippedAccessories.contains(acc.id)) {
        _repository.equipAccessory(acc.id);
        pet = _repository.pet;
      }
    }
    if (pet != state) state = pet;
  }

  void _syncWidget() {
    WidgetDataService.updatePetData(
      petName: state.name,
      level: state.level,
      emoji: state.petType.getEmoji(state.level),
      coins: state.coins,
      streak: 0,
      mood: state.mood.name,
    );
  }

  void addXp(int amount) {
    _repository.addXp(amount);
    state = _repository.pet;
    _syncWidget();
  }

  void addCoins(int amount) {
    _repository.addCoins(amount);
    state = _repository.pet;
    _syncWidget();
  }

  bool spendCoins(int amount) {
    final success = _repository.spendCoins(amount);
    if (success) state = _repository.pet;
    _syncWidget();
    return success;
  }

  void ownAndEquipAccessory(String accessoryId) {
    _repository.ownAccessory(accessoryId);
    _repository.equipAccessory(accessoryId);
    state = _repository.pet;
    _syncWidget();
  }

  void equipAccessory(String accessoryId) {
    _repository.equipAccessory(accessoryId);
    state = _repository.pet;
    _syncWidget();
  }

  Future<void> setPetType(PetType petType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pet_type', petType.index);
    state = Pet(petType: petType, name: petType.name);
    _repository.updatePet(state);
    _syncWidget();
  }
}
