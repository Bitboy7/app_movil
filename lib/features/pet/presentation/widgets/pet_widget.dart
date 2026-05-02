import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/pet_accessory.dart';
import '../providers/pet_providers.dart';

class PetWidget extends ConsumerWidget {
  final double size;
  final Pet? petOverride;
  const PetWidget({super.key, this.size = 200, this.petOverride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Pet pet = petOverride ?? ref.watch(petProvider);
    final reaction = ref.watch(petReactionProvider);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pet.equippedAccessories
              .any((id) => _findAcc(id)?.type == AccessoryType.background))
            _buildBackgroundLayer(pet),
          _buildPetBody(context, pet, reaction),
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

  Widget _buildPetBody(BuildContext context, Pet pet, int reaction) {
    final scale = (1.0 + (pet.level * 0.02)).clamp(1.0, 1.5);
    final colors = pet.petType.getColors(pet.level);

    final body = Container(
      width: size * 0.6,
      height: size * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Center(
        child: Text(
          pet.petType.getEmoji(pet.level),
          style: TextStyle(fontSize: size * 0.3),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(
              duration: 2500.ms,
              begin: -0.04,
              end: 0.04,
              curve: Curves.easeInOut,
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

    return TweenAnimationBuilder<double>(
      key: ValueKey('jump_$reaction'),
      tween: Tween(begin: 0, end: 1),
      duration: 600.ms,
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        final jumpY = t < 0.5
            ? -10 * (t / 0.5)
            : -10 * (1 - (t - 0.5) / 0.5);
        return Transform.translate(
          offset: Offset(0, jumpY),
          child: child,
        );
      },
      child: body,
    );
  }

  Widget _buildAccessoryLayer(PetAccessory accessory) {
    if (accessory.type == AccessoryType.hat) {
      return Positioned(
        top: size * 0.05,
        child: Text(accessory.icon, style: TextStyle(fontSize: size * 0.22))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(duration: 1500.ms, begin: 0, end: -3, curve: Curves.easeInOut),
      );
    }
    if (accessory.type == AccessoryType.glasses) {
      return Positioned(
        top: size * 0.32,
        child: Text(accessory.icon, style: TextStyle(fontSize: size * 0.18))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              duration: 1800.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.08, 1.08),
              curve: Curves.easeInOut,
            ),
      );
    }
    if (accessory.type == AccessoryType.petEffect) {
      return Positioned(
        bottom: size * 0.05,
        child: Text(accessory.icon, style: TextStyle(fontSize: size * 0.2))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1200.ms)
            .then()
            .fadeOut(duration: 1200.ms),
      );
    }
    return const SizedBox.shrink();
  }
}
