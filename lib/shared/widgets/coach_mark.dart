import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachMark {
  final String key;
  final String title;
  final String description;

  const CoachMark({
    required this.key,
    required this.title,
    required this.description,
  });

  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('coach_$key') ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('coach_$key', true);
  }

  static const home = CoachMark(
    key: 'home',
    title: 'Tu panel de rutinas',
    description: 'Aquí ves tus tareas del día. Complétalas para que tu mascota gane XP y evolucione.',
  );

  static const pet = CoachMark(
    key: 'pet',
    title: 'Tu mascota',
    description: 'Mira cómo crece tu compañero. Usa monedas para comprar accesorios en la tienda.',
  );

  static const stats = CoachMark(
    key: 'stats',
    title: 'Tu progreso',
    description: 'Revisa tus estadísticas, racha y logros por categoría.',
  );

  static const taskComplete = CoachMark(
    key: 'task_complete',
    title: '¡Primera tarea!',
    description: 'Cada tarea completada da XP y monedas. ¡Tu mascota celebra contigo!',
  );
}

class CoachMarkOverlay extends StatefulWidget {
  final CoachMark mark;
  final Widget child;
  final VoidCallback? onDismiss;

  const CoachMarkOverlay({
    super.key,
    required this.mark,
    required this.child,
    this.onDismiss,
  });

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _checkAndShow();
  }

  Future<void> _checkAndShow() async {
    final seen = await widget.mark.isSeen();
    if (!seen && mounted) {
      setState(() => _show = true);
      _controller.forward();
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _show = false);
      widget.mark.markSeen();
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        widget.child,
        if (_show)
          Positioned(
            left: 24,
            right: 24,
            bottom: 120,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.mark.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mark.description,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
