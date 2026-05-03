import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_duration.dart';
import '../../../../core/theme/app_easing.dart';

import '../../../pet/presentation/providers/pet_providers.dart';
import '../../domain/models/task.dart';
import '../providers/task_providers.dart';

const _uuid = Uuid();

class TaskFormPage extends ConsumerStatefulWidget {
  final String? taskId;
  final String? heroTag;
  const TaskFormPage({super.key, this.taskId, this.heroTag});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskCategory _selectedCategory;
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  bool _isEditing = false;
  bool _isSaving = false;

  late final AnimationController _ctaPulseController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCategory = TaskCategory.personal;
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    _selectedDays = [];

    _ctaPulseController = AnimationController(
      vsync: this,
      duration: AppDuration.dramatic,
    );

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

    _titleController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctaPulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctaPulseController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid => _titleController.text.trim().isNotEmpty;

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final notifier = ref.read(tasksProvider.notifier);
    final now = DateTime.now();

    final task = Task(
      id: _isEditing ? widget.taskId! : _uuid.v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      time: _selectedTime,
      repeatDays: List.from(_selectedDays),
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
    HapticFeedback.selectionClick();
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryLight,
                    onPrimary: Colors.white,
                    surface: AppColors.surfaceDark,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.surfaceLight,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      HapticFeedback.selectionClick();
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pet = ref.watch(petProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar misión' : 'Nueva misión',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.surfaceDark : AppColors.cardLight)
                  .withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
                onPressed: () {
                  ref
                      .read(tasksProvider.notifier)
                      .deleteTask(widget.taskId!);
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 120,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildXpPreview(context, pet, isDark),
                  const SizedBox(height: 28),
                  _buildTitleField(context, isDark),
                  const SizedBox(height: 16),
                  _buildDescriptionField(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionLabel(context, 'Categoría', Icons.tag_rounded, 0),
                  const SizedBox(height: 12),
                  _buildCategorySelector(isDark),
                  const SizedBox(height: 32),
                  _buildSectionLabel(context, 'Hora', Icons.schedule_rounded, 1),
                  const SizedBox(height: 12),
                  _buildTimeSelector(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionLabel(context, 'Repetir', Icons.repeat_rounded, 2),
                  const SizedBox(height: 12),
                  _buildDaySelector(context, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCtaButton(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXpPreview(BuildContext context, dynamic pet, bool isDark) {
    final theme = Theme.of(context);
    final categoryColor = _selectedCategory.color;
    final petEmoji = pet.petType.getEmoji(pet.level);

    return AnimatedContainer(
      duration: AppDuration.standard,
      curve: AppEasing.appear,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.08),
            categoryColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlRadius,
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: AppDuration.quick,
            switchInCurve: AppEasing.pop,
            switchOutCurve: AppEasing.disappear,
            child: Text(
              petEmoji,
              key: ValueKey('pet_$petEmoji'),
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Editando misión'
                      : 'Nueva misión para ${pet.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientWarm,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${20} XP',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.surfaceDark
                                : AppColors.cardLight)
                            .withValues(alpha: 0.9),
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${5}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: AppDuration.quick,
            switchInCurve: AppEasing.pop,
            switchOutCurve: AppEasing.disappear,
            child: Icon(
              _selectedCategory.icon,
              key: ValueKey(_selectedCategory),
              size: 28,
              color: categoryColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
        )
        .slideY(
          begin: -0.1,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
        );
  }

  Widget _buildTitleField(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(
              color: _isFormValid
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
                      .withValues(alpha: 0.1),
            ),
          ),
          child: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '¿Qué vas a hacer?',
              hintStyle: theme.textTheme.headlineMedium?.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
                fontWeight: FontWeight.w700,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Dale un nombre a tu misión'
                : null,
            cursorColor: AppColors.primary,
            cursorHeight: 28,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: AppDuration.quick,
          curve: AppEasing.appear,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: _isFormValid
                ? AppColors.gradientWarm
                : LinearGradient(
                    colors: [
                      (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight)
                          .withValues(alpha: 0.3),
                      (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight)
                          .withValues(alpha: 0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: 50.ms,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: 50.ms,
        );
  }

  Widget _buildDescriptionField(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        hintText: 'Notas opcionales...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgRadius,
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            Icons.notes_rounded,
            size: 20,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ),
      ),
      maxLines: 2,
      style: theme.textTheme.bodyMedium,
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: 100.ms,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: 100.ms,
        );
  }

  Widget _buildSectionLabel(
      BuildContext context, String title, IconData icon, int staggerIndex) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.brightness == Brightness.dark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: Duration(milliseconds: 150 + staggerIndex * 80),
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: Duration(milliseconds: 150 + staggerIndex * 80),
        );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: TaskCategory.values.map((cat) {
        final selected = _selectedCategory == cat;
        return _CategoryChip(
          category: cat,
          isSelected: selected,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = cat);
          },
        );
      }).toList(),
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: const Duration(milliseconds: 180),
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: const Duration(milliseconds: 180),
        );
  }

  Widget _buildTimeSelector(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickTime,
        borderRadius: AppRadius.xlRadius,
        child: AnimatedContainer(
          duration: AppDuration.quick,
          curve: AppEasing.appear,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientCool,
                  borderRadius: AppRadius.mdRadius,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recordarme a las',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _TimeDigit(text: hour, isDark: isDark),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            ':',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        _TimeDigit(text: minute, isDark: isDark),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTime.period == DayPeriod.am ? 'AM' : 'PM',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: const Duration(milliseconds: 230),
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: const Duration(milliseconds: 230),
        );
  }

