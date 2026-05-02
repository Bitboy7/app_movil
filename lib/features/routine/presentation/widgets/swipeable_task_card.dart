import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_duration.dart';
import '../../../../core/theme/app_easing.dart';
import '../../domain/models/task.dart';

/// Wrapper que añade gestos horizontales a una task card.
///
/// - Swipe derecha → completar tarea
/// - Swipe izquierda → posponer tarea
/// - Tap en la card → editar (manejado por [child])
///
/// El widget usa [AnimationController] para animar el snap-back y las
/// transiciones de confirmación. No usa [Dismissible] ni [flutter_slidable].
class SwipeableTaskCard extends StatefulWidget {
  final Task task;
  final Widget child;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback onEdit;

  const SwipeableTaskCard({
    super.key,
    required this.task,
    required this.child,
    required this.onComplete,
    required this.onPostpone,
    required this.onEdit,
  });

  @override
  State<SwipeableTaskCard> createState() => _SwipeableTaskCardState();
}

class _SwipeableTaskCardState extends State<SwipeableTaskCard>
    with SingleTickerProviderStateMixin {
  // ── Thresholds ──────────────────────────────────────────────────────
  static const _completeThreshold = 0.35;
  static const _postponeThreshold = 0.35;
  static const _hapticEntry = 0.12;
  // px/s – si el usuario suelta por encima de esta velocidad se fuerza
  // la acción aunque no se haya alcanzado el threshold posicional.
  static const _flingVelocity = 400.0;

  // ── Estados internos ────────────────────────────────────────────────
  late AnimationController _ctrl;
  double _offset = 0;
  double _opacity = 1;
  bool _isDragging = false;
  bool _hapticEntryFired = false;
  bool _hapticThresholdFired = false;
  bool _isAnimating = false;
  // Se activa tras la animación de slide+fade del postpone para colapsar
  // la altura de la card a 0 antes de llamar al callback del padre.
  bool _isCollapsing = false;

  // Ancho real del card (se setea en build via LayoutBuilder).
  double _cardWidth = 360;

  // ── Lifecycle ───────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _ctrl.addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    // Si el listener está en medio de animación lo removemos
    // (no puede removerse dentro del listener mismo).
    _ctrl.removeListener(_onAnimationTick);
    _ctrl.dispose();
    super.dispose();
  }

  // ── Guards ──────────────────────────────────────────────────────────
  bool get _canSwipe => !widget.task.isCompleted && !_isAnimating;

  // ── Handlers de drag ────────────────────────────────────────────────

  void _onDragStart(DragStartDetails _) {
    if (!_canSwipe) return;
    _ctrl.stop(canceled: true);
    _offset = 0;
    _opacity = 1;
    _isDragging = true;
    _hapticEntryFired = false;
    _hapticThresholdFired = false;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_isDragging) return;
    _offset += d.delta.dx;
    _maybeHaptic();
    setState(() {});
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_isDragging) return;
    _isDragging = false;

    // El ancho real del RenderBox está disponible aquí (post-layout).
    final actualWidth = context.size?.width ?? _cardWidth;
    final progress = _offset.abs() / actualWidth;
    final velocity = d.primaryVelocity ?? 0;
    final isFastFling = velocity.abs() > _flingVelocity;

    if (_offset > 0) {
      // ── Swipe derecha → completar ──────────────────────────────────
      if (progress >= _completeThreshold || isFastFling) {
        _animateCompleteConfirm();
      } else {
        _animateCancel(actualWidth);
      }
    } else {
      // ── Swipe izquierda → posponer ─────────────────────────────────
      if (progress >= _postponeThreshold || isFastFling) {
        _animatePostponeConfirm(actualWidth);
      } else {
        _animateCancel(actualWidth);
      }
    }
  }

  // ── Haptic progresivo ───────────────────────────────────────────────

  void _maybeHaptic() {
    if (_offset.abs() < 6) return;
    final w = context.size?.width ?? _cardWidth;
    final p = _offset.abs() / w;

    if (p >= _hapticEntry && !_hapticEntryFired) {
      _hapticEntryFired = true;
      HapticFeedback.lightImpact();
    }

    final threshold = _offset > 0 ? _completeThreshold : _postponeThreshold;
    if (p >= threshold && !_hapticThresholdFired) {
      _hapticThresholdFired = true;
      HapticFeedback.mediumImpact();
    }
  }

  // ── Animaciones ─────────────────────────────────────────────────────

  /// Cancela el swipe — la card vuelve a su posición con un resorte suave.
  void _animateCancel(double w) {
    _startSnap(
      from: _offset,
      to: 0,
      opacityTarget: 1,
    );
  }

  /// Confirma completar — bounce de satisfacción + callback.
  void _animateCompleteConfirm() {
    // Bounce rápido: se exagera 12px más allá del centro y se retrae.
    final exaggerated = _offset.sign * (_offset.abs() + 12);
    _startSnap(
      from: exaggerated,
      to: 0,
      opacityTarget: 1,
      onDone: widget.onComplete,
    );
  }

  /// Confirma posponer — fade + slide a la izquierda, luego colapsa la altura.
  void _animatePostponeConfirm(double w) {
    _startSnap(
      from: _offset,
      to: -w * 0.25,
      opacityTarget: 0,
      curve: Curves.easeIn,
      duration: AppDuration.quick,
      onDone: _startHeightCollapse,
    );
  }

  /// Segunda fase del postpone: colapsa la altura de la card a 0 para que las
  /// cards inferiores suban suavemente antes de que se actualice el estado.
  void _startHeightCollapse() {
    if (!mounted) return;
    setState(() => _isCollapsing = true);
    // 400 ms > 350 ms (duración del AnimatedSize) para asegurar que la
    // animación de altura finalice antes de retirar el widget del árbol.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) widget.onPostpone();
    });
  }

  /// Motor único de animación. Resuelve offset y opacidad en cada frame.
  void _startSnap({
    required double from,
    required double to,
    required double opacityTarget,
    Curve curve = AppEasing.appear,
    Duration duration = AppDuration.standard,
    VoidCallback? onDone,
  }) {
    _isAnimating = true;
    final opacityFrom = _opacity;

    _ctrl.value = 0;
    // Duración explícita (no spring simulation para mantenerlo simple y
    // predecible; 350ms standard es suficiente para un snap premium).
    _ctrl.duration = duration;
    _ctrl
      ..drive(Tween<double>(begin: 0, end: 1))
      ..addStatusListener(_onAnimationStatus);

    _animationFrom = from;
    _animationTo = to;
    _opacityFrom = opacityFrom;
    _opacityTo = opacityTarget;
    _snapCurve = curve;
    _snapOnDone = onDone;

    _ctrl.forward();
  }

  // Variables temporales compartidas entre el status listener y el tick
  // para evitar closures mutantes.
  double _animationFrom = 0;
  double _animationTo = 0;
  double _opacityFrom = 1;
  double _opacityTo = 1;
  Curve _snapCurve = AppEasing.appear;
  VoidCallback? _snapOnDone;

  void _onAnimationTick() {
    final t = _ctrl.value;
    final curved = _snapCurve.transform(t);
    _offset = _animationFrom + (_animationTo - _animationFrom) * curved;
    _opacity = _opacityFrom + (_opacityTo - _opacityFrom) * curved;
    setState(() {});
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isAnimating = false;
      _ctrl.removeStatusListener(_onAnimationStatus);
      _snapOnDone?.call();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: _isCollapsing
          ? const SizedBox.shrink()
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Actualizamos el ancho real del card para los thresholds.
                    _cardWidth = constraints.maxWidth;
                    return ClipRRect(
                      borderRadius: AppRadius.xlRadius,
                      child: Opacity(
                        opacity: _opacity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _buildBackground(defaultBg),
                            ),
                            Transform.translate(
                              offset: Offset(_offset, 0),
                              child: widget.child,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  // ── Background visual ───────────────────────────────────────────────

  Widget _buildBackground(Color defaultBg) {
    if (_offset.abs() < 5 && !_isAnimating) {
      return const SizedBox.shrink();
    }

    final isRight = _offset > 0;
    final progress = (_offset.abs() / _cardWidth).clamp(0.0, 1.0);

    if (isRight) {
      return _actionBackground(
        color: AppColors.success,
        icon: Icons.check_rounded,
        label: 'Completar',
        progress: progress,
        alignRight: true,
      );
    }

    // Acción única a izquierda: posponer (sin doble umbral).
    return _actionBackground(
      color: AppColors.warning,
      icon: Icons.schedule_rounded,
      label: 'Posponer',
      progress: (progress / _postponeThreshold).clamp(0.0, 1.0),
      alignRight: false,
    );
  }

  Container _actionBackground({
    required Color color,
    required IconData icon,
    required String label,
    required double progress,
    required bool alignRight,
  }) {
    final bgColor = Color.lerp(
      Colors.transparent,
      color.withValues(alpha: 0.25),
      progress,
    )!;

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(
        left: alignRight ? 0 : 24,
        right: alignRight ? 24 : 0,
      ),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: progress,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight) ...[
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ],
            if (alignRight) ...[
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(width: 10),
              Icon(icon, color: Colors.white, size: 26),
            ],
          ],
        ),
      ),
    );
  }
}
