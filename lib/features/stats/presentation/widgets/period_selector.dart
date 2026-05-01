import 'package:flutter/material.dart';
import '../providers/stats_providers.dart';

class PeriodSelector extends StatelessWidget {
  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _chip(context, StatsPeriod.week, 'Semana'),
          _chip(context, StatsPeriod.month, 'Mes'),
          _chip(context, StatsPeriod.allTime, 'Todo'),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, StatsPeriod period, String label) {
    final isSelected = selected == period;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
