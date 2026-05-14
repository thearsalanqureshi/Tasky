import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/category_model.dart';
import '../../data/models/planner_day_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/planner_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/notification_service.dart';
import '../main_nav/main_nav_controller.dart';
import '../tasks/tasks_controller.dart';

class PlannerController extends GetxController {
  PlannerController(
    this._taskRepository,
    this._plannerRepository,
    this._categoryRepository,
  );

  final TaskRepository _taskRepository;
  final PlannerRepository _plannerRepository;
  final CategoryRepository _categoryRepository;

  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxList<TaskModel> todayCandidateTasks = <TaskModel>[].obs;
  final RxList<TaskModel> selectedTopTasks = <TaskModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rx<PlannerDayModel> todayPlanner = PlannerDayModel.empty(
    DateTime.now(),
  ).obs;
  final RxBool isLoading = false.obs;
  final RxString reflectionText = ''.obs;
  final RxnString errorMessage = RxnString();
  final TextEditingController reflectionController = TextEditingController();

  Worker? _tabWorker;

  @override
  void onInit() {
    super.onInit();
    loadPlannerData();
    if (Get.isRegistered<MainNavController>()) {
      _tabWorker = ever<int>(Get.find<MainNavController>().currentIndex, (
        index,
      ) {
        if (index == 2) {
          refreshPlannerData();
        }
      });
    }
  }

