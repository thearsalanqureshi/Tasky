import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';

class BrutalBottomNav extends StatelessWidget {
  const BrutalBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_BrutalNavItem> _items = [
    _BrutalNavItem(label: AppStrings.home, icon: Icons.home_rounded),
    _BrutalNavItem(label: AppStrings.tasks, icon: Icons.check_box_rounded),
    _BrutalNavItem(
      label: AppStrings.planner,
      icon: Icons.calendar_month_rounded,
    ),
    _BrutalNavItem(label: AppStrings.insights, icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.sm,
            AppSizes.lg,
            AppSizes.lg,
          ),
          child: Container(
            padding: EdgeInsets.all(compact ? 6 : AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.blackStroke,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.blackStroke, width: 3),
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = currentIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.symmetric(
                          vertical: compact ? 7 : AppSizes.sm,
                          horizontal: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryYellow
                              : AppColors.whiteCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.blackStroke,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: compact ? 20 : 22,
                              color: AppColors.blackStroke,
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                style: TextStyle(
                                  color: AppColors.blackStroke,
                                  fontSize: compact ? 10 : 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _BrutalNavItem {
  const _BrutalNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
