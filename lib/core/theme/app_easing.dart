import 'package:flutter/animation.dart';

abstract class AppEasing {
  /// Elementos que APARECEN (fadeIn, slideIn)
  static const Curve appear = Curves.easeOut;

  /// Elementos que DESAPARECEN (fadeOut)
  static const Curve disappear = Curves.easeIn;

  /// Loops continuos (respiración, pulso)
  static const Curve loop = Curves.easeInOut;

  /// "pop" (check, celebración, badge)
  static const Curve pop = Curves.easeOutBack;

  /// Barras de progreso, contadores numéricos
  static const Curve counter = Curves.easeOutCubic;
}
