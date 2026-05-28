import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_tile.dart';
import '../../data/mock/tasky_mock_data.dart';
import '../../data/models/task_model.dart';
import 'tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrutalAppBar(title: 'Tasks'),
      floatingActionButton: _FloatingAddButton(onTap: controller.openAddTask),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 840
                ? 980.0
                : double.infinity;
            return SingleChildScrollView(
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
                        hintText: 'Find a mock task',
                        prefixIcon: const Icon(Icons.search_rounded),
                        onChanged: controller.setSearchQuery,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      _FilterRow(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      Obx(() {
                        final tasks = controller.filteredTasks;
                        if (tasks.isEmpty) {
                          return const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No matching tasks',
                            subtitle: 'Try a different search or filter.',
                          );
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
                    : AppColors.whiteCard,
                child: Text(
                  filter,
                  style: const TextStyle(
                    color: AppColors.blackStroke,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TaskCard extends GetView<TasksController> {
  const _TaskCard({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final category = TaskyMockData.categoryById(task.categoryId);
    return Obx(() {
      final completed = controller.isCompleted(task);
      final overdue = controller.isOverdue(task);
      return TaskTile(
        title: task.title,
        subtitle: task.description,
        isCompleted: completed,
        isOverdue: overdue,
        categoryLabel: category.name,
        categoryColor: TaskyMockData.categoryColor(category.id),
        priorityLabel: task.priority,
        priorityColor: TaskyMockData.priorityColor(task.priority),
        dueLabel: task.dueDate == null
            ? null
            : DateHelper.formatDate(task.dueDate!),
        subtasksCompleted: task.subtasks
            .where((subtask) => subtask.isCompleted)
            .length,
        subtasksTotal: task.subtasks.length,
        onToggle: () => controller.toggleCompleted(task),
        onTap: () => controller.openTask(task),
        onEdit: () => controller.openEditTask(task),
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
