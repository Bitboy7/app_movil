import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/task.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final String? heroTag;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.margin,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final checkedColor = task.category.color.withValues(alpha: 0.15);

    final cardContent = AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? isDark
                ? AppColors.cardDark.withValues(alpha: 0.5)
                : checkedColor
            : theme.cardTheme.color,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(
          color: task.isCompleted
              ? task.category.color.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: task.category.color.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          _buildIcon(context),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? theme.textTheme.bodyMedium?.color
                        : theme.textTheme.titleMedium?.color,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          _buildRewards(context),
        ],
      ),
    );

    final heroContent = heroTag != null
        ? Hero(
            tag: heroTag!,
            child: Material(
              color: Colors.transparent,
              child: cardContent,
            ),
          )
        : cardContent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: heroContent,
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: task.category.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Icon(task.category.icon, color: task.category.color, size: 22),
    );
  }

  Widget _buildRewards(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
        const SizedBox(width: 4),
        Text(
          '+${task.xpReward} XP',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
