abstract class AppDuration {
  /// 0ms — cambios de estado sin animación (tema, selección)
  static const Duration instant = Duration.zero;

  /// 150ms — microinteracciones (press, ripple, hover)
  static const Duration micro = Duration(milliseconds: 150);

  /// 250ms — transiciones pequeñas (fade, cambio de ícono)
  static const Duration quick = Duration(milliseconds: 250);

  /// 350ms — transiciones estándar (navegación, cards, modales)
  static const Duration standard = Duration(milliseconds: 350);

  /// 500ms — énfasis (aparición de pantalla, celebración)
  static const Duration slow = Duration(milliseconds: 500);

  /// 800ms — momentos especiales (nivel up, evolución)
  static const Duration dramatic = Duration(milliseconds: 800);
}
