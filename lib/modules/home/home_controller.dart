import 'dart:math' as math;

import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/notification_service.dart';
import '../main_nav/main_nav_controller.dart';
import '../tasks/tasks_controller.dart';

class HomeController extends GetxController {
  HomeController(
    this._taskRepository,
    this._profileRepository,
    this._categoryRepository,
  );

  static const usernameFallback = 'Task Hero';

  final TaskRepository _taskRepository;
  final ProfileRepository _profileRepository;
  final CategoryRepository _categoryRepository;

  final RxString username = usernameFallback.obs;
  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  Worker? _usernameWorker;
  Worker? _tabWorker;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
    if (Get.isRegistered<MainNavController>()) {
      final mainNavController = Get.find<MainNavController>();
      _usernameWorker = ever<String>(
        mainNavController.username,
        (value) => username.value = _safeUsername(value),
      );
      _tabWorker = ever<int>(mainNavController.currentIndex, (index) {
        if (index == 0) {
          refreshHomeData();
        }
      });
    }
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      loadUsername();
      loadCategories();
      loadTasks();
    } catch (_) {
      errorMessage.value = 'Could not load your home dashboard.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHomeData() => loadHomeData();

  void loadUsername() {
    username.value = _safeUsername(_profileRepository.getUsername());
  }

  void loadTasks() {
    allTasks.assignAll(_sortByCreated(_taskRepository.getTasks()));
  }

  void loadCategories() {
    categories.assignAll(_categoryRepository.getCategories());
  }

  int get totalTodayTasks => todayDashboardTasks.length;

  int get completedTodayTasks => todayDashboardTasks
      .where((task) => task.isCompleted && isSameDay(task.completedAt, today))
      .length;

  int get pendingTodayTasks =>
      math.max(0, totalTodayTasks - completedTodayTasks);

  double get todayProgressPercent {
    if (totalTodayTasks == 0) {
      return 0;
    }
    return (completedTodayTasks / totalTodayTasks).clamp(0, 1).toDouble();
  }

  int get todayProgressDisplay => (todayProgressPercent * 100).round();

  int get overdueTasksCount => allTasks.where(isOverdue).length;

  String get progressMessage {
    final progress = todayProgressPercent;
    if (progress <= 0) {
      return 'Start with one bold move.';
    }
    if (progress < 0.5) {
      return 'Keep punching through.';
    }
    if (progress < 1) {
      return "You're gaining momentum.";
    }
    return 'You crushed today.';
  }

  List<TaskModel> get todayDashboardTasks {
    final taskById = <String, TaskModel>{};
    for (final task in allTasks) {
      if (isDueToday(task) ||
          isOverdue(task) ||
          (task.isCompleted && isSameDay(task.completedAt, today))) {
        taskById[task.id] = task;
      }
    }
    return taskById.values.toList()..sort(_homeSort);
  }

  List<TaskModel> get todayFocusTasks {
    final focusTasks =
        allTasks
            .where(
              (task) =>
                  !task.isCompleted && (isOverdue(task) || isDueToday(task)),
            )
            .toList()
          ..sort(_focusSort);
    return focusTasks.take(3).toList();
  }

  List<TaskModel> get upcomingDeadlineTasks {
    final upcomingTasks = allTasks.where(isUpcoming).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return upcomingTasks.take(5).toList();
  }

  List<TaskModel> get recentCompletedTasks {
    final completedTasks =
        allTasks
            .where((task) => task.isCompleted && task.completedAt != null)
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return completedTasks.take(5).toList();
  }

  CategoryModel categoryById(String? id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => const CategoryModel(
        id: 'general',
        name: 'General',
        colorHex: '#FFFFFF',
      ),
    );
  }

  int incompleteCountForCategory(String categoryId) {
    return allTasks
        .where((task) => !task.isCompleted && task.categoryId == categoryId)
        .length;
  }

  bool isDueToday(TaskModel task) {
    return isSameDay(task.dueDate, today);
  }

  bool isOverdue(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return startOfDay(dueDate).isBefore(startOfDay(today));
  }

  bool isUpcoming(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return startOfDay(dueDate).isAfter(startOfDay(today));
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get today => DateTime.now();

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final now = DateTime.now();
    final completed = !task.isCompleted;
    final updatedTask = task.copyWith(
      isCompleted: completed,
      completedAt: completed ? now : null,
      clearCompletedAt: !completed,
      updatedAt: now,
    );
    final saved = await _taskRepository.updateTask(updatedTask);
    if (!saved) {
      Get.snackbar('Could not update task', 'Please try again.');
      return;
    }
    await _notificationService.syncTaskReminder(
      updatedTask,
      notificationsEnabled: _notificationsEnabled,
    );
    await refreshHomeData();
    await _refreshTasksController();
  }

  Future<void> openSettings() async {
    await Get.toNamed(AppRoutes.settings);
    await refreshHomeData();
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().username.value = username.value;
    }
  }

  Future<void> openAddTask() async {
    await Get.toNamed(AppRoutes.addEditTask, arguments: {'source': 'home'});
    await refreshHomeData();
  }

  void openPlanner() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(2);
    }
  }

  Future<void> openTask(TaskModel task) async {
    await Get.toNamed(AppRoutes.taskDetail, arguments: {'taskId': task.id});
    await refreshHomeData();
  }

  Future<void> openCategory(CategoryModel category) async {
    if (Get.isRegistered<TasksController>()) {
      final tasksController = Get.find<TasksController>();
      tasksController.setCategoryFilter(category.id);
      await tasksController.refreshTasks();
    }
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(1);
    }
  }

  Future<void> _refreshTasksController() async {
    if (Get.isRegistered<TasksController>()) {
      await Get.find<TasksController>().refreshTasks();
    }
  }

  String _safeUsername(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? usernameFallback : trimmed;
  }

  List<TaskModel> _sortByCreated(Iterable<TaskModel> tasks) {
    return tasks.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int _homeSort(TaskModel a, TaskModel b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }
    return _focusSort(a, b);
  }

  int _focusSort(TaskModel a, TaskModel b) {
    final aOverdue = isOverdue(a);
    final bOverdue = isOverdue(b);
    if (aOverdue != bOverdue) {
      return aOverdue ? -1 : 1;
    }

    final priorityCompare = _priorityRank(a).compareTo(_priorityRank(b));
    if (priorityCompare != 0) {
      return priorityCompare;
    }

    final aDueDate = a.dueDate;
    final bDueDate = b.dueDate;
    if (aDueDate != null && bDueDate != null) {
      return aDueDate.compareTo(bDueDate);
    }
    if (aDueDate != null) {
      return -1;
    }
    if (bDueDate != null) {
      return 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  int _priorityRank(TaskModel task) {
    return switch (task.priority.toLowerCase()) {
      'high' => 0,
      'medium' => 1,
      _ => 2,
    };
  }

  @override
  void onClose() {
    _usernameWorker?.dispose();
    _tabWorker?.dispose();
    super.onClose();
  }

  NotificationService get _notificationService =>
      Get.find<NotificationService>();

  SettingsRepository get _settingsRepository => Get.find<SettingsRepository>();

  bool get _notificationsEnabled =>
      _settingsRepository.getNotificationsEnabled();
}
