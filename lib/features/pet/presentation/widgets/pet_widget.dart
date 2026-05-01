import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/pet_accessory.dart';
import '../providers/pet_providers.dart';

class PetWidget extends ConsumerWidget {
  final double size;
  const PetWidget({super.key, this.size = 200});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pet.equippedAccessories
              .any((id) => _findAcc(id)?.type == AccessoryType.background))
            _buildBackgroundLayer(pet),
          _buildPetBody(context, pet),
          ...pet.equippedAccessories.expand((id) {
            final acc = _findAcc(id);
            if (acc == null || acc.type == AccessoryType.background) return [];
            return [_buildAccessoryLayer(acc)];
          }),
        ],
      ),
    );
  }

  PetAccessory? _findAcc(String id) {
    try {
      return defaultAccessories.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildBackgroundLayer(Pet pet) {
    final bg = pet.equippedAccessories
        .map(_findAcc)
        .firstWhere((a) => a?.type == AccessoryType.background,
            orElse: () => null);
    if (bg == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: Center(
        child: Text(bg.icon, style: TextStyle(fontSize: size * 0.9)),
      ),
    );
  }

  Widget _buildPetBody(BuildContext context, Pet pet) {
    final scale = (1.0 + (pet.level * 0.02)).clamp(1.0, 1.5);
    return Container(
      width: size * 0.6,
      height: size * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getPetColors(pet),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: _getPetColors(pet).last.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getPetEmoji(pet),
          style: TextStyle(fontSize: size * 0.3),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          duration: 2000.ms,
          begin: Offset(scale, scale),
          end: Offset(scale * 1.04, scale * 1.04),
          curve: Curves.easeInOut,
        );
  }

  Widget _buildAccessoryLayer(PetAccessory accessory) {
    if (accessory.type == AccessoryType.hat) {
      return Positioned(
        top: size * 0.05,
        child: Text(accessory.icon, style: TextStyle(fontSize: size * 0.22)),
      );
    }
    if (accessory.type == AccessoryType.glasses) {
      return Positioned(
        top: size * 0.32,
        child: Text(accessory.icon, style: TextStyle(fontSize: size * 0.18)),
      );
    }
    if (accessory.type == AccessoryType.petEffect) {
      return Positioned(
        bottom: size * 0.05,
        child: Text(accessory.icon, style: TextStyle(fontSize: size * 0.2)),
      );
    }
    return const SizedBox.shrink();
  }

  List<Color> _getPetColors(Pet pet) {
    if (pet.level >= 10) {
      return [const Color(0xFFFFD700), const Color(0xFFFF6B8A)];
    }
    if (pet.level >= 5) {
      return [const Color(0xFF7C5CFC), const Color(0xFF36D6E7)];
    }
    if (pet.level >= 3) {
      return [const Color(0xFF4ADE80), const Color(0xFF36D6E7)];
    }
    return [AppColors.primaryLight, AppColors.accentLight];
  }

  String _getPetEmoji(Pet pet) {
    if (pet.level >= 15) return '🦄';
    if (pet.level >= 10) return '🐉';
    if (pet.level >= 5) return '🐱';
    if (pet.level >= 3) return '🐰';
    return '🐣';
  }
}
