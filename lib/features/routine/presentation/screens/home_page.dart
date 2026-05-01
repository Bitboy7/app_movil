import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';
import '../../../pet/presentation/providers/pet_providers.dart';
import '../../../pet/presentation/widgets/pet_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.watch(tasksProvider.notifier);
    final tasks = ref.watch(tasksProvider);

    final todayTasks = tasks.where((t) {
      if (t.repeatDays.isEmpty) return true;
      return t.repeatDays.contains(DateTime.now().weekday);
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return a.time.hour.compareTo(b.time.hour);
      });

    final completed = todayTasks.where((t) => t.isCompleted).length;
    final total = todayTasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(
                  context, theme, ref, progress, completed, total),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(context, 'Tareas de hoy', onAdd: () {
                context.push('/task/new');
              }),
            ),
            if (todayTasks.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(context))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = todayTasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => context.push('/task/${task.id}'),
                      onToggle: () {
                        final wasCompleted = task.isCompleted;
                        notifier.toggleTask(task.id);
                        if (!wasCompleted) {
                          ref
                              .read(petProvider.notifier)
                              .addXp(task.xpReward);
                          ref
                              .read(petProvider.notifier)
                              .addCoins(task.coinReward);
                        }
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                        .slideX(begin: 0.05);
                  },
                  childCount: todayTasks.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref,
      double progress, int completed, int total) {
    final pet = ref.watch(petProvider);
    final greeting = _getGreeting();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        )),
                    const SizedBox(height: 4),
                    Text('${pet.name} Nv.${pet.level}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const PetWidget(size: 64),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text('$completed de $total completadas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildSectionTitle(BuildContext context, String title,
      {VoidCallback? onAdd}) {
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.add_rounded, color: AppColors.primary),
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
          Text('Sin tareas por hoy',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              )),
          const SizedBox(height: 8),
          Text('Crea tu primera rutina para empezar',
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}
