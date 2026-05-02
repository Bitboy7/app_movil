import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AnimatedAppIconMotion { none, pop, pulse, float }

/// Pequeño widget reutilizable para mostrar un icono (IconData) o un emoji
/// (String) con o sin un contenedor de fondo tenue del mismo color, y con
/// movimientos sutiles opcionales.
class AnimatedAppIcon extends StatelessWidget {
  /// Acepta `IconData` o `String` (emoji).
  final Object icon;
  final Color color;
  final double size;
  final double? containerSize;
  final bool filled;
  final AnimatedAppIconMotion motion;

  const AnimatedAppIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 22,
    this.containerSize,
    this.filled = true,
    this.motion = AnimatedAppIconMotion.none,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final ico = icon;
    if (ico is IconData) {
      content = Icon(ico, color: color, size: size);
    } else {
      content = Text(
        ico.toString(),
        style: TextStyle(fontSize: size, color: color),
        textAlign: TextAlign.center,
      );
    }

    if (filled && containerSize != null) {
      content = Container(
        width: containerSize,
        height: containerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(containerSize! * 0.3),
        ),
        child: content,
      );
    }

    switch (motion) {
      case AnimatedAppIconMotion.none:
        return content;
      case AnimatedAppIconMotion.pop:
        return content.animate().scale(
          duration: 280.ms,
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
      case AnimatedAppIconMotion.pulse:
        return content
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              duration: 1400.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.08, 1.08),
              curve: Curves.easeInOut,
            );
      case AnimatedAppIconMotion.float:
        return content
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              duration: 2000.ms,
              begin: 0,
              end: -6,
              curve: Curves.easeInOut,
            );
    }
  }
}
