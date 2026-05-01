import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/data/hive_adapters.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await HiveService.openBoxes();

  runApp(const ProviderScope(child: AppMovil()));
}
