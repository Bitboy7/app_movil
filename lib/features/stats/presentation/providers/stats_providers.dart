import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routine/presentation/providers/task_providers.dart';
import '../../../routine/domain/models/task.dart';

enum StatsPeriod { week, month, allTime }

final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.week);

final filteredCompletedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final period = ref.watch(statsPeriodProvider);
  final now = DateTime.now();

  final completed =
      tasks.where((t) => t.isCompleted && t.completedAt != null).toList();

  switch (period) {
    case StatsPeriod.week:
      final weekAgo = now.subtract(const Duration(days: 7));
      return completed.where((t) => t.completedAt!.isAfter(weekAgo)).toList();
    case StatsPeriod.month:
      final monthAgo = now.subtract(const Duration(days: 30));
      return completed.where((t) => t.completedAt!.isAfter(monthAgo)).toList();
    case StatsPeriod.allTime:
      return completed;
  }
});

class StatsAggregates {
  final int completedCount;
  final int totalXp;
  final int totalCoins;
  final Map<TaskCategory, int> categoryBreakdown;

  const StatsAggregates({
    required this.completedCount,
    required this.totalXp,
    required this.totalCoins,
    required this.categoryBreakdown,
  });
}

final statsAggregatesProvider = Provider<StatsAggregates>((ref) {
  final tasks = ref.watch(filteredCompletedTasksProvider);

  final categoryBreakdown = <TaskCategory, int>{};
  var totalXp = 0;
  var totalCoins = 0;

  for (final task in tasks) {
    totalXp += task.xpReward;
    totalCoins += task.coinReward;
    categoryBreakdown[task.category] =
        (categoryBreakdown[task.category] ?? 0) + 1;
  }

  return StatsAggregates(
    completedCount: tasks.length,
    totalXp: totalXp,
    totalCoins: totalCoins,
    categoryBreakdown: categoryBreakdown,
  );
});

final streakProvider = Provider<int>((ref) {
  final tasks = ref.watch(tasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final completedDates =
      tasks
          .where((t) => t.isCompleted && t.completedAt != null)
          .map(
            (t) => DateTime(
              t.completedAt!.year,
              t.completedAt!.month,
              t.completedAt!.day,
            ),
          )
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

  if (completedDates.isEmpty) return 0;

  final mostRecent = completedDates.first;
  if (mostRecent.isBefore(today.subtract(const Duration(days: 1)))) {
    return 0;
  }

  var streak = 0;
  var checkDate = mostRecent;

  for (final date in completedDates) {
    if (date == checkDate) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else if (date.isAfter(checkDate)) {
      continue;
    } else {
      break;
    }
  }

  return streak;
});

class DayStatus {
  final DateTime date;
  final bool isCompleted;
  final bool isToday;
  final String weekdayLabel;

  const DayStatus({
    required this.date,
    required this.isCompleted,
    required this.isToday,
    required this.weekdayLabel,
  });
}

final weeklyStatusProvider = Provider<List<DayStatus>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final completedDates =
      tasks
          .where((t) => t.isCompleted && t.completedAt != null)
          .map(
            (t) => DateTime(
              t.completedAt!.year,
              t.completedAt!.month,
              t.completedAt!.day,
            ),
          )
          .toSet();

  const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  return List.generate(7, (i) {
    final date = today.subtract(Duration(days: 6 - i));
    return DayStatus(
      date: date,
      isCompleted: completedDates.contains(date),
      isToday: date == today,
      weekdayLabel: weekdays[date.weekday - 1],
    );
  });
});
