import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier(ref.watch(taskRepositoryProvider));
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super([]) {
    _loadSeedData();
  }

  void _loadSeedData() {
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
      _repository.addTask(task);
    }
    state = _repository.getTasks();
  }

  void toggleTask(String id) {
    _repository.toggleTask(id);
    state = List.from(_repository.getTasks());
  }

  void addTask(Task task) {
    _repository.addTask(task);
    state = List.from(_repository.getTasks());
  }

  void updateTask(Task task) {
    _repository.updateTask(task);
    state = List.from(_repository.getTasks());
  }

  void deleteTask(String id) {
    _repository.deleteTask(id);
    state = List.from(_repository.getTasks());
  }

  List<Task> get todayTasks => _repository.getTasksForToday();
  double get completionRate => _repository.completionRate;
  int get completedCount => _repository.completedCount;
  int get totalCount => _repository.totalCount;
}

final tasksForTodayProvider = Provider<List<Task>>((ref) {
  return ref.read(tasksProvider.notifier).todayTasks;
});

final completionRateProvider = Provider<double>((ref) {
  return ref.watch(tasksProvider.notifier).completionRate;
});
