import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_card.dart';
import 'planner_controller.dart';

class PlannerView extends GetView<PlannerController> {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrutalAppBar(title: 'Planner'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => _DailyPlanCard(
                      ratio: controller.progressRatio,
                      totalMinutes: controller.totalEstimatedMinutes,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Text(
                    'Top 3 Priorities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _PriorityTasks(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  Text(
                    'Time Blocks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Obx(
                    () => Column(
                      children: controller.timeBlocks
                          .map(
                            (block) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.md,
                              ),
                              child: _TimeBlockTile(
                                block: block,
                                checked: controller.checkedBlocks.contains(
                                  block.id,
                                ),
                                onTap: () => controller.toggleBlock(block.id),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  BrutalCard(
                    backgroundColor: AppColors.pink,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.blackStroke,
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reflection prompt',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                'What is one small win you can finish before the day ends?',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyPlanCard extends StatelessWidget {
  const _DailyPlanCard({required this.ratio, required this.totalMinutes});

  final double ratio;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.blackStroke,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Daily Plan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              BrutalBadge(label: '$totalMinutes min'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            '${(ratio * 100).round()}% planned progress',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 16,
              color: AppColors.blackStroke,
              backgroundColor: AppColors.whiteCard,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityTasks extends StatelessWidget {
  const _PriorityTasks({required this.controller});

  final PlannerController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = constraints.maxWidth >= 700;
        final tasks = controller.priorityTasks;
        if (!useGrid) {
          return Column(
            children: tasks
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: _PriorityCard(
                      title: task.title,
                      minutes: task.estimatedMinutes,
                    ),
                  ),
                )
                .toList(),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _PriorityCard(
              title: task.title,
              minutes: task.estimatedMinutes,
            );
          },
        );
      },
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.title, required this.minutes});

  final String title;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.mintGreen,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.priority_high_rounded, color: AppColors.blackStroke),
          const SizedBox(height: AppSizes.lg),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.xs),
          Text('$minutes min', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TimeBlockTile extends StatelessWidget {
  const _TimeBlockTile({
    required this.block,
    required this.checked,
    required this.onTap,
  });

  final PlannerBlock block;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final energyColor = switch (block.energy) {
      'High' => AppColors.pink,
      'Medium' => AppColors.primaryYellow,
      _ => AppColors.mintGreen,
    };
    return BrutalCard(
      onTap: onTap,
      backgroundColor: checked
          ? AppColors.mintGreen
          : Theme.of(context).cardColor,
      child: Row(
        children: [
          Icon(
            checked
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: AppColors.blackStroke,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(block.time, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSizes.xs),
                Text(
                  block.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    BrutalBadge(label: block.energy, color: energyColor),
                    BrutalBadge(
                      label: '${block.estimatedMinutes} min',
                      color: AppColors.whiteCard,
                      icon: Icons.timer_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
