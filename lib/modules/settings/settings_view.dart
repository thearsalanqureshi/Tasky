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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileCard(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  _ThemeCard(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  _NotificationCard(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  _DailyGoalCard(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  _PrototypeActions(controller: controller),
                  const SizedBox(height: AppSizes.xl),
                  const _AboutCard(),
                ],
              ),
            ),
          ),
        ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.whiteCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.blackStroke, width: 3),
              ),
              child: Text(
                controller.initials,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSizes.md),
                BrutalTextField(
                  controller: controller.usernameController,
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_rounded),
                  onChanged: controller.updateUsername,
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Avatar image picking is planned for a later phase.',
                  style: TextStyle(
                    color: AppColors.blackStroke,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  onTap: () => controller.setThemeMode(ThemeMode.light),
                ),
                _ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  selected:
                      controller.selectedThemeMode.value == ThemeMode.dark,
                  onTap: () => controller.setThemeMode(ThemeMode.dark),
                ),
                _ThemeOption(
                  label: 'System',
                  icon: Icons.settings_suggest_rounded,
                  selected:
                      controller.selectedThemeMode.value == ThemeMode.system,
                  onTap: () => controller.setThemeMode(ThemeMode.system),
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
      backgroundColor: selected
          ? AppColors.primaryYellow
          : Theme.of(context).cardColor,
      shadowOffset: selected ? const Offset(4, 4) : const Offset(2, 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: AppSizes.xs),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
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
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.md),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable reminders',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Prototype toggle only',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: controller.notificationsEnabled.value,
              activeThumbColor: AppColors.blackStroke,
              activeTrackColor: AppColors.mintGreen,
              onChanged: controller.toggleNotifications,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const BrutalBadge(
            label: 'Default reminder: 9:00 AM',
            color: AppColors.whiteCard,
            icon: Icons.alarm_rounded,
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
      child: Obx(
        () => Row(
          children: [
            const Icon(Icons.flag_rounded, color: AppColors.blackStroke),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                'Daily goal: ${controller.dailyGoal.value} tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Decrease daily goal',
              onPressed: controller.decrementGoal,
              icon: const Icon(Icons.remove_rounded),
            ),
            IconButton(
              tooltip: 'Increase daily goal',
              onPressed: controller.incrementGoal,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrototypeActions extends StatelessWidget {
  const _PrototypeActions({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prototype Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          _ActionRow(
            icon: Icons.replay_rounded,
            label: 'Reset onboarding UI',
            onTap: () => _confirm(
              context,
              title: 'Reset onboarding?',
              message: 'Phase 3 will wire this to local storage.',
              onConfirm: () => controller.showPrototypeAction(
                'Prototype only',
                'Onboarding reset will be implemented in Phase 3',
              ),
            ),
          ),
          _ActionRow(
            icon: Icons.cleaning_services_rounded,
            label: 'Clear completed tasks',
            onTap: () => _confirm(
              context,
              title: 'Clear completed tasks?',
              message: 'This prototype will not remove mock tasks.',
              onConfirm: () => controller.showPrototypeAction(
                'Prototype only',
                'Clearing completed tasks will be implemented in Phase 4',
              ),
            ),
          ),
          _ActionRow(
            icon: Icons.delete_forever_rounded,
            label: 'Reset all data',
            danger: true,
            onTap: () => _confirm(
              context,
              title: 'Reset all data?',
              message: 'No local data exists yet, so nothing will be changed.',
              onConfirm: () => controller.showPrototypeAction(
                'Prototype only',
                'Full reset will be implemented after persistence exists',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
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
                      label: 'Confirm',
                      backgroundColor: AppColors.dangerRed,
                      onTap: () {
                        Get.back<void>();
                        onConfirm();
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
          Text('About Tasky', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Offline-first student productivity prototype. Version 0.1.0+1.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
