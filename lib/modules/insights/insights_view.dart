import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/daily_insight_stat.dart';
import 'insights_controller.dart';

class InsightsView extends GetView<InsightsController> {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrutalAppBar(title: 'Insights'),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshInsights,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.allTasks.isEmpty) {
                    return const _InsightsLoadingState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.errorMessage.value != null) ...[
                        _InsightsErrorCard(
                          message: controller.errorMessage.value!,
                          onRetry: controller.refreshInsights,
                        ),
                        const SizedBox(height: AppSizes.xl),
                      ],
                      _InsightsHeader(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _MetricGrid(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      if (!controller.hasTasks) ...[
                        const EmptyState(
                          icon: Icons.insights_rounded,
                          title: 'No insights yet',
                          subtitle:
                              'Complete a few tasks and your stats will show up here.',
                        ),
                        const SizedBox(height: AppSizes.xl),
                      ],
                      _WeeklyProgressCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      if (controller.hasTasks &&
                          !controller.hasCompletedTasks) ...[
                        const EmptyState(
                          icon: Icons.task_alt_rounded,
                          title: 'No completed tasks yet',
                          subtitle: 'Finish one task to unlock real insights.',
                        ),
                        const SizedBox(height: AppSizes.xl),
                      ],
                      _MotivationCard(controller: controller),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightsLoadingState extends StatelessWidget {
  const _InsightsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSizes.xxl),
      child: BrutalCard(
        backgroundColor: AppColors.primaryYellow,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _InsightsErrorCard extends StatelessWidget {
  const _InsightsErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.dangerRed,
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppColors.blackStroke),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.blackStroke,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _InsightsHeader extends StatelessWidget {
  const _InsightsHeader({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.blackStroke),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  'Insights',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.blackStroke,
                  ),
                ),
              ),
              BrutalBadge(
                label: '${controller.allTasks.length} tasks',
                color: AppColors.whiteCard,
                icon: Icons.checklist_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            controller.productivityMessage.value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
        value: '${controller.completedToday.value}',
        icon: Icons.check_circle_rounded,
        color: AppColors.mintGreen,
      ),
      _MetricData(
        title: 'Weekly Completed',
        value: '${controller.completedThisWeek.value}',
        icon: Icons.calendar_view_week_rounded,
        color: AppColors.primaryYellow,
      ),
      _MetricData(
        title: 'Current Streak',
        value: '${controller.currentStreak.value} days',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.pink,
      ),
      _MetricData(
        title: 'Overdue Count',
        value: '${controller.overdueCount.value}',
        icon: Icons.warning_rounded,
        color: AppColors.dangerRed,
      ),
      _MetricData(
        title: 'Best Category',
        value: controller.bestCategoryName.value,
        icon: Icons.folder_special_rounded,
        color: AppColors.blue,
      ),
      _MetricData(
        title: 'Total Completed',
        value: '${controller.totalCompleted.value}',
        icon: Icons.done_all_rounded,
        color: AppColors.mintGreen,
      ),
      _MetricData(
        title: 'Completion Rate',
        value: '${controller.completionRatePercent}%',
        icon: Icons.pie_chart_rounded,
        color: AppColors.primaryYellow,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 560
            ? 3
            : constraints.maxWidth >= 380
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
            childAspectRatio: columns == 1 ? 3.3 : 1.3,
          ),
          itemBuilder: (context, index) {
            return _MetricCard(metric: metrics[index]);
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            metric.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
                label: '${controller.completedThisWeek.value} done',
                color: AppColors.pink,
                icon: Icons.task_alt_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Last 7 days including today',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!controller.hasWeeklyCompletions) ...[
            const SizedBox(height: AppSizes.lg),
            BrutalCard(
              backgroundColor: AppColors.whiteCard,
              padding: const EdgeInsets.all(AppSizes.md),
              shadowOffset: const Offset(3, 3),
              child: Row(
                children: [
                  const Icon(
                    Icons.timeline_rounded,
                    color: AppColors.blackStroke,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      'No weekly completions yet.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.blackStroke,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.lg),
          _WeeklyChart(
            stats: controller.weeklyStats,
            maxCompleted: controller.maxWeeklyCompleted,
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.stats, required this.maxCompleted});

  final List<DailyInsightStat> stats;
  final int maxCompleted;

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxCompleted <= 0 ? 1 : maxCompleted;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        if (compact) {
          return Column(
            children: stats
                .map(
                  (stat) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: _HorizontalWeeklyBar(
                      stat: stat,
                      ratio: stat.completedCount / effectiveMax,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: stats
                .map(
                  (stat) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xs,
                      ),
                      child: _VerticalWeeklyBar(
                        stat: stat,
                        ratio: stat.completedCount / effectiveMax,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _VerticalWeeklyBar extends StatelessWidget {
  const _VerticalWeeklyBar({required this.stat, required this.ratio});

  final DailyInsightStat stat;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${stat.completedCount}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSizes.xs),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.06, 1),
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: stat.completedCount == 0
                      ? AppColors.whiteCard
                      : AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(AppSizes.brutalRadius),
                  border: Border.all(
                    color: AppColors.blackStroke,
                    width: AppSizes.brutalBorder,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        FittedBox(
          child: Text(
            stat.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _HorizontalWeeklyBar extends StatelessWidget {
  const _HorizontalWeeklyBar({required this.stat, required this.ratio});

  final DailyInsightStat stat;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            stat.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.whiteCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.blackStroke,
                    width: AppSizes.brutalBorder,
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.04, 1),
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: stat.completedCount == 0
                        ? AppColors.whiteCard
                        : AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.blackStroke,
                      width: AppSizes.brutalBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        SizedBox(
          width: 28,
          child: Text(
            '${stat.completedCount}',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.blue,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.blackStroke),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productivity Message',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.blackStroke,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  controller.productivityMessage.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.blackStroke,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (controller.bestCategoryName.value != 'No category yet') ...[
                  const SizedBox(height: AppSizes.md),
                  BrutalBadge(
                    label: 'Best: ${controller.bestCategoryName.value}',
                    color: AppColors.whiteCard,
                    icon: Icons.folder_special_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
