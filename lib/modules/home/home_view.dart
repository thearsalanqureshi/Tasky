import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_tile.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 840
                ? 980.0
                : double.infinity;
            return RefreshIndicator(
              onRefresh: controller.refreshHomeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HomeHeader(
                            username: controller.username.value,
                            onSettingsTap: controller.openSettings,
                          ),
                          const SizedBox(height: AppSizes.xl),
                          if (controller.errorMessage.value != null) ...[
                            _HomeErrorCard(
                              message: controller.errorMessage.value!,
                              onRetry: controller.refreshHomeData,
                            ),
                            const SizedBox(height: AppSizes.xl),
                          ],
                          if (controller.isLoading.value &&
                              controller.allTasks.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.xxl),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else ...[
                            _ProgressCard(
                              completed: controller.completedTodayTasks,
                              total: controller.totalTodayTasks,
                              pending: controller.pendingTodayTasks,
                              overdue: controller.overdueTasksCount,
                              ratio: controller.todayProgressPercent,
                              percentage: controller.todayProgressDisplay,
                              message: controller.progressMessage,
                            ),
                            const SizedBox(height: AppSizes.xl),
                            _QuickActions(
                              compact: constraints.maxWidth < 380,
                              onAddTask: controller.openAddTask,
                              onPlanner: controller.openPlanner,
                            ),
                            const SizedBox(height: AppSizes.xl),
                            _SectionTitle(title: 'Categories'),
                            const SizedBox(height: AppSizes.md),
                            _CategoryShortcutRow(
                              categories: controller.categories,
                              countForCategory:
                                  controller.incompleteCountForCategory,
                              onCategoryTap: controller.openCategory,
                            ),
                            const SizedBox(height: AppSizes.xl),
                            _TaskSection(
                              title: 'Today Focus',
                              tasks: controller.todayFocusTasks,
                              emptyIcon: Icons.self_improvement_rounded,
                              emptyTitle: 'No focus tasks',
                              emptySubtitle:
                                  'Add a task for today or enjoy the calm.',
                              onTaskTap: controller.openTask,
                              onToggle: controller.toggleTaskCompletion,
                              categoryForTask: controller.categoryById,
                              isOverdue: controller.isOverdue,
                            ),
                            const SizedBox(height: AppSizes.xl),
                            _TaskSection(
                              title: 'Upcoming Deadlines',
                              tasks: controller.upcomingDeadlineTasks,
                              emptyIcon: Icons.event_available_rounded,
                              emptyTitle: 'No upcoming deadlines',
                              emptySubtitle:
                                  'Your future looks surprisingly peaceful.',
                              onTaskTap: controller.openTask,
                              categoryForTask: controller.categoryById,
                              isOverdue: controller.isOverdue,
                            ),
                            const SizedBox(height: AppSizes.xl),
                            _TaskSection(
                              title: 'Recent Wins',
                              tasks: controller.recentCompletedTasks,
                              emptyIcon: Icons.emoji_events_rounded,
                              emptyTitle: 'No wins yet',
                              emptySubtitle:
                                  'Complete a task to start your streak.',
                              onTaskTap: controller.openTask,
                              categoryForTask: controller.categoryById,
                              isOverdue: controller.isOverdue,
                              completedDateLabel: _completedDateLabel,
                            ),
                          ],
                        ],
                      ),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.username, required this.onSettingsTap});

  final String username;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $username \u{1F44B}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: onSettingsTap,
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }
}

