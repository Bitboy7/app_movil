import 'package:firebase_app_distribution/firebase_app_distribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/routing/hero_tags.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../shared/widgets/animated_counter.dart';
import '../../../../shared/widgets/celebration_overlay.dart';
import '../../../../shared/widgets/coach_mark.dart';
import '../providers/task_providers.dart';
import '../../domain/models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/swipeable_task_card.dart';
import '../../../pet/presentation/providers/pet_providers.dart';
import '../../../pet/presentation/widgets/pet_widget.dart';
import '../../../stats/presentation/providers/stats_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _allDoneCelebrationShown = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _resetDailyIfNeeded();
  }

  Future<void> _resetDailyIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final lastReset = prefs.getString('last_task_reset');

    if (lastReset != today) {
      ref.read(tasksProvider.notifier).resetDaily();
      await prefs.setString('last_task_reset', today);
      _allDoneCelebrationShown = false;
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      await updateIfNewReleaseAvailable();
    } catch (_) {
      // Silently ignore if App Distribution is not available (e.g., debug builds without setup)
    }
  }

  void _handleTaskComplete(Task task) {
    final wasCompleted = task.isCompleted;
    final notifier = ref.read(tasksProvider.notifier);
    notifier.toggleTask(task.id);
    HapticFeedback.lightImpact();
    SoundService.play(SoundEvent.taskComplete);

    if (!wasCompleted && task.completedAt == null) {
      final oldLevel = ref.read(petProvider).level;
      ref.read(petProvider.notifier).addXp(task.xpReward);
      ref.read(petProvider.notifier).addCoins(task.coinReward);
      ref.read(petReactionProvider.notifier).state++;
      final newLevel = ref.read(petProvider).level;
      if (newLevel > oldLevel) {
        SoundService.play(SoundEvent.levelUp);
        Future.microtask(() {
          ref.read(celebrationTypeProvider.notifier).state =
              CelebrationType.levelUp;
        });
      }
    }

    Future.microtask(() {
      final freshToday = ref.read(tasksProvider.notifier).todayTasks;
      final allDone =
          freshToday.every((t) => t.isCompleted) && freshToday.isNotEmpty;
      if (allDone && !_allDoneCelebrationShown) {
        _allDoneCelebrationShown = true;
        HapticFeedback.mediumImpact();
        SoundService.play(SoundEvent.allDone);
        ref.read(celebrationTypeProvider.notifier).state =
            CelebrationType.allDone;
      }
    });
  }

  void _handleTaskPostpone(Task task) {
    ref.read(tasksProvider.notifier).postponeTask(task.id);
    HapticFeedback.lightImpact();
    SoundService.play(SoundEvent.taskPostpone);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(tasksProvider.notifier);
    final tasks = ref.watch(tasksProvider);
    final pet = ref.watch(petProvider);
    final streak = ref.watch(streakProvider);

    final now = DateTime.now();

    final todayTasks =
        tasks.where((t) {
          if (notifier.isTaskSkippedToday(t.id)) return false;
          if (t.repeatDays.isEmpty) return true;
          return t.repeatDays.contains(now.weekday);
        }).toList()..sort((a, b) {
          if (a.isCompleted && !b.isCompleted) return 1;
          if (!a.isCompleted && b.isCompleted) return -1;
          return a.time.hour.compareTo(b.time.hour);
        });

    final completed = todayTasks.where((t) => t.isCompleted).length;
    final total = todayTasks.length;
    final progress = total > 0 ? completed / total : 0.0;
    final xpToday = todayTasks
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.xpReward);

    return CoachMarkOverlay(
      mark: CoachMark.home,
      child: Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 20,
              title: _buildAppBarTitle(context, now, pet),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _buildCoinsBadge(context, pet.coins),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildPetCard(context, ref, pet, progress, completed, total),
            ),
            SliverToBoxAdapter(
              child: _buildMetricsRow(context, completed, total, xpToday, streak),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                context,
                'Tareas de hoy',
                onAdd: () => context.push('/task/new'),
              ),
            ),
            if (todayTasks.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(context))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = todayTasks[index];
                  return SwipeableTaskCard(
                        task: task,
                        onComplete: () => _handleTaskComplete(task),
                        onPostpone: () => _handleTaskPostpone(task),
                        onEdit: () => context.push('/task/${task.id}'),
                        child: TaskCard(
                          task: task,
                          margin: EdgeInsets.zero,
                          onTap: () => context.push('/task/${task.id}'),
                          heroTag: HeroTags.task(task.id),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (index * 60).ms)
                      .slideY(begin: 0.04);
                }, childCount: todayTasks.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context, DateTime now, dynamic pet) {
    final theme = Theme.of(context);
    final days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final dayName = days[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.mdRadius,
          ),
          child: const PetWidget(size: 44),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dayName, $day de $month',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${pet.name} Nv.${pet.level}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildCoinsBadge(BuildContext context, int coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  Widget _buildPetCard(
    BuildContext context,
    WidgetRef ref,
    dynamic pet,
    double progress,
    int completed,
    int total,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.secondary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xxlRadius,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: const PetWidget(size: 160).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.8, 0.8),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pet.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  'Nv. ${pet.level}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${pet.currentXp} / ${pet.xpToNextLevel} XP',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.04);
  }

  Widget _buildMetricsRow(
    BuildContext context,
    int completed,
    int total,
    int xpToday,
    int streak,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(child: _buildMetricPill(
            context,
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            value: '$completed/$total',
            label: 'Completadas',
          )),
          const SizedBox(width: 10),
          Expanded(child: _buildMetricPill(
            context,
            icon: Icons.bolt_rounded,
            color: AppColors.primary,
            value: '$xpToday',
            label: 'XP hoy',
          )),
          const SizedBox(width: 10),
          Expanded(child: _buildMetricPill(
            context,
            icon: Icons.local_fire_department_rounded,
            color: AppColors.warning,
            value: '$streak',
            label: 'Racha',
          )),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.06),
    );
  }

  Widget _buildMetricPill(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isNumeric = int.tryParse(value) != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.xlRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isNumeric
                    ? AnimatedCounter(
                        value: int.parse(value),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                        duration: const Duration(milliseconds: 400),
                      )
                    : Text(
                        value,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    VoidCallback? onAdd,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdRadius,
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Sin tareas por hoy',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera rutina para empezar',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
