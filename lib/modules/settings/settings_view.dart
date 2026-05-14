import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/brutal_app_bar.dart';
import '../../core/widgets/brutal_badge.dart';
import '../../core/widgets/brutal_button.dart';
import '../../core/widgets/brutal_card.dart';
import '../../core/widgets/brutal_text_field.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrutalAppBar(
        title: 'Settings',
        trailing: IconButton(
          tooltip: 'Close',
          onPressed: Get.back,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(
          () => RefreshIndicator(
            onRefresh: controller.loadSettings,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.errorMessage.value != null) ...[
                        _SettingsErrorCard(
                          message: controller.errorMessage.value!,
                          onRetry: controller.loadSettings,
                        ),
                        const SizedBox(height: AppSizes.xl),
                      ],
                      _ProfileCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _ThemeCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _DailyGoalCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _NotificationCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      _DataManagementCard(controller: controller),
                      const SizedBox(height: AppSizes.xl),
                      const _AboutCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsErrorCard extends StatelessWidget {
  const _SettingsErrorCard({required this.message, required this.onRetry});

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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final avatar = _AvatarBox(controller: controller);
          final form = _ProfileForm(controller: controller);

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: AppSizes.lg),
                form,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: AppSizes.lg),
              Expanded(child: form),
            ],
          );
        },
      ),
    );
  }
}

