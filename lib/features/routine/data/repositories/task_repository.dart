import '../../domain/models/task.dart';

class TaskRepository {
  final List<Task> _tasks = [];

  List<Task> getTasks() => List.unmodifiable(_tasks);

  List<Task> getTasksForToday() {
    final today = DateTime.now().weekday;
    return _tasks.where((t) {
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
      _tasks.where((t) => t.isCompleted).toList();

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void addTask(Task task) => _tasks.add(task);

  void updateTask(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) _tasks[index] = updated;
  }

  void toggleTask(String id) {
    final task = getTaskById(id);
    if (task != null) {
      updateTask(task.copyWith(isCompleted: !task.isCompleted));
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
  }

  void resetDailyTasks() {
    for (var i = 0; i < _tasks.length; i++) {
      _tasks[i] = _tasks[i].copyWith(isCompleted: false);
    }
  }

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;
  double get completionRate =>
      _tasks.isEmpty ? 0 : completedCount / totalCount;
}
