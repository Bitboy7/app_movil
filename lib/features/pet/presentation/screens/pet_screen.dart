import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/pet_accessory.dart';
import '../providers/pet_providers.dart';
import '../widgets/pet_widget.dart';

class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pet = ref.watch(petProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.scaffoldBackgroundColor,
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text('Tu compañero', style: theme.textTheme.displayMedium)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1),
                const SizedBox(height: 30),
                const Center(child: PetWidget(size: 220)).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 40),
                _buildLevelCard(context, pet),
                const SizedBox(height: 24),
                _buildAccessoriesShop(context, ref, pet),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, Pet pet) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nivel ${pet.level}', style: theme.textTheme.titleLarge),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 6),
                  Text('${pet.coins}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.warning,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pet.xpProgress,
              minHeight: 10,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text('${pet.currentXp} / ${pet.xpToNextLevel} XP',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAccessoriesShop(BuildContext context, WidgetRef ref, Pet pet) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tienda de accesorios', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: defaultAccessories.map((acc) {
            final ownedIds = ref.read(petProvider.notifier).ownedAccessoryIds;
            final isOwned = ownedIds.contains(acc.id);
            final isEquipped = pet.equippedAccessories.contains(acc.id);
            final canBuy =
                pet.coins >= acc.price && pet.level >= acc.unlockLevel;
            return _shopItem(context, ref, acc, isOwned, isEquipped, canBuy, pet);
          }).toList(),
        ),
      ],
    );
  }

  Widget _shopItem(BuildContext context, WidgetRef ref, PetAccessory acc,
      bool isOwned, bool isEquipped, bool canBuy, Pet pet) {
    final theme = Theme.of(context);
    final locked = pet.level < acc.unlockLevel;

    return GestureDetector(
      onTap: () {
        if (locked) return;
        if (isOwned) {
          ref.read(petProvider.notifier).equipAccessory(acc.id);
        } else if (canBuy) {
          ref.read(petProvider.notifier).ownAndEquipAccessory(acc.id);
        }
      },
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isOwned
              ? AppColors.success.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOwned
                ? AppColors.success
                : locked
                    ? AppColors.textTertiaryLight.withValues(alpha: 0.2)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Opacity(
          opacity: locked ? 0.5 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(acc.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                acc.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (locked)
                Text('🔒 Nv.${acc.unlockLevel}',
                    style: theme.textTheme.bodySmall)
              else if (isEquipped)
                Text('Equipado ✓',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ))
              else if (isOwned)
                Text('Comprado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on_rounded,
                        size: 14,
                        color:
                            canBuy ? AppColors.warning : AppColors.error),
                    const SizedBox(width: 4),
                    Text('${acc.price}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              canBuy ? AppColors.warning : AppColors.error,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