  Future<void> loadPlannerData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      categories.assignAll(_categoryRepository.getCategories());
      allTasks.assignAll(_sortPlannerCandidates(_taskRepository.getTasks()));
      todayPlanner.value = _plannerRepository.getTodayPlanner();
      reflectionText.value = todayPlanner.value.reflectionText;
      if (reflectionController.text != reflectionText.value) {
        reflectionController.text = reflectionText.value;
      }
      await _rebuildPlannerLists(persistMissingIds: true);
    } catch (_) {
      errorMessage.value = 'Could not load your planner.';
      allTasks.clear();
      todayCandidateTasks.clear();
      selectedTopTasks.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPlannerData() => loadPlannerData();

  Future<void> toggleTopTaskSelection(TaskModel task) async {
    final selectedIds = todayPlanner.value.selectedTaskIds.toList();
    if (selectedIds.contains(task.id)) {
      await removeTopTask(task.id);
      return;
    }
    if (selectedIds.length >= 3) {
      Get.snackbar(
        'Top 3 only',
        'Choose your most important tasks for today.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryYellow,
        colorText: AppColors.blackStroke,
        margin: const EdgeInsets.all(AppSizes.lg),
        borderColor: AppColors.blackStroke,
        borderWidth: 3,
      );
      return;
    }
    selectedIds.add(task.id);
    await _savePlanner(
      todayPlanner.value.copyWith(
        selectedTaskIds: selectedIds,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeTopTask(String taskId) async {
    final selectedIds = todayPlanner.value.selectedTaskIds
        .where((id) => id != taskId)
        .toList();
    await _savePlanner(
      todayPlanner.value.copyWith(
        selectedTaskIds: selectedIds,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateTaskEstimatedMinutes(String taskId, int? minutes) async {
    if (minutes != null && minutes < 0) {
      _showSnack('Invalid estimate', 'Estimated minutes cannot be negative.');
      return;
    }
    final task = taskById(taskId);
    if (task == null) {
      return;
    }
    final safeMinutes = minutes == null
        ? null
        : TaskModel.safeEstimatedMinutes(minutes);
    final saved = await _taskRepository.updateTask(
      task.copyWith(
        estimatedMinutes: safeMinutes,
        clearEstimatedMinutes: safeMinutes == null,
        updatedAt: DateTime.now(),
      ),
    );
    if (!saved) {
      _showSnack('Could not update estimate', 'Please try again.');
      return;
    }
    await _afterTaskMutation();
  }

  Future<void> updateTaskEnergyLevel(String taskId, String? energyLevel) async {
    final task = taskById(taskId);
    if (task == null) {
      return;
    }
    final saved = await _taskRepository.updateTask(
      task.copyWith(
        energyLevel: TaskModel.safeEnergyLevel(energyLevel),
        updatedAt: DateTime.now(),
      ),
    );
    if (!saved) {
      _showSnack('Could not update energy', 'Please try again.');
      return;
    }
    await _afterTaskMutation();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = taskById(taskId);
    if (task == null) {
      return;
    }
    final now = DateTime.now();
    final completed = !task.isCompleted;
    final saved = await _taskRepository.updateTask(
      task.copyWith(
        isCompleted: completed,
        completedAt: completed ? now : null,
        clearCompletedAt: !completed,
        updatedAt: now,
      ),
    );
    if (!saved) {
      _showSnack('Could not update task', 'Please try again.');
      return;
    }
    await _notificationService.syncTaskReminder(
      task.copyWith(
        isCompleted: completed,
        completedAt: completed ? now : null,
        clearCompletedAt: !completed,
        updatedAt: now,
      ),
      notificationsEnabled: _notificationsEnabled,
    );
    await _afterTaskMutation();
  }

  Future<void> saveReflection(String text) async {
    final trimmedText = text.trim();
    reflectionText.value = trimmedText;
    await _savePlanner(
      todayPlanner.value.copyWith(
        reflectionText: trimmedText,
        updatedAt: DateTime.now(),
      ),
      rebuildTasks: false,
    );
  }

  Future<void> clearTodayPlanner() async {
    reflectionController.clear();
    reflectionText.value = '';
    await _savePlanner(
      todayPlanner.value.copyWith(
        selectedTaskIds: const [],
        reflectionText: '',
        updatedAt: DateTime.now(),
      ),
    );
  }

  List<TaskModel> candidateTasksForQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return todayCandidateTasks;
    }
    return todayCandidateTasks.where((task) {
      final categoryName = categoryById(task.categoryId).name.toLowerCase();
      return task.title.toLowerCase().contains(normalizedQuery) ||
          (task.description ?? '').toLowerCase().contains(normalizedQuery) ||
          categoryName.contains(normalizedQuery);
    }).toList();
  }

  Future<void> openTask(TaskModel task) async {
    await Get.toNamed(AppRoutes.taskDetail, arguments: {'taskId': task.id});
    await refreshPlannerData();
  }

  Future<void> openAddTask() async {
    await Get.toNamed(AppRoutes.addEditTask, arguments: {'source': 'planner'});
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(2);
    }
    await refreshPlannerData();
  }

  TaskModel? taskById(String taskId) {
    for (final task in allTasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
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

  int get plannedTasksDone =>
      selectedTopTasks.where((task) => task.isCompleted).length;

  int get plannedTasksTotal => selectedTopTasks.length;

  double get plannerProgress {
    if (plannedTasksTotal == 0) {
      return 0;
    }
    return (plannedTasksDone / plannedTasksTotal).clamp(0, 1).toDouble();
  }

  int get plannerProgressPercent => (plannerProgress * 100).round();

  int get selectedEstimatedMinutes {
    return selectedTopTasks.fold(
      0,
      (total, task) => total + (task.estimatedMinutes ?? 0),
    );
  }

  bool isSelected(String taskId) {
    return todayPlanner.value.selectedTaskIds.contains(taskId);
  }

  bool isDueToday(TaskModel task) {
    return _isSameDay(task.dueDate, DateTime.now());
  }

  bool isOverdue(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return _startOfDay(dueDate).isBefore(_startOfDay(DateTime.now()));
  }

  bool isUpcoming(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return _startOfDay(dueDate).isAfter(_startOfDay(DateTime.now()));
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _savePlanner(
    PlannerDayModel plannerDay, {
    bool rebuildTasks = true,
  }) async {
    final saved = await _plannerRepository.saveTodayPlanner(plannerDay);
    if (!saved) {
      _showSnack('Could not save planner', 'Please try again.');
      return;
    }
    todayPlanner.value = _plannerRepository.getTodayPlanner();
    reflectionText.value = todayPlanner.value.reflectionText;
    if (rebuildTasks) {
      await _rebuildPlannerLists(persistMissingIds: false);
    }
  }

  Future<void> _afterTaskMutation() async {
    await refreshPlannerData();
    if (Get.isRegistered<TasksController>()) {
      await Get.find<TasksController>().refreshTasks();
    }
  }

  Future<void> _rebuildPlannerLists({required bool persistMissingIds}) async {
    todayCandidateTasks.assignAll(_sortPlannerCandidates(allTasks));

    final tasksById = {for (final task in allTasks) task.id: task};
    final validSelectedIds = todayPlanner.value.selectedTaskIds
        .where(tasksById.containsKey)
        .toList();
    selectedTopTasks.assignAll(
      validSelectedIds.map((taskId) => tasksById[taskId]!).toList(),
    );

    if (persistMissingIds &&
        validSelectedIds.length != todayPlanner.value.selectedTaskIds.length) {
      await _savePlanner(
        todayPlanner.value.copyWith(
          selectedTaskIds: validSelectedIds,
          updatedAt: DateTime.now(),
        ),
        rebuildTasks: false,
      );
    }
  }

  List<TaskModel> _sortPlannerCandidates(Iterable<TaskModel> tasks) {
    return tasks.toList()..sort(_plannerSort);
  }

  int _plannerSort(TaskModel a, TaskModel b) {
    final rankCompare = _plannerRank(a).compareTo(_plannerRank(b));
    if (rankCompare != 0) {
      return rankCompare;
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

  int _plannerRank(TaskModel task) {
    if (task.isCompleted) {
      return 6;
    }
    if (isOverdue(task)) {
      return 0;
    }
    if (isDueToday(task) && task.priority == 'High') {
      return 1;
    }
    if (isDueToday(task) && task.priority == 'Medium') {
      return 2;
    }
    if (isDueToday(task)) {
      return 3;
    }
    if (isUpcoming(task)) {
      return 4;
    }
    return 5;
  }

  int _priorityRank(TaskModel task) {
    return switch (task.priority.toLowerCase()) {
      'high' => 0,
      'medium' => 1,
      _ => 2,
    };
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

  @override
  void onClose() {
    _tabWorker?.dispose();
    reflectionController.dispose();
    super.onClose();
  }

  NotificationService get _notificationService =>
      Get.find<NotificationService>();

  SettingsRepository get _settingsRepository => Get.find<SettingsRepository>();

  bool get _notificationsEnabled =>
      _settingsRepository.getNotificationsEnabled();
}
