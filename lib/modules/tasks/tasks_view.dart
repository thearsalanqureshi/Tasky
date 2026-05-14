import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_tile.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrutalAppBar(
        title: 'Tasks',
        trailing: IconButton(
          tooltip: 'Refresh tasks',
          onPressed: controller.refreshTasks,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
      floatingActionButton: _FloatingAddButton(onTap: controller.openAddTask),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 840
                ? 980.0
                : double.infinity;
            return RefreshIndicator(
              onRefresh: controller.refreshTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  104,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BrutalTextField(
                          controller: controller.searchController,
                          labelText: 'Search tasks',
                          hintText: 'Find a saved task',
                          prefixIcon: const Icon(Icons.search_rounded),
                          onChanged: controller.setSearchQuery,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        _FilterRow(controller: controller),
                        _ActiveCategoryFilter(controller: controller),
                        const SizedBox(height: AppSizes.xl),
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.xxl),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final error = controller.errorMessage.value;
                          if (error != null) {
                            return _TasksEmptyState(
                              icon: Icons.error_outline_rounded,
                              title: 'Could not load tasks',
                              subtitle: error,
                              buttonLabel: 'Try Again',
                              onButtonTap: controller.refreshTasks,
                            );
                          }

                          final tasks = controller.filteredTasks;
                          if (tasks.isEmpty) {
                            return _EmptyTasksForState(controller: controller);
                          }

                          return Column(
                            children: tasks
                                .map(
                                  (task) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSizes.md,
                                    ),
                                    child: _TaskCard(task: task),
                                  ),
                                )
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Obx(
        () => Row(
          children: TasksController.filters.map((filter) {
            final selected = controller.selectedFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: BrutalCard(
                onTap: () => controller.setFilter(filter),
                shadowOffset: selected
                    ? const Offset(4, 4)
                    : const Offset(2, 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                backgroundColor: selected
                    ? AppColors.primaryYellow
                    : Theme.of(context).cardColor,
                child: Text(
                  filter.label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActiveCategoryFilter extends StatelessWidget {
  const _ActiveCategoryFilter({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categoryId = controller.selectedCategoryId.value;
      if (categoryId == null) {
        return const SizedBox.shrink();
      }
      final category = controller.categoryById(categoryId);
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.md),
        child: BrutalCard(
          backgroundColor: _categoryColor(category),
          shadowOffset: const Offset(3, 3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_rounded, color: AppColors.blackStroke),
              const SizedBox(width: AppSizes.xs),
              Text(
                category.name,
                style: const TextStyle(
                  color: AppColors.blackStroke,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              InkWell(
                onTap: controller.clearCategoryFilter,
                borderRadius: BorderRadius.circular(999),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.blackStroke,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _EmptyTasksForState extends StatelessWidget {
  const _EmptyTasksForState({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
    final hasCategory = controller.selectedCategoryId.value != null;
    if (!controller.hasAnyTasks) {
      return _TasksEmptyState(
        icon: Icons.add_task_rounded,
        title: 'No tasks yet',
        subtitle: 'Add your first offline task and it will stay on this phone.',
        buttonLabel: 'Add Task',
        onButtonTap: controller.openAddTask,
      );
    }
    if (hasSearch) {
      return const _TasksEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No search results',
        subtitle: 'Try a different title, description, or category.',
      );
    }
    if (hasCategory) {
      final category = controller.categoryById(
        controller.selectedCategoryId.value,
      );
      return _TasksEmptyState(
        icon: Icons.folder_off_rounded,
        title: 'No ${category.name} tasks',
        subtitle: 'This category has no tasks in the current filter.',
      );
    }
    return switch (controller.selectedFilter.value) {
      TaskFilter.completed => const _TasksEmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'No completed tasks',
        subtitle: 'Finished tasks will collect here.',
      ),
      TaskFilter.overdue => const _TasksEmptyState(
        icon: Icons.warning_amber_rounded,
        title: 'No overdue tasks',
        subtitle: 'Nothing is late right now.',
      ),
      TaskFilter.today => const _TasksEmptyState(
        icon: Icons.today_rounded,
        title: 'No tasks for today',
        subtitle: 'Try adding a task with today as its due date.',
      ),
      TaskFilter.upcoming => const _TasksEmptyState(
        icon: Icons.event_available_rounded,
        title: 'No upcoming tasks',
        subtitle: 'Future dated tasks will show up here.',
      ),
      TaskFilter.all => _TasksEmptyState(
        icon: Icons.inbox_rounded,
        title: 'No tasks here',
        subtitle: 'The current view is empty.',
        buttonLabel: 'Add Task',
        onButtonTap: controller.openAddTask,
      ),
    };
  }
}

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmptyState(icon: icon, title: title, subtitle: subtitle),
        if (buttonLabel != null && onButtonTap != null) ...[
          const SizedBox(height: AppSizes.lg),
          BrutalButton(
            label: buttonLabel!,
            icon: Icons.add_rounded,
            onTap: onButtonTap,
          ),
        ],
      ],
    );
  }
}

class _TaskCard extends GetView<TasksController> {
  const _TaskCard({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTask = controller.taskById(task.id) ?? task;
      final category = controller.categoryById(currentTask.categoryId);
      return TaskTile(
        title: currentTask.title,
        subtitle: currentTask.description,
        isCompleted: currentTask.isCompleted,
        isOverdue: controller.isOverdue(currentTask),
        categoryLabel: category.name,
        categoryColor: _categoryColor(category),
        priorityLabel: currentTask.priority,
        priorityColor: _priorityColor(currentTask.priority),
        dueLabel: currentTask.dueDate == null
            ? null
            : DateHelper.formatDate(currentTask.dueDate!),
        subtasksCompleted: currentTask.subtasks
            .where((subtask) => subtask.isCompleted)
            .length,
        subtasksTotal: currentTask.subtasks.length,
        onToggle: () => controller.toggleTaskCompletion(currentTask.id),
        onTap: () => controller.openTask(currentTask),
        onEdit: () => controller.openEditTask(currentTask),
      );
    });
  }
}

class _FloatingAddButton extends StatelessWidget {
  const _FloatingAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      onTap: onTap,
      backgroundColor: AppColors.primaryYellow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, color: AppColors.blackStroke),
          SizedBox(width: AppSizes.xs),
          Text(
            'Add Task',
            style: TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
