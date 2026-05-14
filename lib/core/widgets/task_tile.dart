import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'brutal_badge.dart';
import 'brutal_card.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.title,
    super.key,
    this.subtitle,
    this.categoryLabel,
    this.categoryColor,
    this.priorityLabel,
    this.priorityColor,
    this.dueLabel,
    this.isOverdue = false,
    this.subtasksCompleted,
    this.subtasksTotal,
    this.isCompleted = false,
    this.showCheckbox = true,
    this.onToggle,
    this.onEdit,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? categoryLabel;
  final Color? categoryColor;
  final String? priorityLabel;
  final Color? priorityColor;
  final String? dueLabel;
  final bool isOverdue;
  final int? subtasksCompleted;
  final int? subtasksTotal;
  final bool isCompleted;
  final bool showCheckbox;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSubtasks = (subtasksTotal ?? 0) > 0;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      decoration: isCompleted ? TextDecoration.lineThrough : null,
      decorationThickness: 3,
    );
    return BrutalCard(
      onTap: onTap,
      backgroundColor: isCompleted
          ? AppColors.mintGreen
          : Theme.of(context).cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCheckbox) ...[
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xs),
                child: Icon(
                  isCompleted
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: AppColors.blackStroke,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSizes.md),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    if (categoryLabel != null)
                      BrutalBadge(
                        label: categoryLabel!,
                        color: categoryColor ?? AppColors.blue,
                      ),
                    if (priorityLabel != null)
                      BrutalBadge(
                        label: priorityLabel!,
                        color: priorityColor ?? AppColors.primaryYellow,
                        icon: Icons.flag_rounded,
                      ),
                    if (dueLabel != null)
                      BrutalBadge(
                        label: dueLabel!,
                        color: isOverdue
                            ? AppColors.dangerRed
                            : AppColors.whiteCard,
                        icon: Icons.event_rounded,
                      ),
                    if (isCompleted)
                      const BrutalBadge(
                        label: 'Completed',
                        color: AppColors.mintGreen,
                        icon: Icons.check_rounded,
                      ),
                    if (isOverdue)
                      const BrutalBadge(
                        label: 'Overdue',
                        color: AppColors.dangerRed,
                        icon: Icons.warning_rounded,
                      ),
                  ],
                ),
                if (hasSubtasks) ...[
                  const SizedBox(height: AppSizes.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: subtasksCompleted! / subtasksTotal!,
                      minHeight: 8,
                      color: AppColors.blackStroke,
                      backgroundColor: AppColors.blackStroke.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '$subtasksCompleted/$subtasksTotal subtasks',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: AppSizes.sm),
            IconButton(
              tooltip: 'Edit task',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
          ],
        ],
      ),
    );
  }
}
