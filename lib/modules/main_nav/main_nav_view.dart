import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/brutal_bottom_nav.dart';
import '../home/home_view.dart';
import '../insights/insights_view.dart';
import '../planner/planner_view.dart';
import '../tasks/tasks_view.dart';
import 'main_nav_controller.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final useRail = ResponsiveHelper.isTablet(context);
      final body = IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomeView(),
          TasksView(),
          PlannerView(),
          InsightsView(),
        ],
      );

      if (useRail) {
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                _BrutalNavigationRail(
                  selectedIndex: controller.currentIndex.value,
                  onDestinationSelected: controller.changeTab,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        body: body,
        bottomNavigationBar: BrutalBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      );
    });
  }
}

class _BrutalNavigationRail extends StatelessWidget {
  const _BrutalNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    (label: AppStrings.home, icon: Icons.home_rounded),
    (label: AppStrings.tasks, icon: Icons.check_box_rounded),
    (label: AppStrings.planner, icon: Icons.calendar_month_rounded),
    (label: AppStrings.insights, icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      margin: const EdgeInsets.all(AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.blackStroke,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: InkWell(
              onTap: () => onDestinationSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryYellow
                      : AppColors.whiteCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.blackStroke, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(item.icon, color: AppColors.blackStroke),
                    const SizedBox(height: AppSizes.xs),
                    FittedBox(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: AppColors.blackStroke,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
