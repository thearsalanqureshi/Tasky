import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/category_model.dart';
import '../../data/models/subtask_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/notification_service.dart';

enum TaskFilter {
  all('All'),
  today('Today'),
  upcoming('Upcoming'),
  overdue('Overdue'),
  completed('Completed');

  const TaskFilter(this.label);

  final String label;
}

class TasksController extends GetxController {
  TasksController(this._taskRepository, this._categoryRepository);

  static const filters = TaskFilter.values;

  final TaskRepository _taskRepository;
  final CategoryRepository _categoryRepository;

  final TextEditingController searchController = TextEditingController();
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<TaskFilter> selectedFilter = TaskFilter.all.obs;
  final RxnString selectedCategoryId = RxnString();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      categories.assignAll(_categoryRepository.getCategories());
      tasks.assignAll(_sortTasks(_taskRepository.getTasks()));
    } catch (_) {
      errorMessage.value = 'Could not load saved tasks.';
      tasks.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTasks() => loadTasks();

  Future<bool> addTask(TaskModel task) async {
    final safeTask = task.copyWith(updatedAt: DateTime.now());
    final saved = await _taskRepository.addTask(safeTask);
    await refreshTasks();
    return saved;
  }

  Future<bool> updateTask(TaskModel task) async {
    final saved = await _taskRepository.updateTask(
      task.copyWith(updatedAt: DateTime.now()),
    );
    await refreshTasks();
    return saved;
  }

  Future<bool> deleteTask(String taskId) async {
    final saved = await _taskRepository.deleteTask(taskId);
    if (saved) {
      await _notificationService.cancelTaskReminder(taskId);
    }
    await refreshTasks();
    return saved;
  }

  Future<bool> clearCompletedTasks() async {
    final completedTaskIds = _taskRepository
        .getTasks()
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();
    final saved = await _taskRepository.clearCompletedTasks();
    if (saved) {
      for (final taskId in completedTaskIds) {
        await _notificationService.cancelTaskReminder(taskId);
      }
    }
    await refreshTasks();
    return saved;
  }

  Future<bool> toggleTaskCompletion(String taskId) async {
    final task = taskById(taskId);
    if (task == null) {
      return false;
    }
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
      return false;
    }
    await _notificationService.syncTaskReminder(
      updatedTask,
      notificationsEnabled: _notificationsEnabled,
    );
    await refreshTasks();
    return true;
  }

  Future<bool> toggleSubtaskCompletion(String taskId, String subtaskId) async {
    final task = taskById(taskId);
    if (task == null) {
      return false;
    }
    final updatedSubtasks = task.subtasks.map((subtask) {
      if (subtask.id != subtaskId) {
        return subtask;
      }
      return subtask.copyWith(isCompleted: !subtask.isCompleted);
    }).toList();
    return updateTask(
      task.copyWith(subtasks: updatedSubtasks, updatedAt: DateTime.now()),
    );
  }

  TaskModel? taskById(String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  TaskModel? taskFromArgument(
    Object? argument, {
    bool allowUnsavedTask = false,
  }) {
    if (argument is TaskModel) {
      return taskById(argument.id) ?? (allowUnsavedTask ? argument : null);
    }
    if (argument is String) {
      return taskById(argument);
    }
    if (argument is Map) {
      final id = argument['taskId'];
      if (id is String) {
        return taskById(id);
      }
      final task = argument['task'];
      if (task is TaskModel) {
        return taskById(task.id) ?? (allowUnsavedTask ? task : null);
      }
    }
    return null;
  }

  List<TaskModel> get filteredTasks {
    final query = searchQuery.value.trim().toLowerCase();
    final filtered = tasks.where((task) {
      final categoryName = categoryById(task.categoryId).name.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          (task.description ?? '').toLowerCase().contains(query) ||
          categoryName.contains(query);
      if (!matchesQuery) {
        return false;
      }
      final categoryId = selectedCategoryId.value;
      if (categoryId != null && task.categoryId != categoryId) {
        return false;
      }

      return switch (selectedFilter.value) {
        TaskFilter.today => isToday(task),
        TaskFilter.upcoming => isUpcoming(task),
        TaskFilter.overdue => isOverdue(task),
        TaskFilter.completed => task.isCompleted,
        TaskFilter.all => true,
      };
    }).toList();
    return _sortTasks(filtered);
  }

  bool get hasAnyTasks => tasks.isNotEmpty;

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setFilter(TaskFilter filter) {
    selectedFilter.value = filter;
  }

  void setCategoryFilter(String? categoryId) {
    selectedCategoryId.value = categoryId?.trim().isEmpty ?? true
        ? null
        : categoryId!.trim();
  }

  void clearCategoryFilter() {
    selectedCategoryId.value = null;
  }

  void openAddTask() {
    Get.toNamed(AppRoutes.addEditTask);
  }

  void openEditTask(TaskModel task) {
    Get.toNamed(
      AppRoutes.addEditTask,
      arguments: {'taskId': task.id, 'mode': 'edit'},
    );
  }

  void openTask(TaskModel task) {
    Get.toNamed(AppRoutes.taskDetail, arguments: {'taskId': task.id});
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

  bool isToday(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null) {
      return false;
    }
    final today = _startOfDay(DateTime.now());
    return _startOfDay(dueDate) == today;
  }

  bool isUpcoming(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return _startOfDay(dueDate).isAfter(_startOfDay(DateTime.now()));
  }

  bool isOverdue(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return _startOfDay(dueDate).isBefore(_startOfDay(DateTime.now()));
  }

  List<SubtaskModel> sanitizeSubtasks(List<SubtaskModel> subtasks) {
    final seenIds = <String>{};
    return subtasks.where((subtask) {
      final hasTitle = subtask.title.trim().isNotEmpty;
      final isUnique = seenIds.add(subtask.id);
      return hasTitle && isUnique;
    }).toList();
  }

  List<TaskModel> _sortTasks(Iterable<TaskModel> unsortedTasks) {
    final sortedTasks = unsortedTasks.toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }

        final aDueRank = _dueRank(a);
        final bDueRank = _dueRank(b);
        if (aDueRank != bDueRank) {
          return aDueRank.compareTo(bDueRank);
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
      });
    return sortedTasks;
  }

  int _dueRank(TaskModel task) {
    if (task.isCompleted) {
      return 3;
    }
    if (isOverdue(task)) {
      return 0;
    }
    if (isToday(task)) {
      return 1;
    }
    return 2;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  NotificationService get _notificationService =>
      Get.find<NotificationService>();

  SettingsRepository get _settingsRepository => Get.find<SettingsRepository>();

  bool get _notificationsEnabled =>
      _settingsRepository.getNotificationsEnabled();
}
