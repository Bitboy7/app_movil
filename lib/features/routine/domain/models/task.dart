import 'package:flutter/material.dart';

enum TaskCategory {
  health('Salud', Icons.favorite, Color(0xFFF87171), '❤️'),
  work('Trabajo', Icons.work, Color(0xFF7C5CFC), '💼'),
  personal('Personal', Icons.person, Color(0xFF36D6E7), '🧘'),
  learning('Aprendizaje', Icons.school, Color(0xFF4ADE80), '📚'),
  home('Hogar', Icons.home, Color(0xFFFB923C), '🏠'),
  social('Social', Icons.people, Color(0xFFFF6B8A), '🤝');

  final String label;
  final IconData icon;
  final Color color;
  final String emoji;

  const TaskCategory(this.label, this.icon, this.color, this.emoji);

  static TaskCategory fromLabel(String label) {
    return TaskCategory.values.firstWhere(
      (c) => c.label == label,
      orElse: () => TaskCategory.personal,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TimeOfDay time;
  final List<int> repeatDays;
  final bool isCompleted;
  final int xpReward;
  final int coinReward;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.category = TaskCategory.personal,
    required this.time,
    this.repeatDays = const [],
    this.isCompleted = false,
    this.xpReward = 20,
    this.coinReward = 5,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TimeOfDay? time,
    List<int>? repeatDays,
    bool? isCompleted,
    int? xpReward,
    int? coinReward,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      isCompleted: isCompleted ?? this.isCompleted,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
