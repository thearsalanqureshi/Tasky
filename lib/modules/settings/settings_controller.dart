import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/planner_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/avatar_storage_service.dart';
import '../../data/services/notification_service.dart';
import '../home/home_controller.dart';
import '../insights/insights_controller.dart';
import '../main_nav/main_nav_controller.dart';
import '../planner/planner_controller.dart';
import '../tasks/tasks_controller.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._profileRepository,
    this._settingsRepository,
    this._taskRepository,
    this._plannerRepository,
    this._categoryRepository,
    this._avatarStorageService,
  );

  final ProfileRepository _profileRepository;
  final SettingsRepository _settingsRepository;
  final TaskRepository _taskRepository;
  final PlannerRepository _plannerRepository;
  final CategoryRepository _categoryRepository;
  final AvatarStorageService _avatarStorageService;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dailyGoalController = TextEditingController();

  final RxString username = UserProfileModel.defaultUsername.obs;
  final RxString avatarPath = ''.obs;
  final RxInt dailyGoal = AppSettingsModel.defaultDailyGoal.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxString defaultReminderTime =
      AppSettingsModel.defaultReminderTimeValue.obs;
  final Rx<ThemeMode> selectedThemeMode = ThemeMode.system.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final loadedUsername = _profileRepository.getUsername();
      final loadedAvatarPath = _profileRepository.getAvatarPath();
      final avatarExists =
          loadedAvatarPath != null &&
          await _avatarStorageService.avatarFileExists(loadedAvatarPath);

      username.value = _safeUsername(loadedUsername);
      usernameController.text = username.value;
      avatarPath.value = avatarExists ? loadedAvatarPath : '';
      if (loadedAvatarPath != null && !avatarExists) {
        await _profileRepository.clearAvatarPath();
      }

      selectedThemeMode.value = _settingsRepository.getThemeMode();
      dailyGoal.value = _settingsRepository.getDailyGoal();
      dailyGoalController.text = dailyGoal.value.toString();
      notificationsEnabled.value = _settingsRepository
          .getNotificationsEnabled();
      defaultReminderTime.value = _settingsRepository.getDefaultReminderTime();

      _syncMainNavState();
    } catch (_) {
      errorMessage.value = 'Could not load settings.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUsername(String value) async {
    final safeUsername = _safeUsername(value);
    final saved = await _profileRepository.saveUsername(safeUsername);
    if (!saved) {
      _showSnack('Could not save username', 'Please try again.');
      return;
    }
    username.value = safeUsername;
    usernameController.text = safeUsername;
    _syncMainNavState();
    await _refreshHome();
    _showSnack('Username saved', 'Your profile name was saved offline.');
  }

  Future<void> updateDailyGoal(int value) async {
    if (value < 1 || value > 99) {
      _showSnack('Invalid goal', 'Daily goal must be between 1 and 99.');
      dailyGoalController.text = dailyGoal.value.toString();
      return;
    }
    final saved = await _settingsRepository.saveDailyGoal(value);
    if (!saved) {
      _showSnack('Could not save goal', 'Please try again.');
      return;
    }
    dailyGoal.value = value;
    dailyGoalController.text = value.toString();
    _syncMainNavState();
    _showSnack('Daily goal saved', 'Your daily goal was updated.');
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    selectedThemeMode.value = mode;
    Get.changeThemeMode(mode);
    final saved = await _settingsRepository.saveThemeMode(mode);
    if (!saved) {
      _showSnack('Could not save theme', 'Please try again.');
      return;
    }
    _showSnack('Theme saved', 'Tasky will remember this theme.');
  }

  Future<void> toggleNotifications(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        notificationsEnabled.value = false;
        await _settingsRepository.saveNotificationsEnabled(false);
        await _notificationService.cancelAllTaskReminders();
        _showSnack(
          'Permission denied',
          'Enable notification permission in system settings to use reminders.',
        );
        return;
      }

      final saved = await _settingsRepository.saveNotificationsEnabled(true);
      if (!saved) {
        _showSnack('Could not save preference', 'Please try again.');
        return;
      }

      notificationsEnabled.value = true;
      await _scheduleEligibleTaskReminders();
      _showSnack(
        'Notifications enabled',
        'Tasky will schedule local reminders on this device.',
      );
      return;
    }

    final saved = await _settingsRepository.saveNotificationsEnabled(false);
    if (!saved) {
      _showSnack('Could not save preference', 'Please try again.');
      return;
    }
    notificationsEnabled.value = false;
    await _notificationService.cancelAllTaskReminders();
    _showSnack(
      'Notifications disabled',
      'All scheduled Tasky reminders were cancelled.',
    );
  }

  Future<void> updateDefaultReminderTime(String value) async {
    final safeTime = AppSettingsModel.safeReminderTime(value);
    final saved = await _settingsRepository.saveDefaultReminderTime(safeTime);
    if (!saved) {
      _showSnack('Could not save reminder time', 'Please try again.');
      return;
    }
    defaultReminderTime.value = safeTime;
    _showSnack('Reminder time saved', 'Default reminder preference updated.');
  }

  Future<void> pickAvatarImage() async {
    final pickedImage = await _avatarStorageService.pickImageFromGallery();
    if (pickedImage == null) {
      return;
    }

    final previousPath = avatarPath.value.trim().isEmpty
        ? null
        : avatarPath.value;
    final savedPath = await _avatarStorageService.saveAvatarFile(
      pickedImage,
      previousAvatarPath: previousPath,
    );
    if (savedPath == null) {
      _showSnack('Could not save avatar', 'Please try another image.');
      return;
    }

    final saved = await _profileRepository.saveAvatarPath(savedPath);
    if (!saved) {
      await _avatarStorageService.deleteAvatarFile(savedPath);
      _showSnack('Could not save avatar', 'Please try again.');
      return;
    }
    avatarPath.value = savedPath;
    _showSnack('Avatar saved', 'Your profile image is stored on this device.');
  }

  Future<void> removeAvatarImage() async {
    final removed = await _profileRepository.clearAvatarPath();
    avatarPath.value = '';
    if (!removed) {
      _showSnack('Avatar removed', 'Tasky is using your initials again.');
      return;
    }
    _showSnack('Avatar removed', 'Tasky is using your initials again.');
  }

  Future<void> resetOnboarding() async {
    final saved = await _settingsRepository.saveOnboardingCompleted(false);
    if (!saved) {
      _showSnack('Could not reset onboarding', 'Please try again.');
      return;
    }
    _showSnack(
      'Onboarding reset',
      'The next fresh launch will show onboarding again.',
    );
  }

  Future<void> clearCompletedTasks() async {
    final completedTaskIds = _taskRepository
        .getTasks()
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();
    final cleared = await _taskRepository.clearCompletedTasks();
    if (!cleared) {
      _showSnack('Could not clear tasks', 'Please try again.');
      return;
    }
    for (final taskId in completedTaskIds) {
      await _notificationService.cancelTaskReminder(taskId);
    }
    await _refreshTaskDataControllers();
    _showSnack('Completed tasks cleared', 'Open tasks were left untouched.');
  }

  Future<void> resetAllTaskyData() async {
    final previousAvatarPath = avatarPath.value.trim().isEmpty
        ? null
        : avatarPath.value;
    if (previousAvatarPath != null) {
      await _avatarStorageService.deleteAvatarFile(previousAvatarPath);
    }

    await _notificationService.cancelAllTaskReminders();

    await Future.wait([
      _taskRepository.clearAllTasks(),
      _plannerRepository.clearAllPlannerData(),
      _profileRepository.clearProfile(),
      _settingsRepository.saveSettings(const AppSettingsModel()),
      _categoryRepository.saveCategories(CategoryRepository.defaultCategories),
    ]);

    username.value = UserProfileModel.defaultUsername;
    usernameController.text = username.value;
    avatarPath.value = '';
    dailyGoal.value = AppSettingsModel.defaultDailyGoal;
    dailyGoalController.text = dailyGoal.value.toString();
    notificationsEnabled.value = false;
    defaultReminderTime.value = AppSettingsModel.defaultReminderTimeValue;
    selectedThemeMode.value = ThemeMode.system;
    Get.changeThemeMode(ThemeMode.system);
    _syncMainNavState();
    await _refreshTaskDataControllers();

    Get.offAllNamed(AppRoutes.onboarding);
    _showSnack('Tasky reset', 'Local data was cleared safely.');
  }

  void updateUsernameDraft(String value) {
    username.value = _safeUsername(value);
  }

  String get initials {
    final trimmed = username.value.trim();
    if (trimmed.isEmpty) {
      return 'TH';
    }
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    if (parts.isEmpty) {
      return 'TH';
    }
    final partsList = parts.toList();
    if (partsList.length == 1) {
      return partsList.first.characters.first.toUpperCase();
    }
    return '${partsList.first.characters.first}${partsList.last.characters.first}'
        .toUpperCase();
  }

  bool get hasAvatarImage => avatarPath.value.trim().isNotEmpty;

  Future<void> _refreshTaskDataControllers() async {
    if (Get.isRegistered<TasksController>()) {
      await Get.find<TasksController>().refreshTasks();
    }
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshHomeData();
    }
    if (Get.isRegistered<PlannerController>()) {
      await Get.find<PlannerController>().refreshPlannerData();
    }
    if (Get.isRegistered<InsightsController>()) {
      await Get.find<InsightsController>().refreshInsights();
    }
  }

  Future<void> _refreshHome() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshHomeData();
    }
  }

  Future<void> _scheduleEligibleTaskReminders() async {
    final tasks = _taskRepository.getTasks();
    for (final task in tasks) {
      await _notificationService.syncTaskReminder(
        task,
        notificationsEnabled: true,
      );
    }
  }

  void _syncMainNavState() {
    if (!Get.isRegistered<MainNavController>()) {
      return;
    }
    final mainNavController = Get.find<MainNavController>();
    mainNavController.username.value = username.value;
    mainNavController.dailyGoal.value = dailyGoal.value;
  }

  String _safeUsername(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? UserProfileModel.defaultUsername : trimmed;
  }

  void _showSnack(String title, String message) {
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

  NotificationService get _notificationService =>
      Get.find<NotificationService>();

  @override
  void onClose() {
    usernameController.dispose();
    dailyGoalController.dispose();
    super.onClose();
  }
}
