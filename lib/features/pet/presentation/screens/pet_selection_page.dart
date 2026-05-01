import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/pet.dart';
import '../providers/pet_providers.dart';
import '../widgets/pet_widget.dart';

class PetSelectionPage extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const PetSelectionPage({super.key, this.isOnboarding = false});

  @override
  ConsumerState<PetSelectionPage> createState() => _PetSelectionPageState();
}

class _PetSelectionPageState extends ConsumerState<PetSelectionPage> {
  PetType? _selected;

  @override
  void initState() {
    super.initState();
    final current = ref.read(petProvider);
    _selected = current.petType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = PetType.values;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              title: const Text('Elige tu mascota'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isOnboarding) const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Elige tu compañero',
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cada mascota tiene su propia personalidad',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: types.map((type) => _buildPetCard(context, type)).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () async {
                          await ref.read(petProvider.notifier).setPetType(_selected!);
                          if (mounted) {
                            if (widget.isOnboarding) {
                              context.go('/home');
                            } else {
                              Navigator.pop(context);
                            }
                          }
                        },
                  child: Text(_selected == null ? 'Selecciona una mascota' : '¡Elegir ${_selected!.name}!'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetType type) {
    final theme = Theme.of(context);
    final isSelected = _selected == type;
    final samplePet = Pet(petType: type);

    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? type.colors.first.withValues(alpha: 0.12)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? type.colors.first : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.colors.first.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PetWidget(size: 100, petOverride: samplePet),
            const SizedBox(height: 12),
            Text(
              type.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? type.colors.first : null,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}