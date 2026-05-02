import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/pet/presentation/providers/pet_providers.dart';
import '../../features/pet/presentation/widgets/pet_widget.dart';
import '../../features/routine/presentation/providers/task_providers.dart';
import '../../core/theme/app_colors.dart';

final dailyLoginProvider = StateProvider<bool>((ref) => false);

class DailyLoginGate extends ConsumerStatefulWidget {
  final Widget child;
  const DailyLoginGate({super.key, required this.child});

  @override
  ConsumerState<DailyLoginGate> createState() => _DailyLoginGateState();
}

class _DailyLoginGateState extends ConsumerState<DailyLoginGate>
    with SingleTickerProviderStateMixin {
  bool _showGreeting = false;
  int _streak = 0;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _petScale;
  late final Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _petScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _checkDailyLogin();
  }

  Future<void> _checkDailyLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStr = prefs.getString('last_login_date');
    final lastDate = lastStr != null ? DateTime.parse(lastStr) : null;

    if (lastDate == null || !lastDate.isAtSameMomentAs(today)) {
      await prefs.setString('last_login_date', today.toIso8601String());
      await _loadStreak();
      if (mounted) {
        setState(() => _showGreeting = true);
        ref.read(dailyLoginProvider.notifier).state = true;
        _ctrl.forward();
        Future.delayed(const Duration(seconds: 4), _dismiss);
      }
    }
  }

  Future<void> _loadStreak() async {
    final tasks = ref.read(tasksProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final completedDates = tasks
        .where((t) => t.isCompleted && t.completedAt != null)
        .map((t) => DateTime(t.completedAt!.year, t.completedAt!.month, t.completedAt!.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    if (completedDates.isNotEmpty && completedDates.first == today) {
      streak = 1;
      var check = today.subtract(const Duration(days: 1));
      for (final d in completedDates.skip(1)) {
        if (d == check) {
          streak++;
          check = check.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    if (mounted) setState(() => _streak = streak);
  }

  void _dismiss() {
    if (_ctrl.isCompleted) {
      _ctrl.reverse().then((_) {
        if (mounted) setState(() => _showGreeting = false);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        widget.child,
        if (_showGreeting)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => FadeTransition(
              opacity: _fade,
              child: Container(
                color: Colors.black87,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _petScale.value,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 48,
                                  spreadRadius: 8,
                                ),
                              ],
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
                        ),
                        const SizedBox(height: 24),
                        AnimatedBuilder(
                          animation: _ctrl,
                          builder: (context, _) => Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: FadeTransition(
                              opacity: _fade,
                              child: Column(
                                children: [
                                  Text(
                                    _getMessage(),
                                    style: theme.textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${pet.name} está feliz de verte',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  if (_streak > 0) ...[
                                    const SizedBox(height: 12),
                                    _buildStreakBadge(theme),
                                  ],
                                  const SizedBox(height: 32),
                                  GestureDetector(
                                    onTap: _dismiss,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '¡A por hoy!',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStreakBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWarm,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            'Racha de $_streak días',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getMessage() {
    if (_streak >= 30) return '¡Eres imparable!';
    if (_streak >= 14) return '¡Dos semanas seguidas!';
    if (_streak >= 7) return '¡Una semana de racha!';
    if (_streak >= 3) return '¡3 días seguidos!';
    if (_streak > 0) return '¡Bienvenido de nuevo!';
    return '¡Hola de nuevo!';
  }
}
