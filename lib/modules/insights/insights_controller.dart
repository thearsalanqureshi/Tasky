import 'package:get/get.dart';

import '../../data/mock/tasky_mock_data.dart';
import '../../data/models/task_model.dart';

class InsightsController extends GetxController {
  List<TaskModel> get tasks => TaskyMockData.tasks;

  List<WeeklyStat> get weeklyStats => TaskyMockData.weeklyStats;

  int get completedToday {
    final now = DateTime.now();
    return tasks.where((task) {
      final completedAt = task.completedAt;
      return task.isCompleted &&
          completedAt != null &&
          completedAt.year == now.year &&
          completedAt.month == now.month &&
          completedAt.day == now.day;
    }).length;
  }

  int get overdueCount => tasks.where(TaskyMockData.isOverdue).length;

  int get currentStreak => 4;

  String get bestCategory {
    final counts = <String, int>{};
    for (final task in tasks.where((task) => task.isCompleted)) {
      final category = TaskyMockData.categoryById(task.categoryId);
      counts[category.name] = (counts[category.name] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return 'Study';
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  int get weeklyCompleted {
    return weeklyStats.fold(0, (total, stat) => total + stat.completed);
  }

  int get weeklyTotal {
    return weeklyStats.fold(0, (total, stat) => total + stat.total);
  }
}
