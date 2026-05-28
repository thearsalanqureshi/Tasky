import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/tasky_mock_data.dart';
import '../../data/models/category_model.dart';
import '../../data/models/task_model.dart';
import '../main_nav/main_nav_controller.dart';

class HomeController extends GetxController {
  List<TaskModel> get tasks => TaskyMockData.tasks;

  List<CategoryModel> get categories => TaskyMockData.categories;

  String get username {
    if (Get.isRegistered<MainNavController>()) {
      return Get.find<MainNavController>().username.value;
    }
    return TaskyMockData.usernameFallback;
  }

  int get completedCount => tasks.where((task) => task.isCompleted).length;

  int get totalCount => tasks.length;

  double get progressRatio => totalCount == 0 ? 0 : completedCount / totalCount;

  List<TaskModel> get todayFocus {
    return tasks
        .where((task) => TaskyMockData.isToday(task) && !task.isCompleted)
        .take(3)
        .toList();
  }

  List<TaskModel> get upcomingDeadlines {
    final now = DateTime.now();
    final upcoming = tasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate != null && dueDate.isAfter(now) && !task.isCompleted;
    }).toList()..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return upcoming.take(3).toList();
  }

  List<TaskModel> get recentWins {
    final completed = tasks.where((task) => task.isCompleted).toList()
      ..sort((a, b) {
        final aDate = a.completedAt ?? a.createdAt;
        final bDate = b.completedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
    return completed.take(3).toList();
  }

  void openSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  void openAddTask() {
    Get.toNamed(AppRoutes.addEditTask);
  }

  void openPlanner() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(2);
    }
  }

  void openTask(TaskModel task) {
    Get.toNamed(AppRoutes.taskDetail, arguments: task);
  }
}
