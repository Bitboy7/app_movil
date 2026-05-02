import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/task.dart';

class TaskRepository {
  late final Box<Task> _box;

  TaskRepository() {
    _box = Hive.box<Task>('tasks_v2');
    if (_box.isEmpty) {
      _seedTasks();
    }
  }

  void _seedTasks() {
    final now = DateTime.now();
    final seedTasks = [
      Task(
        id: '1',
        title: 'Meditación matutina',
        category: TaskCategory.health,
        time: const TimeOfDay(hour: 7, minute: 0),
        xpReward: 30,
        coinReward: 10,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
      ),
      Task(
        id: '2',
        title: 'Leer 20 minutos',
        description: 'Lectura de crecimiento personal',
        category: TaskCategory.learning,
        time: const TimeOfDay(hour: 9, minute: 0),
        xpReward: 25,
        coinReward: 8,
        repeatDays: [1, 2, 3, 4, 5],
        createdAt: now,
      ),
      Task(
        id: '3',
        title: 'Ejercicio diario',
        description: '30 min de cardio o fuerza',
        category: TaskCategory.health,
        time: const TimeOfDay(hour: 6, minute: 30),
        xpReward: 40,
        coinReward: 15,
        repeatDays: [1, 2, 3, 4, 5],
        createdAt: now,
      ),
      Task(
        id: '4',
        title: 'Organizar espacio de trabajo',
        category: TaskCategory.home,
        time: const TimeOfDay(hour: 8, minute: 0),
        xpReward: 15,
        coinReward: 5,
        repeatDays: [1],
        createdAt: now,
      ),
      Task(
        id: '5',
        title: 'Llamar a un amigo',
        description: 'Mantener conexiones sociales',
        category: TaskCategory.social,
        time: const TimeOfDay(hour: 18, minute: 0),
        xpReward: 20,
        coinReward: 5,
        repeatDays: [5, 6, 7],
        createdAt: now,
      ),
      Task(
        id: '6',
        title: 'Revisar objetivos semanales',
        category: TaskCategory.work,
        time: const TimeOfDay(hour: 10, minute: 0),
        xpReward: 20,
        coinReward: 5,
        repeatDays: [1],
        createdAt: now,
      ),
    ];
    for (final task in seedTasks) {
      _box.put(task.id, task);
    }
  }

  List<Task> getTasks() => List.unmodifiable(_box.values.toList());

  List<Task> getTasksForToday() {
    final today = DateTime.now().weekday;
    return getTasks().where((t) {
      if (t.repeatDays.isEmpty) return true;
      return t.repeatDays.contains(today);
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return a.time.hour.compareTo(b.time.hour);
      });
  }

  List<Task> getCompletedTasks() =>
      getTasks().where((t) => t.isCompleted).toList();

  Task? getTaskById(String id) => _box.get(id);

  void addTask(Task task) => _box.put(task.id, task);

  void updateTask(Task updated) => _box.put(updated.id, updated);

  void toggleTask(String id) {
    final task = getTaskById(id);
    if (task != null) {
      final now = DateTime.now();
      updateTask(
        task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? now : null,
        ),
      );
    }
  }

  void deleteTask(String id) => _box.delete(id);

  void resetDailyTasks() {
    for (final task in _box.values) {
      _box.put(
        task.id,
        task.copyWith(
          isCompleted: false,
          completedAt: null,
        ),
      );
    }
  }

  int get completedCount => getTasks().where((t) => t.isCompleted).length;
  int get totalCount => getTasks().length;
  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;
}