  Widget _buildDaySelector(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final isAllSelected = _selectedDays.length == 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isAllSelected) {
                    _selectedDays.clear();
                  } else {
                    _selectedDays = List.generate(7, (i) => i + 1);
                  }
                });
              },
              child: AnimatedContainer(
                duration: AppDuration.micro,
                curve: AppEasing.appear,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAllSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  isAllSelected ? 'Deseleccionar' : 'Todos los días',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isAllSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final selected = _selectedDays.contains(dayNumber);
            return _DayPill(
              label: days[index],
              sublabel: dayLabels[index],
              isSelected: selected,
              isDark: isDark,
              categoryColor: _selectedCategory.color,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (selected) {
                    _selectedDays.remove(dayNumber);
                  } else {
                    _selectedDays.add(dayNumber);
                  }
                });
              },
            );
          }),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: const Duration(milliseconds: 280),
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppDuration.standard,
          curve: AppEasing.appear,
          delay: const Duration(milliseconds: 280),
        );
  }

  Widget _buildCtaButton(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final isValid = _isFormValid;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor.withValues(alpha: 0),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: AnimatedScale(
        scale: isValid ? 1.0 : 0.97,
        duration: AppDuration.micro,
        curve: AppEasing.appear,
        child: _MissionCtaButton(
          isValid: isValid,
          isEditing: _isEditing,
          isSaving: _isSaving,
          categoryColor: _selectedCategory.color,
          pulseAnimation: _ctaPulseController,
          onPressed: isValid ? _save : null,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // AppEasing.appear = Curves.easeOut → stays within [0,1], nunca
        // hace overshoot. Usar easeOutBack (AppEasing.pop) aquí causaba
        // t > 1.0, lo que producía BoxShadow.scale(negativo) → blurRadius < 0.
        duration: AppDuration.quick,
        curve: AppEasing.appear,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.backgroundLight,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                    ? AppColors.textTertiaryDark.withValues(alpha: 0.15)
                    : AppColors.textTertiaryLight.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppDuration.micro,
              curve: AppEasing.appear,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : (isDark ? AppColors.cardDark : AppColors.cardLight),
                borderRadius: AppRadius.smRadius,
              ),
              child: Icon(
                category.emoji,
                size: 16,
                color: isSelected
                    ? color
                    : isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(width: 8),
            // Sin AnimatedSwitcher: mantenía ambos hijos en el árbol
            // simultáneamente durante la transición → Wrap calculaba
            // dimensiones incorrectas → chips duplicados visualmente +
            // _dependents.isEmpty al interrumpir la animación con taps rápidos.
            Text(
              category.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? color
                    : isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final bool isDark;
  final Color categoryColor;
  final VoidCallback onTap;

  const _DayPill({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.isDark,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: AppDuration.micro,
        curve: AppEasing.pop,
        child: AnimatedContainer(
          duration: AppDuration.micro,
          curve: AppEasing.appear,
          width: 42,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? categoryColor.withValues(alpha: 0.15)
                : isDark
                    ? AppColors.surfaceDark
                    : AppColors.backgroundLight,
            borderRadius: AppRadius.mdRadius,
            border: Border.all(
              color: isSelected
                  ? categoryColor
                  : isDark
                      ? AppColors.textTertiaryDark.withValues(alpha: 0.15)
                      : AppColors.textTertiaryLight.withValues(alpha: 0.25),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? categoryColor
                      : isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 15,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedCrossFade(
                firstChild: Text(
                  '✓',
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                secondChild: Text(
                  sublabel.substring(0, 3).toLowerCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    height: 1,
                  ),
                ),
                crossFadeState: isSelected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: AppDuration.micro,
                sizeCurve: AppEasing.appear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeDigit extends StatelessWidget {
  final String text;
  final bool isDark;

  const _TimeDigit({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : AppColors.cardLight)
            .withValues(alpha: 0.8),
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        text,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _MissionCtaButton extends StatefulWidget {
  final bool isValid;
  final bool isEditing;
  final bool isSaving;
  final Color categoryColor;
  final Animation<double> pulseAnimation;
  final VoidCallback? onPressed;

  const _MissionCtaButton({
    required this.isValid,
    required this.isEditing,
    required this.isSaving,
    required this.categoryColor,
    required this.pulseAnimation,
    this.onPressed,
  });

  @override
  State<_MissionCtaButton> createState() => _MissionCtaButtonState();
}

class _MissionCtaButtonState extends State<_MissionCtaButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = widget.isValid
        ? [AppColors.primary, AppColors.secondary]
        : [
            (isDark ? AppColors.surfaceDark : AppColors.textTertiaryLight)
                .withValues(alpha: 0.4),
            (isDark ? AppColors.surfaceDark : AppColors.textTertiaryLight)
                .withValues(alpha: 0.3),
          ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: AppDuration.micro,
        curve: AppEasing.pop,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: AppRadius.xlRadius,
boxShadow: widget.isValid
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const <BoxShadow>[],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else ...[
                AnimatedSwitcher(
                  duration: AppDuration.micro,
                  child: Icon(
                    widget.isEditing
                        ? Icons.check_rounded
                        : Icons.rocket_launch_rounded,
                    key: ValueKey(widget.isEditing),
                    size: 20,
                    color: widget.isValid
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: AppDuration.quick,
                  child: Text(
                    widget.isEditing ? 'Guardar cambios' : 'Crear misión',
                    key: ValueKey('cta_${widget.isEditing}_${widget.isValid}'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: widget.isValid
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}