class _AvatarBox extends StatelessWidget {
  const _AvatarBox({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final path = controller.avatarPath.value;
      return Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.blackStroke, width: 3),
        ),
        child: path.isEmpty
            ? Text(
                controller.initials,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.blackStroke,
                  fontWeight: FontWeight.w900,
                ),
              )
            : Image.file(
                File(path),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Text(
                  controller.initials,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.blackStroke,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      );
    });
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.blackStroke),
        ),
        const SizedBox(height: AppSizes.md),
        BrutalTextField(
          controller: controller.usernameController,
          labelText: 'Username',
          prefixIcon: const Icon(Icons.person_rounded),
          textInputAction: TextInputAction.done,
          onChanged: controller.updateUsernameDraft,
        ),
        const SizedBox(height: AppSizes.md),
        Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          children: [
            BrutalButton(
              label: 'Save Name',
              icon: Icons.save_rounded,
              backgroundColor: AppColors.whiteCard,
              onTap: () =>
                  controller.saveUsername(controller.usernameController.text),
            ),
            BrutalButton(
              label: 'Change Avatar',
              icon: Icons.image_rounded,
              backgroundColor: AppColors.mintGreen,
              onTap: controller.pickAvatarImage,
            ),
            Obx(
              () => controller.hasAvatarImage
                  ? BrutalButton(
                      label: 'Remove Avatar',
                      icon: Icons.delete_rounded,
                      backgroundColor: AppColors.dangerRed,
                      onTap: () => _confirm(
                        context,
                        title: 'Remove avatar?',
                        message: 'Tasky will switch back to your initials.',
                        confirmLabel: 'Remove',
                        onConfirm: controller.removeAvatarImage,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Choose how Tasky looks on this device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.md),
          Obx(
            () => Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                _ThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  selected:
                      controller.selectedThemeMode.value == ThemeMode.light,
                  onTap: () => controller.changeThemeMode(ThemeMode.light),
                ),
                _ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  selected:
                      controller.selectedThemeMode.value == ThemeMode.dark,
                  onTap: () => controller.changeThemeMode(ThemeMode.dark),
                ),
                _ThemeOption(
                  label: 'System',
                  icon: Icons.settings_suggest_rounded,
                  selected:
                      controller.selectedThemeMode.value == ThemeMode.system,
                  onTap: () => controller.changeThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      onTap: onTap,
      backgroundColor: selected ? AppColors.primaryYellow : AppColors.whiteCard,
      shadowOffset: selected ? const Offset(4, 4) : const Offset(2, 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.blackStroke),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.mintGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productivity',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.blackStroke),
          ),
          const SizedBox(height: AppSizes.md),
          BrutalTextField(
            controller: controller.dailyGoalController,
            labelText: 'Daily goal',
            hintText: '1 to 99 tasks',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.flag_rounded),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Obx(
                () => BrutalBadge(
                  label: '${controller.dailyGoal.value} tasks/day',
                  color: AppColors.whiteCard,
                  icon: Icons.track_changes_rounded,
                ),
              ),
              BrutalButton(
                label: 'Save Goal',
                icon: Icons.save_rounded,
                backgroundColor: AppColors.whiteCard,
                onTap: () {
                  final value = int.tryParse(
                    controller.dailyGoalController.text.trim(),
                  );
                  if (value == null) {
                    controller.updateDailyGoal(0);
                    return;
                  }
                  controller.updateDailyGoal(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.blackStroke),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Tasky asks for permission only when reminders are enabled.',
            style: TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Enable task reminders',
                style: TextStyle(
                  color: AppColors.blackStroke,
                  fontWeight: FontWeight.w900,
                ),
              ),
              value: controller.notificationsEnabled.value,
              activeThumbColor: AppColors.blackStroke,
              activeTrackColor: AppColors.mintGreen,
              onChanged: controller.toggleNotifications,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Obx(
            () => Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                BrutalBadge(
                  label: 'Default ${controller.defaultReminderTime.value}',
                  color: AppColors.whiteCard,
                  icon: Icons.alarm_rounded,
                ),
                BrutalButton(
                  label: 'Pick Time',
                  icon: Icons.schedule_rounded,
                  backgroundColor: AppColors.whiteCard,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _timeFromString(
                        controller.defaultReminderTime.value,
                      ),
                    );
                    if (picked == null) {
                      return;
                    }
                    await controller.updateDefaultReminderTime(
                      _formatTime(picked),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataManagementCard extends StatelessWidget {
  const _DataManagementCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Management',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          _ActionRow(
            icon: Icons.cleaning_services_rounded,
            label: 'Clear completed tasks',
            onTap: () => _confirm(
              context,
              title: 'Clear completed tasks?',
              message: 'Completed tasks will be removed from local storage.',
              confirmLabel: 'Clear',
              onConfirm: controller.clearCompletedTasks,
            ),
          ),
          _ActionRow(
            icon: Icons.replay_rounded,
            label: 'Reset onboarding',
            onTap: () => _confirm(
              context,
              title: 'Reset onboarding?',
              message: 'The next fresh launch will show onboarding again.',
              confirmLabel: 'Reset',
              onConfirm: controller.resetOnboarding,
            ),
          ),
          _ActionRow(
            icon: Icons.delete_forever_rounded,
            label: 'Reset all Tasky data',
            danger: true,
            onTap: () => _confirm(
              context,
              title: 'Reset everything?',
              message:
                  'This clears local tasks, planner data, profile, avatar, and settings. This cannot be undone.',
              confirmLabel: 'Reset Everything',
              danger: true,
              onConfirm: controller.resetAllTaskyData,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: BrutalCard(
        onTap: onTap,
        backgroundColor: danger ? AppColors.dangerRed : AppColors.whiteCard,
        shadowOffset: const Offset(3, 3),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blackStroke),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.blackStroke,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.blackStroke,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: AppColors.primaryYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Tasky',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.blackStroke),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Offline-first task planning. Your tasks, profile, and settings stay on this device.',
            style: TextStyle(
              color: AppColors.blackStroke,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const BrutalBadge(
            label: 'Version 0.1.0+1',
            color: AppColors.whiteCard,
            icon: Icons.info_rounded,
          ),
        ],
      ),
    );
  }
}

void _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function() onConfirm,
  bool danger = false,
}) {
  Get.dialog<void>(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSizes.lg),
      child: BrutalCard(
        backgroundColor: Theme.of(context).cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.sm),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: BrutalButton(
                    label: 'Cancel',
                    backgroundColor: AppColors.whiteCard,
                    onTap: Get.back,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: BrutalButton(
                    label: confirmLabel,
                    backgroundColor: danger
                        ? AppColors.dangerRed
                        : AppColors.primaryYellow,
                    onTap: () async {
                      Get.back<void>();
                      await onConfirm();
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
}

TimeOfDay _timeFromString(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return const TimeOfDay(hour: 9, minute: 0);
  }
  final hour = int.tryParse(parts[0]) ?? 9;
  final minute = int.tryParse(parts[1]) ?? 0;
  return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
