import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_card.dart';
import '../../data/mock/tasky_mock_data.dart';
import 'insights_controller.dart';

class InsightsView extends GetView<InsightsController> {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrutalAppBar(title: 'Insights'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricGrid(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  _WeeklyProgressCard(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  BrutalCard(
                    backgroundColor: AppColors.primaryYellow,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.campaign_rounded,
                          color: AppColors.blackStroke,
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keep the streak loud',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                'One honest task finished today beats ten perfect plans waiting for tomorrow.',
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

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        title: 'Completed Today',
        value: '${controller.completedToday}',
        icon: Icons.check_circle_rounded,
        color: AppColors.mintGreen,
      ),
      _MetricData(
        title: 'Current Streak',
        value: '${controller.currentStreak} days',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.primaryYellow,
      ),
      _MetricData(
        title: 'Overdue Count',
        value: '${controller.overdueCount}',
        icon: Icons.warning_rounded,
        color: AppColors.dangerRed,
      ),
      _MetricData(
        title: 'Best Category',
        value: controller.bestCategory,
        icon: Icons.folder_special_rounded,
        color: AppColors.blue,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: columns == 1 ? 3.4 : 1.35,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return BrutalCard(
              backgroundColor: metric.color,
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(metric.icon, color: AppColors.blackStroke),
                  const Spacer(),
                  Text(
                    metric.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    metric.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              BrutalBadge(
                label:
                    '${controller.weeklyCompleted}/${controller.weeklyTotal}',
                color: AppColors.pink,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          ...controller.weeklyStats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: _WeeklyBar(stat: stat),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({required this.stat});

  final WeeklyStat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(stat.day, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stat.ratio,
              minHeight: 18,
              color: AppColors.primaryYellow,
              backgroundColor: AppColors.blackStroke.withValues(alpha: 0.12),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        SizedBox(
          width: 48,
          child: Text(
            '${stat.completed}/${stat.total}',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
