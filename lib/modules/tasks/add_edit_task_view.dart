import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../data/mock/tasky_mock_data.dart';
import '../../data/models/task_model.dart';

class AddEditTaskView extends StatefulWidget {
  const AddEditTaskView({super.key});

  @override
  State<AddEditTaskView> createState() => _AddEditTaskViewState();
}

class _AddEditTaskViewState extends State<AddEditTaskView> {
  late final TaskModel? _task;
  late String _selectedCategoryId;
  late String _selectedPriority;
  late int _estimatedMinutes;
  bool _reminderEnabled = false;

  bool get _isEditMode => _task != null;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    _task = arguments is Map && arguments['task'] is TaskModel
        ? arguments['task'] as TaskModel
        : null;
    _selectedCategoryId =
        _task?.categoryId ?? TaskyMockData.categories.first.id;
    _selectedPriority = _task?.priority ?? 'Medium';
    _estimatedMinutes = _task?.estimatedMinutes ?? 30;
    _reminderEnabled = _task?.reminderTime != null;
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
                          initialValue: _task?.title,
                          labelText: 'Title',
                          hintText: 'What needs to get done?',
                          prefixIcon: const Icon(Icons.title_rounded),
                        ),
                        const SizedBox(height: AppSizes.md),
                        BrutalTextField(
                          initialValue: _task?.description,
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
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: TaskyMockData.categories.map((category) {
                      final selected = _selectedCategoryId == category.id;
                      return BrutalCard(
                        onTap: () =>
                            setState(() => _selectedCategoryId = category.id),
                        backgroundColor: selected
                            ? TaskyMockData.categoryColor(category.id)
                            : AppColors.whiteCard,
                        shadowOffset: selected
                            ? const Offset(4, 4)
                            : const Offset(2, 2),
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
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _SectionTitle(title: 'Priority'),
                  const SizedBox(height: AppSizes.md),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: ['Low', 'Medium', 'High'].map((priority) {
                      final selected = _selectedPriority == priority;
                      return BrutalCard(
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        backgroundColor: selected
                            ? TaskyMockData.priorityColor(priority)
                            : AppColors.whiteCard,
                        shadowOffset: selected
                            ? const Offset(4, 4)
                            : const Offset(2, 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.sm,
                        ),
                        child: Text(
                          priority,
                          style: const TextStyle(
                            color: AppColors.blackStroke,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _ScheduleCard(
                    task: _task,
                    reminderEnabled: _reminderEnabled,
                    estimatedMinutes: _estimatedMinutes,
                    onReminderChanged: (value) =>
                        setState(() => _reminderEnabled = value),
                    onEstimateChanged: (value) => setState(() {
                      _estimatedMinutes = (_estimatedMinutes + value)
                          .clamp(10, 180)
                          .toInt();
                    }),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _SubtasksCard(task: _task),
                  const SizedBox(height: AppSizes.xl),
                  BrutalButton(
                    width: double.infinity,
                    label: 'Save Prototype Task',
                    icon: Icons.save_rounded,
                    onTap: _showPrototypeSnackbar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPrototypeSnackbar() {
    Get.snackbar(
      'Prototype only',
      'Real task saving will be implemented in Phase 4',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryYellow,
      colorText: AppColors.blackStroke,
      margin: const EdgeInsets.all(AppSizes.lg),
      borderColor: AppColors.blackStroke,
      borderWidth: 3,
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.task,
    required this.reminderEnabled,
    required this.estimatedMinutes,
    required this.onReminderChanged,
    required this.onEstimateChanged,
  });

  final TaskModel? task;
  final bool reminderEnabled;
  final int estimatedMinutes;
  final ValueChanged<bool> onReminderChanged;
  final ValueChanged<int> onEstimateChanged;

  @override
  Widget build(BuildContext context) {
    final dueLabel = task?.dueDate == null
        ? 'Today, 5:00 PM'
        : DateHelper.formatDateTime(task!.dueDate!);
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Plan'),
          const SizedBox(height: AppSizes.md),
          BrutalTextField(
            initialValue: dueLabel,
            labelText: 'Due date',
            readOnly: true,
            prefixIcon: const Icon(Icons.event_rounded),
            suffixIcon: const Icon(Icons.expand_more_rounded),
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
                  'Reminder preview',
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
          if (reminderEnabled) ...[
            const SizedBox(height: AppSizes.sm),
            const BrutalBadge(
              label: 'Reminder: 30 minutes before',
              color: AppColors.whiteCard,
              icon: Icons.alarm_rounded,
            ),
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
  const _SubtasksCard({required this.task});

  final TaskModel? task;

  @override
  Widget build(BuildContext context) {
    final subtasks = task?.subtasks ?? const [];
    return BrutalCard(
      backgroundColor: AppColors.mintGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Subtasks'),
          const SizedBox(height: AppSizes.md),
          if (subtasks.isEmpty)
            const Text(
              'Add small steps here in the real task flow.',
              style: TextStyle(
                color: AppColors.blackStroke,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            ...subtasks.map(
              (subtask) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    Icon(
                      subtask.isCompleted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: AppColors.blackStroke,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: const TextStyle(
                          color: AppColors.blackStroke,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSizes.md),
          BrutalTextField(
            labelText: 'New subtask',
            hintText: 'Prototype input only',
            prefixIcon: const Icon(Icons.playlist_add_rounded),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}