class _HomeErrorCard extends StatelessWidget {
  const _HomeErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.dangerRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Home needs a reload',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.blackStroke),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          BrutalButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            backgroundColor: AppColors.whiteCard,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.pending,
    required this.overdue,
    required this.ratio,
    required this.percentage,
    required this.message,
  });

  final int completed;
  final int total;
  final int pending;
  final int overdue;
  final double ratio;
  final int percentage;
  final String message;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.blackStroke),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  "Today's Progress",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.blackStroke,
                  ),
                ),
              ),
              BrutalBadge(label: '$percentage%'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            '$completed/$total tasks done',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.blackStroke),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 16,
              value: ratio,
              color: AppColors.blackStroke,
              backgroundColor: AppColors.whiteCard,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              BrutalBadge(
                label: '$pending pending',
                icon: Icons.pending_actions_rounded,
              ),
              BrutalBadge(
                label: '$overdue overdue',
                color: overdue > 0 ? AppColors.dangerRed : AppColors.whiteCard,
                icon: Icons.warning_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.compact,
    required this.onAddTask,
    required this.onPlanner,
  });

  final bool compact;
  final VoidCallback onAddTask;
  final VoidCallback onPlanner;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      BrutalButton(
        label: 'Add Task',
        icon: Icons.add_rounded,
        backgroundColor: AppColors.mintGreen,
        onTap: onAddTask,
        width: compact ? double.infinity : null,
      ),
      BrutalButton(
        label: 'Planner',
        icon: Icons.calendar_month_rounded,
        backgroundColor: AppColors.blue,
        onTap: onPlanner,
        width: compact ? double.infinity : null,
      ),
    ];
    return compact
        ? Column(
            children: [
              buttons.first,
              const SizedBox(height: AppSizes.md),
              buttons.last,
            ],
          )
        : Row(
            children: [
              Expanded(child: buttons.first),
              const SizedBox(width: AppSizes.lg),
              Expanded(child: buttons.last),
            ],
          );
  }
}

class _CategoryShortcutRow extends StatelessWidget {
  const _CategoryShortcutRow({
    required this.categories,
    required this.countForCategory,
    required this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final int Function(String categoryId) countForCategory;
  final ValueChanged<CategoryModel> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_off_rounded,
        title: 'No categories yet',
        subtitle: 'Default categories will appear after storage loads.',
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSizes.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          final count = countForCategory(category.id);
          return SizedBox(
            width: 144,
            child: BrutalCard(
              onTap: () => onCategoryTap(category),
              backgroundColor: _categoryColor(category),
              padding: const EdgeInsets.all(AppSizes.md),
              shadowOffset: const Offset(4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.folder_rounded,
                    color: AppColors.blackStroke,
                  ),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.blackStroke,
                    ),
                  ),
                  Text(
                    '$count open',
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
          );
        },
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onTaskTap,
    required this.categoryForTask,
    required this.isOverdue,
    this.onToggle,
    this.completedDateLabel,
  });

  final String title;
  final List<TaskModel> tasks;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final ValueChanged<TaskModel> onTaskTap;
  final ValueChanged<TaskModel>? onToggle;
  final CategoryModel Function(String? categoryId) categoryForTask;
  final bool Function(TaskModel task) isOverdue;
  final String Function(TaskModel task)? completedDateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: AppSizes.md),
        if (tasks.isEmpty)
          EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          )
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: _HomeTaskTile(
                task: task,
                category: categoryForTask(task.categoryId),
                isOverdue: isOverdue(task),
                dateLabel: completedDateLabel?.call(task),
                onTap: () => onTaskTap(task),
                onToggle: onToggle == null ? null : () => onToggle!(task),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeTaskTile extends StatelessWidget {
  const _HomeTaskTile({
    required this.task,
    required this.category,
    required this.isOverdue,
    required this.onTap,
    this.onToggle,
    this.dateLabel,
  });

  final TaskModel task;
  final CategoryModel category;
  final bool isOverdue;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final dueLabel =
        dateLabel ??
        (task.dueDate == null ? null : DateHelper.formatDate(task.dueDate!));
    return TaskTile(
      title: task.title,
      subtitle: task.description,
      isCompleted: task.isCompleted,
      isOverdue: isOverdue,
      categoryLabel: category.name,
      categoryColor: _categoryColor(category),
      priorityLabel: task.priority,
      priorityColor: _priorityColor(task.priority),
      dueLabel: dueLabel,
      subtasksCompleted: task.subtasks
          .where((subtask) => subtask.isCompleted)
          .length,
      subtasksTotal: task.subtasks.length,
      showCheckbox: onToggle != null,
      onToggle: onToggle,
      onTap: onTap,
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

String _completedDateLabel(TaskModel task) {
  final completedAt = task.completedAt;
  if (completedAt == null) {
    return 'Done';
  }
  final now = DateTime.now();
  if (completedAt.year == now.year &&
      completedAt.month == now.month &&
      completedAt.day == now.day) {
    return 'Today';
  }
  return DateHelper.formatDate(completedAt);
}
