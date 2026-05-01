import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/routine/domain/models/task.dart';

class CategoryBarChart extends StatelessWidget {
  final Map<TaskCategory, int> breakdown;

  const CategoryBarChart({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries =
        breakdown.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Sin datos para mostrar',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final maxValue = entries.first.value;

    return Column(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        final category = entry.key;
        final count = entry.value;
        final progress = count / maxValue;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$count',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                height: 8,
                                width: constraints.maxWidth,
                                color: category.color.withValues(alpha: 0.1),
                              ),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Container(
                                    height: 8,
                                    width: constraints.maxWidth * value,
                                    decoration: BoxDecoration(
                                      color: category.color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(
            begin: -0.05,
          ),
        );
      }),
    );
  }
}
