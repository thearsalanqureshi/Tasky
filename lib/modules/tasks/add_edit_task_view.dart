import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/subtask_model.dart';
import '../../data/models/task_model.dart';
import '../../data/services/notification_service.dart';
import '../main_nav/main_nav_controller.dart';
import 'tasks_controller.dart';

class AddEditTaskView extends StatefulWidget {
  const AddEditTaskView({super.key});

  @override
  State<AddEditTaskView> createState() => _AddEditTaskViewState();
}

class _AddEditTaskViewState extends State<AddEditTaskView> {
  static const _uuid = Uuid();

  late final TasksController _tasksController;
  late final SettingsRepository _settingsRepository;
  late final TaskModel? _task;
  late final bool _stayOnSourceTab;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedCategoryId;
  late String _selectedPriority;
  late String _selectedEnergyLevel;
  late int _estimatedMinutes;
  DateTime? _dueDate;
  DateTime? _reminderAt;
  bool _reminderEnabled = false;
  final List<_SubtaskDraft> _subtasks = [];

  bool get _isEditMode => _task != null;

  @override
  void initState() {
    super.initState();
    _tasksController = Get.find<TasksController>();
    _settingsRepository = Get.find<SettingsRepository>();
    _task = _tasksController.taskFromArgument(
      Get.arguments,
      allowUnsavedTask: true,
    );
    final arguments = Get.arguments;
    _stayOnSourceTab =
        arguments is Map &&
        (arguments['source'] == 'home' || arguments['source'] == 'planner');
    _titleController = TextEditingController(text: _task?.title ?? '');
    _descriptionController = TextEditingController(
      text: _task?.description ?? '',
    );
    _selectedCategoryId = _safeInitialCategoryId();
    _selectedPriority = _task?.priority ?? TaskModel.defaultPriority;
    _selectedEnergyLevel = _task?.energyLevel ?? TaskModel.defaultEnergyLevel;
    _estimatedMinutes = _task?.estimatedMinutes ?? 30;
    _dueDate = _task?.dueDate;
    _reminderAt = _task?.reminderAt;
    _reminderEnabled = _reminderAt != null;
    _subtasks.addAll(
      (_task?.subtasks ?? const []).map(
        (subtask) => _SubtaskDraft(
          id: subtask.id,
          titleController: TextEditingController(text: subtask.title),
          isCompleted: subtask.isCompleted,
        ),
      ),
    );
    if (_subtasks.isEmpty) {
      _addSubtaskField();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Task' : 'Add Task';
    return Scaffold(
      appBar: BrutalAppBar(
        title: title,
        trailing: IconButton(
          tooltip: 'Close',
          onPressed: Get.back,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrutalCard(
                    backgroundColor: AppColors.blue,
                    child: Column(
                      children: [
                        BrutalTextField(
                          controller: _titleController,
                          labelText: 'Title',
                          hintText: 'What needs to get done?',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.title_rounded),
                        ),
                        const SizedBox(height: AppSizes.md),
                        BrutalTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          hintText: 'Add helpful details',
                          maxLines: 4,
                          prefixIcon: const Icon(Icons.notes_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _SectionTitle(title: 'Category'),
                  const SizedBox(height: AppSizes.md),
                  _CategorySelector(
                    categories: _tasksController.categories,
                    selectedCategoryId: _selectedCategoryId,
                    onSelected: (id) =>
                        setState(() => _selectedCategoryId = id),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _SectionTitle(title: 'Priority'),
                  const SizedBox(height: AppSizes.md),
                  _ChoiceChips(
                    values: const ['Low', 'Medium', 'High'],
                    selectedValue: _selectedPriority,
                    colorForValue: _priorityColor,
                    onSelected: (value) =>
                        setState(() => _selectedPriority = value),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _SectionTitle(title: 'Energy'),
                  const SizedBox(height: AppSizes.md),
                  _ChoiceChips(
                    values: const ['Low', 'Medium', 'High'],
                    selectedValue: _selectedEnergyLevel,
                    colorForValue: _energyColor,
                    onSelected: (value) =>
                        setState(() => _selectedEnergyLevel = value),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _ScheduleCard(
                    dueDate: _dueDate,
                    reminderEnabled: _reminderEnabled,
                    reminderAt: _reminderAt,
                    estimatedMinutes: _estimatedMinutes,
                    onPickDueDate: _pickDueDate,
                    onClearDueDate: () => setState(() {
                      _dueDate = null;
                    }),
                    onReminderChanged: (value) => setState(() {
                      _reminderEnabled = value;
                      _reminderAt = value
                          ? (_reminderAt ?? _initialReminderDateTime())
                          : null;
                    }),
                    onPickReminderDate: _pickReminderDate,
                    onPickReminderTime: _pickReminderTime,
                    onEstimateChanged: (value) => setState(() {
                      _estimatedMinutes = (_estimatedMinutes + value)
                          .clamp(1, 1440)
                          .toInt();
                    }),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _SubtasksCard(
                    subtasks: _subtasks,
                    onAddSubtask: () => setState(_addSubtaskField),
                    onRemoveSubtask: (index) => setState(() {
                      _subtasks.removeAt(index).dispose();
                      if (_subtasks.isEmpty) {
                        _addSubtaskField();
                      }
                    }),
                    onToggleSubtask: (index) => setState(() {
                      _subtasks[index].isCompleted =
                          !_subtasks[index].isCompleted;
                    }),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  BrutalButton(
                    width: double.infinity,
                    label: _isEditMode ? 'Save Changes' : 'Create Task',
                    icon: Icons.save_rounded,
                    onTap: _saveTask,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _safeInitialCategoryId() {
    final categories = _tasksController.categories;
    if (categories.isEmpty) {
      return 'study';
    }
    final existingCategory = _task?.categoryId;
    if (existingCategory != null &&
        categories.any((category) => category.id == existingCategory)) {
      return existingCategory;
    }
    return categories.first.id;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      helpText: 'Pick due date',
    );
    if (pickedDate == null) {
      return;
    }
    setState(() {
      _dueDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnack('Missing title', 'Add a task title before saving.');
      return;
    }
    if (_estimatedMinutes < 0) {
      _showSnack('Invalid estimate', 'Estimated minutes cannot be negative.');
      return;
    }

    final now = DateTime.now();
    final description = _descriptionController.text.trim();
    final reminderAt = _reminderEnabled ? _effectiveReminderAt() : null;
    final task = TaskModel(
      id: _task?.id ?? _uuid.v4(),
      title: title,
      description: description.isEmpty ? null : description,
      categoryId: _selectedCategoryId,
      priority: _selectedPriority,
      dueDate: _dueDate,
      isCompleted: _task?.isCompleted ?? false,
      createdAt: _task?.createdAt ?? now,
      updatedAt: now,
      completedAt: _task?.completedAt,
      subtasks: _buildSubtasks(),
      reminderAt: reminderAt,
      estimatedMinutes: _estimatedMinutes,
      energyLevel: _selectedEnergyLevel,
    );

    final saved = _isEditMode
        ? await _tasksController.updateTask(task)
        : await _tasksController.addTask(task);
    if (!saved) {
      _showSnack('Could not save task', 'Please try again.');
      return;
    }

    await _syncReminderAfterSave(task);

    if (!_stayOnSourceTab && Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(1);
    }
    Get.back<void>();
    _showSnack(
      _isEditMode ? 'Task updated' : 'Task added',
      'Your task was saved offline.',
    );
  }

  List<SubtaskModel> _buildSubtasks() {
    final subtasks = _subtasks
        .where((draft) => draft.titleController.text.trim().isNotEmpty)
        .map(
          (draft) => SubtaskModel(
            id: draft.id ?? _uuid.v4(),
            title: draft.titleController.text.trim(),
            isCompleted: draft.isCompleted,
          ),
        )
        .toList();
    return _tasksController.sanitizeSubtasks(subtasks);
  }

  DateTime _effectiveReminderAt() {
    return _reminderAt ?? _initialReminderDateTime();
  }

  DateTime _initialReminderDateTime() {
    final baseDate = _dueDate ?? DateTime.now();
    final time = _defaultReminderTimeOfDay();
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
  }

  TimeOfDay _defaultReminderTimeOfDay() {
    final value = _settingsRepository.getDefaultReminderTime();
    final parts = value.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  DateTime _mergeReminderDateWithTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickReminderDate() async {
    final now = DateTime.now();
    final initialDate = _reminderAt ?? _initialReminderDateTime();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      helpText: 'Pick reminder date',
    );
    if (pickedDate == null) {
      return;
    }
    setState(() {
      final currentTime = _reminderAt == null
          ? _defaultReminderTimeOfDay()
          : TimeOfDay.fromDateTime(_reminderAt!);
      _reminderAt = _mergeReminderDateWithTime(pickedDate, currentTime);
      _reminderEnabled = true;
    });
  }

  Future<void> _pickReminderTime() async {
    final initialTime = _reminderAt == null
        ? _defaultReminderTimeOfDay()
        : TimeOfDay.fromDateTime(_reminderAt!);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime == null) {
      return;
    }
    setState(() {
      final currentDate = _reminderAt ?? _initialReminderDateTime();
      _reminderAt = _mergeReminderDateWithTime(currentDate, pickedTime);
      _reminderEnabled = true;
    });
  }

  Future<void> _syncReminderAfterSave(TaskModel task) async {
    final notificationService = Get.find<NotificationService>();
    final notificationsEnabled = Get.find<SettingsRepository>()
        .getNotificationsEnabled();

    if (task.reminderAt == null) {
      await notificationService.cancelTaskReminder(task.id);
      return;
    }

    if (!task.reminderAt!.isAfter(DateTime.now())) {
      await notificationService.cancelTaskReminder(task.id);
      _showSnack(
        'Reminder time passed',
        'Tasky saved the reminder, but it will not be scheduled.',
      );
      return;
    }

    if (!notificationsEnabled) {
      await notificationService.cancelTaskReminder(task.id);
      _showSnack(
        'Reminder saved',
        'Enable notifications in Settings to receive alerts.',
      );
      return;
    }

    final scheduled = await notificationService.syncTaskReminder(
      task,
      notificationsEnabled: true,
      requestPermissionIfNeeded: true,
    );
    if (!scheduled) {
      _showSnack(
        'Could not schedule reminder',
        'Tasky saved the reminder, but scheduling failed on this device.',
      );
    }
  }

  void _addSubtaskField() {
    _subtasks.add(_SubtaskDraft(titleController: TextEditingController()));
  }

  void _showSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryYellow,
      colorText: AppColors.blackStroke,
      margin: const EdgeInsets.all(AppSizes.lg),
      borderColor: AppColors.blackStroke,
      borderWidth: 3,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final draft in _subtasks) {
      draft.dispose();
    }
    super.dispose();
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final effectiveCategories = categories.isEmpty
        ? CategoryRepositoryFallback.categories
        : categories;
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: effectiveCategories.map((category) {
        final selected = selectedCategoryId == category.id;
        return BrutalCard(
          onTap: () => onSelected(category.id),
          backgroundColor: selected
              ? _categoryColor(category)
              : AppColors.whiteCard,
          shadowOffset: selected ? const Offset(4, 4) : const Offset(2, 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Text(
            category.name,
            style: const TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChoiceChips extends StatelessWidget {
  const _ChoiceChips({
    required this.values,
    required this.selectedValue,
    required this.colorForValue,
    required this.onSelected,
  });

  final List<String> values;
  final String selectedValue;
  final Color Function(String value) colorForValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: values.map((value) {
        final selected = selectedValue == value;
        return BrutalCard(
          onTap: () => onSelected(value),
          backgroundColor: selected
              ? colorForValue(value)
              : AppColors.whiteCard,
          shadowOffset: selected ? const Offset(4, 4) : const Offset(2, 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.dueDate,
    required this.reminderEnabled,
    required this.reminderAt,
    required this.estimatedMinutes,
    required this.onPickDueDate,
    required this.onClearDueDate,
    required this.onReminderChanged,
    required this.onPickReminderDate,
    required this.onPickReminderTime,
    required this.onEstimateChanged,
  });

  final DateTime? dueDate;
  final bool reminderEnabled;
  final DateTime? reminderAt;
  final int estimatedMinutes;
  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;
  final ValueChanged<bool> onReminderChanged;
  final VoidCallback onPickReminderDate;
  final VoidCallback onPickReminderTime;
  final ValueChanged<int> onEstimateChanged;

  @override
  Widget build(BuildContext context) {
    final dueLabel = dueDate == null
        ? 'No due date'
        : DateHelper.formatDate(dueDate!);
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Plan'),
          const SizedBox(height: AppSizes.md),
          BrutalTextField(
            key: ValueKey(dueLabel),
            initialValue: dueLabel,
            labelText: 'Due date',
            readOnly: true,
            onTap: onPickDueDate,
            prefixIcon: const Icon(Icons.event_rounded),
            suffixIcon: IconButton(
              tooltip: dueDate == null ? 'Pick due date' : 'Clear due date',
              onPressed: dueDate == null ? onPickDueDate : onClearDueDate,
              icon: Icon(
                dueDate == null
                    ? Icons.expand_more_rounded
                    : Icons.close_rounded,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.blackStroke,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Task reminder',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(
                value: reminderEnabled,
                activeThumbColor: AppColors.blackStroke,
                activeTrackColor: AppColors.mintGreen,
                onChanged: onReminderChanged,
              ),
            ],
          ),
          const Text(
            'Reminders stay on this device and work offline.',
            style: TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (reminderEnabled) ...[
            const SizedBox(height: AppSizes.sm),
            BrutalTextField(
              key: ValueKey(
                'reminder-date-${reminderAt?.toIso8601String() ?? 'empty'}',
              ),
              initialValue: reminderAt == null
                  ? 'Pick reminder date'
                  : DateHelper.formatDate(reminderAt),
              labelText: 'Reminder date',
              readOnly: true,
              onTap: onPickReminderDate,
              prefixIcon: const Icon(Icons.event_rounded),
              suffixIcon: const Icon(Icons.expand_more_rounded),
            ),
            const SizedBox(height: AppSizes.md),
            BrutalTextField(
              key: ValueKey(
                'reminder-time-${reminderAt?.toIso8601String() ?? 'empty'}',
              ),
              initialValue: reminderAt == null
                  ? 'Pick reminder time'
                  : DateHelper.formatTime(reminderAt),
              labelText: 'Reminder time',
              readOnly: true,
              onTap: onPickReminderTime,
              prefixIcon: const Icon(Icons.schedule_rounded),
              suffixIcon: const Icon(Icons.expand_more_rounded),
            ),
            if (reminderAt != null) ...[
              const SizedBox(height: AppSizes.sm),
              BrutalBadge(
                label:
                    'Reminder: ${DateHelper.formatReminderDateTime(reminderAt)}',
                color: AppColors.whiteCard,
                icon: Icons.alarm_rounded,
              ),
            ],
          ],
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estimated time: $estimatedMinutes min',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Decrease estimate',
                onPressed: () => onEstimateChanged(-10),
                icon: const Icon(Icons.remove_rounded),
              ),
              IconButton(
                tooltip: 'Increase estimate',
                onPressed: () => onEstimateChanged(10),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubtasksCard extends StatelessWidget {
  const _SubtasksCard({
    required this.subtasks,
    required this.onAddSubtask,
    required this.onRemoveSubtask,
    required this.onToggleSubtask,
  });

  final List<_SubtaskDraft> subtasks;
  final VoidCallback onAddSubtask;
  final ValueChanged<int> onRemoveSubtask;
  final ValueChanged<int> onToggleSubtask;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.mintGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionTitle(title: 'Subtasks')),
              IconButton(
                tooltip: 'Add subtask',
                onPressed: onAddSubtask,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...List.generate(subtasks.length, (index) {
            final draft = subtasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Toggle subtask',
                    onPressed: () => onToggleSubtask(index),
                    icon: Icon(
                      draft.isCompleted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                    ),
                  ),
                  Expanded(
                    child: BrutalTextField(
                      controller: draft.titleController,
                      labelText: 'Subtask ${index + 1}',
                      hintText: 'Small step',
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove subtask',
                    onPressed: () => onRemoveSubtask(index),
                    icon: const Icon(Icons.delete_rounded),
                  ),
                ],
              ),
            );
          }),
          const Text(
            'Empty subtasks are ignored when saving.',
            style: TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtaskDraft {
  _SubtaskDraft({
    required this.titleController,
    this.id,
    this.isCompleted = false,
  });

  final String? id;
  final TextEditingController titleController;
  bool isCompleted;

  void dispose() {
    titleController.dispose();
  }
}

class CategoryRepositoryFallback {
  const CategoryRepositoryFallback._();

  static const categories = [
    CategoryModel(id: 'study', name: 'Study', colorHex: '#FFD84D'),
    CategoryModel(id: 'personal', name: 'Personal', colorHex: '#F47BD5'),
    CategoryModel(id: 'work', name: 'Work', colorHex: '#A7D8FF'),
    CategoryModel(id: 'health', name: 'Health', colorHex: '#8CF28A'),
    CategoryModel(id: 'project', name: 'Project', colorHex: '#FFFFFF'),
  ];
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

Color _categoryColor(CategoryModel category) {
  final hex = category.colorHex.replaceFirst('#', '');
  if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return AppColors.whiteCard;
  }
  return Color(int.parse('FF$hex', radix: 16));
}

Color _priorityColor(String priority) {
  return switch (priority.toLowerCase()) {
    'high' => AppColors.pink,
    'low' => AppColors.mintGreen,
    _ => AppColors.primaryYellow,
  };
}

Color _energyColor(String energyLevel) {
  return switch (energyLevel.toLowerCase()) {
    'high' => AppColors.pink,
    'low' => AppColors.blue,
    _ => AppColors.mintGreen,
  };
}
