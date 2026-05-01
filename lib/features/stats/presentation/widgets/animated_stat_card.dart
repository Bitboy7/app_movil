import 'package:flutter/material.dart';
import '../../../../shared/widgets/animated_app_icon.dart';

class AnimatedStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final LinearGradient? gradient;

  const AnimatedStatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient != null ? null : theme.cardColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (gradient == null)
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.15 : 0.04,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedAppIcon(
            icon: icon,
            color: gradient != null ? Colors.white : color,
            size: 24,
            containerSize: 48,
            motion: AnimatedAppIconMotion.pop,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color:
                  gradient != null
                      ? Colors.white
                      : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  gradient != null
                      ? Colors.white.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
