import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../../features/pet/presentation/providers/pet_providers.dart';
import '../../features/pet/presentation/widgets/pet_widget.dart';

enum CelebrationType { allDone, levelUp }

final celebrationTypeProvider = StateProvider<CelebrationType?>((ref) => null);

class CelebrationOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const CelebrationOverlay({super.key, required this.child});

  @override
  ConsumerState<CelebrationOverlay> createState() =>
      _CelebrationOverlayState();
}

class _CelebrationOverlayState extends ConsumerState<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAndDismiss() {
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          ref.read(celebrationTypeProvider.notifier).state = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(celebrationTypeProvider);
    final pet = ref.watch(petProvider);

    if (type != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.status != AnimationStatus.forward) {
          _showAndDismiss();
        }
      });
    }

    return Stack(
      children: [
        widget.child,
        if (type != null)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: type == CelebrationType.levelUp
                          ? _buildLevelUpWidget(context, pet)
                          : _buildAllDoneWidget(context, pet),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAllDoneWidget(BuildContext context, dynamic pet) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Lottie.asset(
            'assets/lottie/star.json',
            width: 200,
            height: 200,
            repeat: true,
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _fade,
          child: Text(
            '¡Todo completado!',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _fade,
          child: Text(
            '${pet.name} está orgulloso de ti',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildDismissButton(),
      ],
    );
  }

  Widget _buildLevelUpWidget(BuildContext context, dynamic pet) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const PetWidget(size: 200),
              Lottie.asset(
                'assets/lottie/star.json',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _fade,
          child: Text(
            '¡NIVEL ${pet.level}!',
            style: theme.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _fade,
          child: Text(
            '${pet.name} ha evolucionado',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeTransition(
          opacity: _fade,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.gradientWarm,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${pet.currentXp} / ${pet.xpToNextLevel} XP',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildDismissButton(),
      ],
    );
  }

  Widget _buildDismissButton() {
    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: () {
          _controller.reverse().then((_) {
            ref.read(celebrationTypeProvider.notifier).state = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
