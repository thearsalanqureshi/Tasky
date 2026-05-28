import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/tasky_mock_data.dart';
import '../../data/models/task_model.dart';

class TasksController extends GetxController {
  static const filters = ['All', 'Today', 'Upcoming', 'Overdue', 'Completed'];

  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<String, bool> completionOverrides = <String, bool>{}.obs;

  List<TaskModel> get allTasks => TaskyMockData.tasks;

  List<TaskModel> get filteredTasks {
    final query = searchQuery.value.trim().toLowerCase();
    return allTasks.where((task) {
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          (task.description ?? '').toLowerCase().contains(query) ||
          TaskyMockData.categoryById(
            task.categoryId,
          ).name.toLowerCase().contains(query);
      if (!matchesQuery) {
        return false;
      }

      switch (selectedFilter.value) {
        case 'Today':
          return TaskyMockData.isToday(task);
        case 'Upcoming':
          final dueDate = task.dueDate;
          return dueDate != null &&
              dueDate.isAfter(DateTime.now()) &&
              !isCompleted(task);
        case 'Overdue':
          return isOverdue(task);
        case 'Completed':
          return isCompleted(task);
        default:
          return true;
      }
    }).toList();
  }

  bool isCompleted(TaskModel task) {
    return completionOverrides[task.id] ?? task.isCompleted;
  }

  bool isOverdue(TaskModel task) {
    final dueDate = task.dueDate;
    return dueDate != null &&
        dueDate.isBefore(DateTime.now()) &&
        !isCompleted(task);
  }

  TaskModel effectiveTask(TaskModel task) {
    return task.copyWith(isCompleted: isCompleted(task));
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleCompleted(TaskModel task) {
    completionOverrides[task.id] = !isCompleted(task);
  }

  void openAddTask() {
    Get.toNamed(AppRoutes.addEditTask);
  }

  void openEditTask(TaskModel task) {
    Get.toNamed(
      AppRoutes.addEditTask,
      arguments: {'task': effectiveTask(task), 'mode': 'edit'},
    );
  }

  void openTask(TaskModel task) {
    Get.toNamed(AppRoutes.taskDetail, arguments: effectiveTask(task));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
