import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'tasks_controller.dart';

class TaskDetailView extends GetView<TasksController> {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrutalAppBar(
        title: 'Task Detail',
        trailing: IconButton(
          tooltip: 'Close',
          onPressed: Get.back,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final task = controller.taskFromArgument(Get.arguments);
          if (task == null) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Task not found',
                      subtitle: 'This task may have been deleted.',
                    ),
                  ),
                  BrutalButton(
                    width: double.infinity,
                    label: 'Back',
                    icon: Icons.arrow_back_rounded,
                    onTap: Get.back,
                  ),
                ],
              ),
            );
          }
          final category = controller.categoryById(task.categoryId);
          final completedSubtasks = task.subtasks
              .where((subtask) => subtask.isCompleted)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrutalCard(
                      backgroundColor: _categoryColor(category),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSizes.sm,
                            runSpacing: AppSizes.sm,
                            children: [
                              BrutalBadge(
                                label: category.name,
                                color: AppColors.whiteCard,
                                icon: Icons.folder_rounded,
                              ),
                              BrutalBadge(
                                label: task.priority,
                                color: _priorityColor(task.priority),
                                icon: Icons.flag_rounded,
                              ),
                              BrutalBadge(
                                label: task.energyLevel,
                                color: _energyColor(task.energyLevel),
                                icon: Icons.bolt_rounded,
                              ),
                              BrutalBadge(
                                label: task.isCompleted ? 'Completed' : 'Open',
                                color: task.isCompleted
                                    ? AppColors.mintGreen
                                    : AppColors.primaryYellow,
                                icon: task.isCompleted
                                    ? Icons.check_rounded
                                    : Icons.pending_actions_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            task.description ?? 'No description yet.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    _InfoGrid(task: task, controller: controller),
                    const SizedBox(height: AppSizes.xl),
                    _SubtaskDetailCard(
                      task: task,
                      completedSubtasks: completedSubtasks,
                      onToggle: (subtaskId) => controller
                          .toggleSubtaskCompletion(task.id, subtaskId),
                    ),
                    if (task.reminderAt != null) ...[
                      const SizedBox(height: AppSizes.xl),
                      _ReminderCard(task: task),
                    ],
                    const SizedBox(height: AppSizes.xl),
                    _DetailActions(task: task, controller: controller),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.task, required this.controller});

  final TaskModel task;
  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.event_rounded,
        label: 'Due date',
        value: task.dueDate == null
            ? 'No date'
            : DateHelper.formatDateTime(task.dueDate!),
        color: AppColors.primaryYellow,
      ),
      (
        icon: Icons.timer_rounded,
        label: 'Estimate',
        value: task.estimatedMinutes == null
            ? 'No estimate'
            : '${task.estimatedMinutes} min',
        color: AppColors.blue,
      ),
      (
        icon: Icons.check_circle_rounded,
        label: 'Status',
        value: task.isCompleted ? 'Completed' : 'Still open',
        color: task.isCompleted ? AppColors.mintGreen : AppColors.whiteCard,
      ),
      (
        icon: Icons.warning_rounded,
        label: 'Overdue',
        value: controller.isOverdue(task) ? 'Yes' : 'No',
        color: controller.isOverdue(task)
            ? AppColors.dangerRed
            : AppColors.mintGreen,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 560 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: columns == 2 ? 2.7 : 4.3,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return BrutalCard(
              backgroundColor: item.color,
              padding: const EdgeInsets.all(AppSizes.md),
              shadowOffset: const Offset(3, 3),
              child: Row(
                children: [
                  Icon(item.icon, color: AppColors.blackStroke),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.blackStroke,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.blackStroke,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SubtaskDetailCard extends StatelessWidget {
  const _SubtaskDetailCard({
    required this.task,
    required this.completedSubtasks,
    required this.onToggle,
  });

  final TaskModel task;
  final int completedSubtasks;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.whiteCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subtasks',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.blackStroke),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            task.subtasks.isEmpty
                ? 'No subtasks for this task.'
                : '$completedSubtasks/${task.subtasks.length} completed',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.blackStroke),
          ),
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            ...task.subtasks.map(
              (subtask) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.brutalRadius),
                  onTap: () => onToggle(subtask.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
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
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.blackStroke),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.blue,
      child: Row(
        children: [
          const Icon(Icons.notifications_rounded, color: AppColors.blackStroke),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder preview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  task.reminderAt!.isBefore(DateTime.now())
                      ? 'Reminder time passed'
                      : DateHelper.formatReminderDateTime(task.reminderAt!),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.task, required this.controller});

  final TaskModel task;
  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final edit = BrutalButton(
      label: 'Edit',
      icon: Icons.edit_rounded,
      backgroundColor: AppColors.primaryYellow,
      onTap: () => Get.toNamed(
        AppRoutes.addEditTask,
        arguments: {'taskId': task.id, 'mode': 'edit'},
      ),
      width: compact ? double.infinity : null,
    );
    final delete = BrutalButton(
      label: 'Delete',
      icon: Icons.delete_rounded,
      backgroundColor: AppColors.dangerRed,
      onTap: () => _confirmDelete(context),
      width: compact ? double.infinity : null,
    );

    return compact
        ? Column(
            children: [
              edit,
              const SizedBox(height: AppSizes.md),
              delete,
            ],
          )
        : Row(
            children: [
              Expanded(child: edit),
              const SizedBox(width: AppSizes.lg),
              Expanded(child: delete),
            ],
          );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSizes.lg),
        child: BrutalCard(
          backgroundColor: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete task?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'This will remove the task from local storage on this device.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: BrutalButton(
                      label: 'Cancel',
                      backgroundColor: AppColors.whiteCard,
                      onTap: Get.back,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: BrutalButton(
                      label: 'Confirm',
                      backgroundColor: AppColors.dangerRed,
                      onTap: () async {
                        Get.back<void>();
                        final deleted = await controller.deleteTask(task.id);
                        if (deleted) {
                          Get.back<void>();
                          Get.snackbar(
                            'Task deleted',
                            'The task was removed from local storage.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryYellow,
                            colorText: AppColors.blackStroke,
                            margin: const EdgeInsets.all(AppSizes.lg),
                            borderColor: AppColors.blackStroke,
                            borderWidth: 3,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
