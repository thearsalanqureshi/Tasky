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
import '../../data/mock/tasky_mock_data.dart';
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => _HomeHeader(
                          username: controller.username,
                          onSettingsTap: controller.openSettings,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _ProgressCard(
                        completed: controller.completedCount,
                        total: controller.totalCount,
                        ratio: controller.progressRatio,
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
                      _CategoryShortcutRow(categories: controller.categories),
                      const SizedBox(height: AppSizes.xl),
                      _TaskSection(
                        title: 'Today Focus',
                        tasks: controller.todayFocus,
                        emptyTitle: 'No focus tasks',
                        emptySubtitle: 'Today is clear in the mock plan.',
                        onTaskTap: controller.openTask,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _TaskSection(
                        title: 'Upcoming Deadlines',
                        tasks: controller.upcomingDeadlines,
                        emptyTitle: 'No deadlines',
                        emptySubtitle: 'Nothing urgent is queued up.',
                        onTaskTap: controller.openTask,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _TaskSection(
                        title: 'Recent Wins',
                        tasks: controller.recentWins,
                        emptyTitle: 'No wins yet',
                        emptySubtitle: 'Completed tasks will show here later.',
                        onTaskTap: controller.openTask,
                      ),
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
                'Hello, $username 👋',
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.ratio,
  });

  final int completed;
  final int total;
  final double ratio;

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
                  'Today Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              BrutalBadge(label: '${(ratio * 100).round()}%'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            '$completed/$total tasks done',
            style: Theme.of(context).textTheme.headlineMedium,
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
  const _CategoryShortcutRow({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSizes.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          return SizedBox(
            width: 132,
            child: BrutalCard(
              backgroundColor: TaskyMockData.categoryColor(category.id),
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
                    style: Theme.of(context).textTheme.titleMedium,
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
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onTaskTap,
  });

  final String title;
  final List<TaskModel> tasks;
  final String emptyTitle;
  final String emptySubtitle;
  final ValueChanged<TaskModel> onTaskTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: AppSizes.md),
        if (tasks.isEmpty)
          EmptyState(
            icon: Icons.inbox_rounded,
            title: emptyTitle,
            subtitle: emptySubtitle,
          )
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: _HomeTaskTile(task: task, onTap: () => onTaskTap(task)),
            ),
          ),
      ],
    );
  }
}

class _HomeTaskTile extends StatelessWidget {
  const _HomeTaskTile({required this.task, required this.onTap});

  final TaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = TaskyMockData.categoryById(task.categoryId);
    return TaskTile(
      title: task.title,
      subtitle: task.description,
      isCompleted: task.isCompleted,
      isOverdue: TaskyMockData.isOverdue(task),
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
