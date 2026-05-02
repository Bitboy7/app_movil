import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/data/hive_adapters.dart';
import 'features/routine/data/repositories/task_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await HiveService.openBoxes();

  final prefs = await SharedPreferences.getInstance();
  final lastDate = prefs.getString('last_active_date');
  final today = DateTime.now().toIso8601String().substring(0, 10);
  if (lastDate != today) {
    TaskRepository().resetDailyTasks();
    await prefs.setString('last_active_date', today);
  }

  runApp(const ProviderScope(child: AppMovil()));
}
