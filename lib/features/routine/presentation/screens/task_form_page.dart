import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/models/task.dart';
import '../providers/task_providers.dart';

const _uuid = Uuid();

class TaskFormPage extends ConsumerStatefulWidget {
  final String? taskId;
  const TaskFormPage({super.key, this.taskId});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskCategory _selectedCategory;
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCategory = TaskCategory.personal;
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    _selectedDays = [];

    if (widget.taskId != null) {
      _isEditing = true;
      final tasks = ref.read(tasksProvider);
      Task? existing;
      for (final t in tasks) {
        if (t.id == widget.taskId) {
          existing = t;
          break;
        }
      }
      if (existing != null) {
        _titleController.text = existing.title;
        _descriptionController.text = existing.description;
        _selectedCategory = existing.category;
        _selectedTime = existing.time;
        _selectedDays = List.from(existing.repeatDays);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(tasksProvider.notifier);
    final now = DateTime.now();

    final task = Task(
      id: _isEditing ? widget.taskId! : _uuid.v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      time: _selectedTime,
      repeatDays: _selectedDays,
      createdAt: now,
    );

    if (_isEditing) {
      notifier.updateTask(task);
    } else {
      notifier.addTask(task);
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar tarea' : 'Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                ref.read(tasksProvider.notifier).deleteTask(widget.taskId!);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '¿Qué vas a hacer?',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 28),
              Text(
                'Categoría',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskCategory.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? cat.color.withValues(alpha: 0.15)
                            : isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? cat.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: selected
                                  ? cat.color
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Hora',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickTime,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
                icon: const Icon(Icons.access_time_rounded),
                label: Text(
                  _selectedTime.toFormattedString(),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Repetir',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildDaySelector(isDark),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Guardar cambios' : 'Crear tarea',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(bool isDark) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final selected = _selectedDays.contains(dayNumber);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedDays.remove(dayNumber);
              } else {
                _selectedDays.add(dayNumber);
              }
            });
          },
          child: AnimatedContainer(
            duration: 200.ms,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : isDark
                  ? AppColors.surfaceDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? null
                  : Border.all(
                      color: AppColors.textTertiaryLight.withValues(alpha: 0.3),
                    ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textTertiaryLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
