import 'package:flutter/material.dart';

abstract class AppRadius {
  /// Chips, badges pequeños, dots
  static const double sm = 8.0;

  /// Inputs, contenedores chicos, icon containers
  static const double md = 12.0;

  /// Botones, cards secundarias, dialogs
  static const double lg = 16.0;

  /// Cards principales, headers
  static const double xl = 20.0;

  /// Cards destacadas (solo header home)
  static const double xxl = 28.0;

  /// Pills, badges circulares, chips redondos
  static const double full = 999.0;

  // BorderRadius shortcuts
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullRadius =
      BorderRadius.all(Radius.circular(full));
}
