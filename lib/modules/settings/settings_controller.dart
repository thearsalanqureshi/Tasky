import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/mock/tasky_mock_data.dart';
import '../main_nav/main_nav_controller.dart';

class SettingsController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final Rx<ThemeMode> selectedThemeMode = ThemeMode.system.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxInt dailyGoal = 5.obs;
  final RxString usernameText = TaskyMockData.usernameFallback.obs;

  String get username {
    if (usernameText.value.trim().isEmpty) {
      return TaskyMockData.usernameFallback;
    }
    return usernameText.value.trim();
  }

  String get initials {
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final end = parts.first.length.clamp(1, 2).toInt();
      return parts.first.substring(0, end).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<MainNavController>()) {
      final mainNavController = Get.find<MainNavController>();
      usernameController.text = mainNavController.username.value;
      usernameText.value = mainNavController.username.value;
      dailyGoal.value = mainNavController.dailyGoal.value;
    } else {
      usernameController.text = TaskyMockData.usernameFallback;
      usernameText.value = TaskyMockData.usernameFallback;
    }
  }

  void updateUsername(String value) {
    usernameText.value = value.trim().isEmpty
        ? TaskyMockData.usernameFallback
        : value.trim();
    if (Get.isRegistered<MainNavController>() && value.trim().isNotEmpty) {
      Get.find<MainNavController>().username.value = value.trim();
    }
  }

  void setThemeMode(ThemeMode mode) {
    selectedThemeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    Get.snackbar(
      'Prototype only',
      'Notification permissions will be handled in Phase 4',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryYellow,
      colorText: AppColors.blackStroke,
      margin: const EdgeInsets.all(AppSizes.lg),
      borderColor: AppColors.blackStroke,
      borderWidth: 3,
    );
  }

  void incrementGoal() {
    if (dailyGoal.value < 12) {
      dailyGoal.value++;
      _syncDailyGoal();
    }
  }

  void decrementGoal() {
    if (dailyGoal.value > 1) {
      dailyGoal.value--;
      _syncDailyGoal();
    }
  }

  void showPrototypeAction(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryYellow,
      colorText: AppColors.blackStroke,
      margin: const EdgeInsets.all(AppSizes.lg),
      borderColor: AppColors.blackStroke,
      borderWidth: 3,
    );
  }

  void _syncDailyGoal() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().dailyGoal.value = dailyGoal.value;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }
}
