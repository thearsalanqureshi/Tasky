import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/category_model.dart';
import '../../data/models/daily_insight_stat.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../main_nav/main_nav_controller.dart';

class InsightsController extends GetxController {
  InsightsController(this._taskRepository, this._categoryRepository);

  final TaskRepository _taskRepository;
  final CategoryRepository _categoryRepository;

  final RxBool isLoading = false.obs;
  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxInt completedToday = 0.obs;
  final RxInt completedThisWeek = 0.obs;
  final RxInt overdueCount = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt totalCompleted = 0.obs;
  final RxDouble completionRate = 0.0.obs;
  final RxString bestCategoryName = 'No category yet'.obs;
  final RxString productivityMessage =
      'Complete a few tasks and your stats will show up here.'.obs;
  final RxList<DailyInsightStat> weeklyStats = <DailyInsightStat>[].obs;
  final RxnString errorMessage = RxnString();

  Worker? _tabWorker;

  @override
  void onInit() {
    super.onInit();
    loadInsights();
    if (Get.isRegistered<MainNavController>()) {
      _tabWorker = ever<int>(Get.find<MainNavController>().currentIndex, (
        index,
      ) {
        if (index == 3) {
          refreshInsights();
        }
      });
    }
  }

  Future<void> loadInsights() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      allTasks.assignAll(_taskRepository.getTasks());
      categories.assignAll(_categoryRepository.getCategories());
      calculateCompletedToday();
      calculateWeeklyStats();
      calculateCurrentStreak();
      calculateOverdueCount();
      calculateBestCategory();
      calculateCompletionRate();
      buildProductivityMessage();
    } catch (_) {
      errorMessage.value = 'Could not load your insights.';
      allTasks.clear();
      weeklyStats.clear();
      completedToday.value = 0;
      completedThisWeek.value = 0;
      overdueCount.value = 0;
      currentStreak.value = 0;
      totalCompleted.value = 0;
      completionRate.value = 0;
      bestCategoryName.value = 'No category yet';
      productivityMessage.value =
          'Complete a few tasks and your stats will show up here.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshInsights() => loadInsights();

  void calculateCompletedToday() {
    completedToday.value = completedTasks
        .where((task) => isSameDay(task.completedAt, today))
        .length;
    totalCompleted.value = completedTasks.length;
  }

  void calculateWeeklyStats() {
    final stats = <DailyInsightStat>[];
    final formatter = DateFormat.E();
    for (var daysAgo = 6; daysAgo >= 0; daysAgo--) {
      final date = startOfDay(today.subtract(Duration(days: daysAgo)));
      final completedCount = completedTasks
          .where((task) => isSameDay(task.completedAt, date))
          .length;
      stats.add(
        DailyInsightStat(
          date: date,
          label: formatter.format(date),
          completedCount: completedCount,
        ),
      );
    }
    weeklyStats.assignAll(stats);
    completedThisWeek.value = stats.fold(
      0,
      (total, stat) => total + stat.completedCount,
    );
  }

  void calculateCurrentStreak() {
    final completedDays = completedTasks
        .where((task) => task.completedAt != null)
        .map((task) => startOfDay(task.completedAt!))
        .toSet();
    if (completedDays.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    var cursor = startOfDay(today);
    if (!completedDays.contains(cursor)) {
      final yesterday = cursor.subtract(const Duration(days: 1));
      if (!completedDays.contains(yesterday)) {
        currentStreak.value = 0;
        return;
      }
      cursor = yesterday;
    }

    var streak = 0;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    currentStreak.value = streak;
  }

  void calculateOverdueCount() {
    overdueCount.value = allTasks.where(isOverdue).length;
  }

  void calculateBestCategory() {
    final categoryCounts = <String, int>{};
    var generalCount = 0;
    for (final task in completedTasks) {
      final categoryId = task.categoryId;
      if (categoryId == null || categoryId.trim().isEmpty) {
        generalCount++;
      } else {
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      }
    }

    if (categoryCounts.isEmpty && generalCount == 0) {
      bestCategoryName.value = 'No category yet';
      return;
    }

    String bestName = generalCount > 0 ? 'General' : 'No category yet';
    var bestCount = generalCount;
    for (final entry in categoryCounts.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestName = categoryById(entry.key).name;
      }
    }
    bestCategoryName.value = bestName;
  }

  void calculateCompletionRate() {
    if (allTasks.isEmpty) {
      completionRate.value = 0;
      return;
    }
    completionRate.value = (totalCompleted.value / allTasks.length)
        .clamp(0, 1)
        .toDouble();
  }

  void buildProductivityMessage() {
    if (allTasks.isEmpty) {
      productivityMessage.value =
          'Add your first task and start building momentum.';
      return;
    }
    if (completedToday.value == 0) {
      productivityMessage.value = 'Start with one small win today.';
      return;
    }
    if (overdueCount.value > 0) {
      productivityMessage.value = 'Clear overdue tasks to reduce the chaos.';
      return;
    }
    if (currentStreak.value >= 3) {
      productivityMessage.value = 'Your streak is heating up.';
      return;
    }
    if (completionRate.value >= 0.8) {
      productivityMessage.value = "You're crushing your task game.";
      return;
    }
    if (completionRate.value < 0.5) {
      productivityMessage.value = "You're moving. Keep punching through.";
      return;
    }
    productivityMessage.value = 'Keep stacking small wins.';
  }

  List<TaskModel> get completedTasks =>
      allTasks.where((task) => task.isCompleted).toList();

  bool get hasTasks => allTasks.isNotEmpty;

  bool get hasCompletedTasks => completedTasks.isNotEmpty;

  bool get hasWeeklyCompletions =>
      weeklyStats.any((stat) => stat.completedCount > 0);

  int get completionRatePercent => (completionRate.value * 100).round();

  int get maxWeeklyCompleted {
    if (weeklyStats.isEmpty) {
      return 0;
    }
    return weeklyStats
        .map((stat) => stat.completedCount)
        .reduce((a, b) => a > b ? a : b);
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

  bool isOverdue(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null || task.isCompleted) {
      return false;
    }
    return startOfDay(dueDate).isBefore(startOfDay(today));
  }

  bool isSameDay(DateTime? date, DateTime target) {
    if (date == null) {
      return false;
    }
    return date.year == target.year &&
        date.month == target.month &&
        date.day == target.day;
  }

  DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get today => DateTime.now();

  @override
  void onClose() {
    _tabWorker?.dispose();
    super.onClose();
  }
}
