import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import 'planner_controller.dart';

class PlannerView extends GetView<PlannerController> {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrutalAppBar(title: 'Planner'),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshPlannerData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.allTasks.isEmpty) {
                    return const _PlannerLoadingState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.errorMessage.value != null) ...[
                        _PlannerErrorCard(
                          message: controller.errorMessage.value!,
                          onRetry: controller.refreshPlannerData,
                        ),
                        const SizedBox(height: AppSizes.xl),
                      ],
                      _PlannerProgressCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _SectionHeader(
                        title: 'Top 3 Tasks',
                        actionLabel: 'Select',
                        actionIcon: Icons.add_task_rounded,
                        onAction: () => _showTaskPicker(context),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _TopTasksSection(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _SectionHeader(
                        title: 'Task Pool',
                        actionLabel: 'Add Task',
                        actionIcon: Icons.add_rounded,
                        onAction: controller.openAddTask,
                      ),
                      const SizedBox(height: AppSizes.md),
                      _CandidatePreview(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      Text(
                        'Time Blocks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSizes.md),
                      _TimeBlocksSection(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _ReflectionCard(controller: controller),
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

  Future<void> _showTaskPicker(BuildContext context) async {
    final searchController = TextEditingController();
    var query = '';
    await Get.bottomSheet<void>(
      StatefulBuilder(
        builder: (context, setModalState) {
          final tasks = controller.candidateTasksForQuery(query);
          return SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.86,
              ),
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: const BoxDecoration(
                color: AppColors.creamBackground,
                border: Border(
                  top: BorderSide(
                    color: AppColors.blackStroke,
                    width: AppSizes.brutalBorder,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose Top Tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: Get.back,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  BrutalTextField(
                    controller: searchController,
                    labelText: 'Search tasks',
                    hintText: 'Title, notes, or category',
                    prefixIcon: const Icon(Icons.search_rounded),
                    onChanged: (value) =>
                        setModalState(() => query = value.trim()),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Expanded(
                    child: tasks.isEmpty
                        ? const EmptyState(
                            icon: Icons.add_task_rounded,
                            title: 'No tasks to plan',
                            subtitle: 'Add a task first, then build your day.',
                          )
                        : ListView.separated(
                            itemCount: tasks.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSizes.md),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Obx(
                                () => _CandidateTaskTile(
                                  task: task,
                                  category: controller.categoryById(
                                    task.categoryId,
                                  ),
                                  isSelected: controller.isSelected(task.id),
                                  isOverdue: controller.isOverdue(task),
                                  onTap: controller.isSelected(task.id)
                                      ? null
                                      : () => controller.toggleTopTaskSelection(
                                          task,
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    searchController.dispose();
  }
}

class _PlannerLoadingState extends StatelessWidget {
  const _PlannerLoadingState();

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

class _PlannerErrorCard extends StatelessWidget {
  const _PlannerErrorCard({required this.message, required this.onRetry});

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

class _PlannerProgressCard extends StatelessWidget {
  const _PlannerProgressCard({required this.controller});

  final PlannerController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.plannedTasksTotal;
    final done = controller.plannedTasksDone;
    final progress = controller.plannerProgress;
    final message = total == 0
        ? 'Pick your Top 3 to shape the day.'
        : done == total
        ? 'You crushed your Top 3.'
        : 'Keep the plan moving.';

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
                  'Planner Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              BrutalBadge(
                label: '${controller.plannerProgressPercent}%',
                color: AppColors.whiteCard,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            '$done/$total planned tasks done',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 16,
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
                label: '${controller.selectedTopTasks.length}/3 selected',
                color: AppColors.whiteCard,
                icon: Icons.push_pin_rounded,
              ),
              BrutalBadge(
                label: _formatMinutes(controller.selectedEstimatedMinutes),
                color: AppColors.mintGreen,
                icon: Icons.timer_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          BrutalButton(
            label: actionLabel,
            icon: actionIcon,
            onTap: onAction,
            width: double.infinity,
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        BrutalButton(label: actionLabel, icon: actionIcon, onTap: onAction),
      ],
    );
  }
}

class _TopTasksSection extends StatelessWidget {
  const _TopTasksSection({required this.controller});

  final PlannerController controller;

  @override
  Widget build(BuildContext context) {
    final selectedTasks = controller.selectedTopTasks;
    if (selectedTasks.isEmpty) {
      return Column(
        children: [
          const EmptyState(
            icon: Icons.filter_3_rounded,
            title: 'No Top 3 selected',
            subtitle: 'Choose up to three tasks that deserve your best energy.',
          ),
          const SizedBox(height: AppSizes.md),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: _EmptyTopSlot(index: index),
            ),
          ),
        ],
      );
    }

    return Column(
      children: List.generate(3, (index) {
        if (index >= selectedTasks.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: _EmptyTopSlot(index: index),
          );
        }
        final task = selectedTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: _TopTaskCard(
            task: task,
            slotNumber: index + 1,
            category: controller.categoryById(task.categoryId),
            isOverdue: controller.isOverdue(task),
            onTap: () => controller.openTask(task),
            onToggle: () => controller.toggleTaskCompletion(task.id),
            onRemove: () => controller.removeTopTask(task.id),
            onEditEstimate: () =>
                _showEstimateDialog(context, controller, task),
            onClearEstimate: task.estimatedMinutes == null
                ? null
                : () => controller.updateTaskEstimatedMinutes(task.id, null),
            onEnergySelected: (energy) =>
                controller.updateTaskEnergyLevel(task.id, energy),
          ),
        );
      }),
    );
  }

  Future<void> _showEstimateDialog(
    BuildContext context,
    PlannerController controller,
    TaskModel task,
  ) async {
    final estimateController = TextEditingController(
      text: task.estimatedMinutes?.toString() ?? '',
    );
    await Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSizes.lg),
        child: BrutalCard(
          backgroundColor: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.md),
              BrutalTextField(
                controller: estimateController,
                labelText: 'Minutes',
                hintText: 'Example: 45',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.timer_rounded),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: BrutalButton(
                      label: 'Clear',
                      backgroundColor: AppColors.whiteCard,
                      onTap: () async {
                        await controller.updateTaskEstimatedMinutes(
                          task.id,
                          null,
                        );
                        Get.back<void>();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: BrutalButton(
                      label: 'Save',
                      icon: Icons.save_rounded,
                      onTap: () async {
                        final rawValue = estimateController.text.trim();
                        final minutes = rawValue.isEmpty
                            ? null
                            : int.tryParse(rawValue);
                        if (rawValue.isNotEmpty && minutes == null) {
                          Get.snackbar(
                            'Invalid estimate',
                            'Use whole minutes only.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryYellow,
                            colorText: AppColors.blackStroke,
                            margin: const EdgeInsets.all(AppSizes.lg),
                            borderColor: AppColors.blackStroke,
                            borderWidth: 3,
                          );
                          return;
                        }
                        await controller.updateTaskEstimatedMinutes(
                          task.id,
                          minutes,
                        );
                        Get.back<void>();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    estimateController.dispose();
  }
}

class _EmptyTopSlot extends StatelessWidget {
  const _EmptyTopSlot({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(AppSizes.md),
      shadowOffset: const Offset(3, 3),
      child: Row(
        children: [
          BrutalBadge(
            label: '#${index + 1}',
            color: AppColors.primaryYellow,
            icon: Icons.push_pin_rounded,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              'Empty Top 3 slot',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTaskCard extends StatelessWidget {
  const _TopTaskCard({
    required this.task,
    required this.slotNumber,
    required this.category,
    required this.isOverdue,
    required this.onTap,
    required this.onToggle,
    required this.onRemove,
    required this.onEditEstimate,
    required this.onEnergySelected,
    this.onClearEstimate,
  });

  final TaskModel task;
  final int slotNumber;
  final CategoryModel category;
  final bool isOverdue;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final VoidCallback onEditEstimate;
  final VoidCallback? onClearEstimate;
  final ValueChanged<String> onEnergySelected;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      onTap: onTap,
      backgroundColor: task.isCompleted
          ? AppColors.mintGreen
          : Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: AppColors.blackStroke,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrutalBadge(
                      label: 'Top $slotNumber',
                      color: AppColors.primaryYellow,
                      icon: Icons.push_pin_rounded,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationThickness: 3,
                      ),
                    ),
                    if ((task.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove from Top 3',
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              BrutalBadge(
                label: category.name,
                color: _categoryColor(category),
                icon: Icons.folder_rounded,
              ),
              BrutalBadge(
                label: task.priority,
                color: _priorityColor(task.priority),
                icon: Icons.flag_rounded,
              ),
              if (task.dueDate != null)
                BrutalBadge(
                  label: DateHelper.formatDate(task.dueDate!),
                  color: isOverdue ? AppColors.dangerRed : AppColors.whiteCard,
                  icon: Icons.event_rounded,
                ),
              if (isOverdue)
                const BrutalBadge(
                  label: 'Overdue',
                  color: AppColors.dangerRed,
                  icon: Icons.warning_rounded,
                ),
              if (task.isCompleted)
                const BrutalBadge(
                  label: 'Completed',
                  color: AppColors.mintGreen,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _EstimateRow(
            label: _formatNullableMinutes(task.estimatedMinutes),
            onEdit: onEditEstimate,
            onClear: onClearEstimate,
          ),
          const SizedBox(height: AppSizes.md),
          _EnergyChips(
            selectedEnergy: task.energyLevel,
            onSelected: onEnergySelected,
          ),
        ],
      ),
    );
  }
}

class _EstimateRow extends StatelessWidget {
  const _EstimateRow({required this.label, required this.onEdit, this.onClear});

  final String label;
  final VoidCallback onEdit;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BrutalButton(
            label: label,
            icon: Icons.timer_rounded,
            backgroundColor: AppColors.blue,
            onTap: onEdit,
            width: double.infinity,
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: AppSizes.md),
          IconButton(
            tooltip: 'Clear estimate',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ],
    );
  }
}

class _EnergyChips extends StatelessWidget {
  const _EnergyChips({required this.selectedEnergy, required this.onSelected});

  final String selectedEnergy;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: ['Low', 'Medium', 'High'].map((energy) {
        final selected = selectedEnergy == energy;
        return BrutalCard(
          onTap: () => onSelected(energy),
          backgroundColor: selected
              ? _energyColor(energy)
              : AppColors.whiteCard,
          shadowOffset: selected ? const Offset(4, 4) : const Offset(2, 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 16,
                color: AppColors.blackStroke,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                energy,
                style: const TextStyle(
                  color: AppColors.blackStroke,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CandidatePreview extends StatelessWidget {
  const _CandidatePreview({required this.controller});

  final PlannerController controller;

  @override
  Widget build(BuildContext context) {
    final candidates = controller.todayCandidateTasks;
    if (candidates.isEmpty) {
      return Column(
        children: [
          const EmptyState(
            icon: Icons.add_task_rounded,
            title: 'No tasks available',
            subtitle: 'Add a task first, then build your day.',
          ),
          const SizedBox(height: AppSizes.md),
          BrutalButton(
            label: 'Add Task',
            icon: Icons.add_rounded,
            width: double.infinity,
            onTap: controller.openAddTask,
          ),
        ],
      );
    }

    final previewTasks = candidates.take(3).toList();
    return Column(
      children: previewTasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: _CandidateTaskTile(
            task: task,
            category: controller.categoryById(task.categoryId),
            isSelected: controller.isSelected(task.id),
            isOverdue: controller.isOverdue(task),
            onTap: controller.isSelected(task.id)
                ? null
                : () => controller.toggleTopTaskSelection(task),
          ),
        );
      }).toList(),
    );
  }
}

class _CandidateTaskTile extends StatelessWidget {
  const _CandidateTaskTile({
    required this.task,
    required this.category,
    required this.isSelected,
    required this.isOverdue,
    required this.onTap,
  });

  final TaskModel task;
  final CategoryModel category;
  final bool isSelected;
  final bool isOverdue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      onTap: onTap,
      backgroundColor: isSelected
          ? AppColors.mintGreen
          : Theme.of(context).cardColor,
      padding: const EdgeInsets.all(AppSizes.md),
      shadowOffset: const Offset(3, 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.add_circle_rounded,
            color: AppColors.blackStroke,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    BrutalBadge(
                      label: category.name,
                      color: _categoryColor(category),
                    ),
                    BrutalBadge(
                      label: task.priority,
                      color: _priorityColor(task.priority),
                      icon: Icons.flag_rounded,
                    ),
                    if (task.dueDate != null)
                      BrutalBadge(
                        label: DateHelper.formatDate(task.dueDate!),
                        color: isOverdue
                            ? AppColors.dangerRed
                            : AppColors.whiteCard,
                        icon: Icons.event_rounded,
                      ),
                    if (task.isCompleted)
                      const BrutalBadge(
                        label: 'Completed',
                        color: AppColors.mintGreen,
                        icon: Icons.check_rounded,
                      ),
                    if (isSelected)
                      const BrutalBadge(
                        label: 'Selected',
                        color: AppColors.primaryYellow,
                        icon: Icons.push_pin_rounded,
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

class _TimeBlocksSection extends StatelessWidget {
  const _TimeBlocksSection({required this.controller});

  final PlannerController controller;

  @override
  Widget build(BuildContext context) {
    final slots = ['Morning push', 'Midday reset', 'Wrap-up'];
    final tasks = controller.selectedTopTasks;

    // TODO Phase 8: replace these simple visual slots with editable time blocks.
    return Column(
      children: List.generate(slots.length, (index) {
        final task = index < tasks.length ? tasks[index] : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: BrutalCard(
            backgroundColor: task == null
                ? Theme.of(context).cardColor
                : _energyColor(task.energyLevel),
            padding: const EdgeInsets.all(AppSizes.md),
            shadowOffset: const Offset(3, 3),
            child: Row(
              children: [
                BrutalBadge(
                  label: slots[index],
                  color: AppColors.whiteCard,
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    task?.title ?? 'No task planned',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (task != null)
                  BrutalBadge(
                    label: _formatNullableMinutes(task.estimatedMinutes),
                    color: AppColors.whiteCard,
                    icon: Icons.timer_rounded,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.controller});

  final PlannerController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.blackStroke),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  'Daily Reflection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          BrutalTextField(
            controller: controller.reflectionController,
            labelText: "What's one thing you want to remember from today?",
            hintText: 'Write a small note for future you',
            maxLines: 4,
            prefixIcon: const Icon(Icons.lightbulb_rounded),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.md,
            children: [
              BrutalButton(
                label: 'Save Reflection',
                icon: Icons.save_rounded,
                onTap: () => controller.saveReflection(
                  controller.reflectionController.text,
                ),
              ),
              BrutalButton(
                label: 'Clear Plan',
                icon: Icons.restart_alt_rounded,
                backgroundColor: AppColors.whiteCard,
                onTap: controller.clearTodayPlanner,
              ),
            ],
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

Color _energyColor(String energyLevel) {
  return switch (energyLevel.toLowerCase()) {
    'high' => AppColors.pink,
    'low' => AppColors.blue,
    _ => AppColors.mintGreen,
  };
}

String _formatNullableMinutes(int? minutes) {
  if (minutes == null) {
    return 'No estimate';
  }
  return _formatMinutes(minutes);
}

String _formatMinutes(int minutes) {
  if (minutes <= 0) {
    return 'No estimate';
  }
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (hours == 0) {
    return '$minutes min';
  }
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainingMinutes}m';
}
