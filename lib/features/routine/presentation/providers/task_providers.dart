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

  TasksNotifier(this._repository) : super(_repository.getTasks());

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

  void resetDailyTasks() {
    _repository.resetDailyTasks();
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
