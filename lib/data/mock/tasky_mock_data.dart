import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

class TaskyMockData {
  const TaskyMockData._();

  static const String usernameFallback = 'Task Hero';

  static List<CategoryModel> get categories => const [
    CategoryModel(id: 'study', name: 'Study', colorHex: '#FFD84D'),
    CategoryModel(id: 'personal', name: 'Personal', colorHex: '#F47BD5'),
    CategoryModel(id: 'work', name: 'Work', colorHex: '#A7D8FF'),
    CategoryModel(id: 'health', name: 'Health', colorHex: '#8CF28A'),
    CategoryModel(id: 'project', name: 'Project', colorHex: '#FFFFFF'),
  ];

  static List<TaskModel> get tasks {
    final today = _today;
    return [
      TaskModel(
        id: 'task-1',
        title: 'Review calculus notes',
        description: 'Summarize derivatives and practice five examples.',
        categoryId: 'study',
        priority: 'High',
        dueDate: today.add(const Duration(hours: 10)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 1)),
        estimatedMinutes: 45,
        reminderAt: today.add(const Duration(hours: 9)),
        subtasks: const [
          SubtaskModel(
            id: 'sub-1',
            title: 'Read chapter recap',
            isCompleted: true,
          ),
          SubtaskModel(id: 'sub-2', title: 'Solve practice set'),
          SubtaskModel(id: 'sub-3', title: 'Mark confusing questions'),
        ],
      ),
      TaskModel(
        id: 'task-2',
        title: 'Submit history assignment',
        description: 'Final proofread and export the essay PDF.',
        categoryId: 'study',
        priority: 'High',
        dueDate: today.subtract(const Duration(hours: 3)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 3)),
        estimatedMinutes: 35,
      ),
      TaskModel(
        id: 'task-3',
        title: 'Plan app wireframes',
        description: 'Sketch the next two Tasky screens before coding.',
        categoryId: 'project',
        priority: 'Medium',
        dueDate: today.add(const Duration(days: 1, hours: 11)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 2)),
        estimatedMinutes: 60,
        subtasks: const [
          SubtaskModel(
            id: 'sub-4',
            title: 'Draft home layout',
            isCompleted: true,
          ),
          SubtaskModel(
            id: 'sub-5',
            title: 'Draft task detail layout',
            isCompleted: true,
          ),
          SubtaskModel(id: 'sub-6', title: 'Review empty states'),
        ],
      ),
      TaskModel(
        id: 'task-4',
        title: 'Morning stretch',
        description: 'Ten minutes of mobility before class.',
        categoryId: 'health',
        priority: 'Low',
        dueDate: today.add(const Duration(hours: 7)),
        isCompleted: true,
        createdAt: today.subtract(const Duration(days: 1)),
        completedAt: today.add(const Duration(hours: 7, minutes: 15)),
        estimatedMinutes: 10,
      ),
      TaskModel(
        id: 'task-5',
        title: 'Email project mentor',
        description: 'Send progress summary and blockers.',
        categoryId: 'work',
        priority: 'Medium',
        dueDate: today.add(const Duration(days: 2, hours: 13)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 2)),
        estimatedMinutes: 20,
      ),
      TaskModel(
        id: 'task-6',
        title: 'Clean study desk',
        description: 'Reset workspace for the week.',
        categoryId: 'personal',
        priority: 'Low',
        dueDate: today.subtract(const Duration(days: 1, hours: 2)),
        isCompleted: true,
        createdAt: today.subtract(const Duration(days: 2)),
        completedAt: today.subtract(const Duration(days: 1, hours: 1)),
        estimatedMinutes: 15,
      ),
      TaskModel(
        id: 'task-7',
        title: 'Read research paper',
        description: 'Highlight core ideas for the capstone proposal.',
        categoryId: 'project',
        priority: 'High',
        dueDate: today.add(const Duration(days: 3, hours: 15)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 1)),
        estimatedMinutes: 90,
      ),
      TaskModel(
        id: 'task-8',
        title: 'Buy lab notebook',
        description: 'Pick one up before Thursday lab.',
        categoryId: 'personal',
        priority: 'Medium',
        dueDate: today.add(const Duration(days: 4, hours: 12)),
        isCompleted: false,
        createdAt: today,
        estimatedMinutes: 25,
      ),
      TaskModel(
        id: 'task-9',
        title: 'Finish workout log',
        description: 'Record sets, reps, and how the session felt.',
        categoryId: 'health',
        priority: 'Low',
        dueDate: today,
        isCompleted: true,
        createdAt: today.subtract(const Duration(hours: 8)),
        completedAt: today.add(const Duration(hours: 1)),
        estimatedMinutes: 10,
      ),
      TaskModel(
        id: 'task-10',
        title: 'Prep presentation outline',
        description: 'Create a tight five-slide story for review.',
        categoryId: 'work',
        priority: 'High',
        dueDate: today.add(const Duration(days: 6, hours: 16)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 4)),
        estimatedMinutes: 50,
      ),
    ];
  }

  static List<WeeklyStat> get weeklyStats => const [
    WeeklyStat(day: 'Mon', completed: 4, total: 6),
    WeeklyStat(day: 'Tue', completed: 5, total: 7),
    WeeklyStat(day: 'Wed', completed: 3, total: 5),
    WeeklyStat(day: 'Thu', completed: 6, total: 8),
    WeeklyStat(day: 'Fri', completed: 5, total: 8),
    WeeklyStat(day: 'Sat', completed: 2, total: 4),
    WeeklyStat(day: 'Sun', completed: 4, total: 5),
  ];

  static CategoryModel categoryById(String? id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => categories.first,
    );
  }

  static Color categoryColor(String? id) {
    final hex = categoryById(id).colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.pink;
      case 'medium':
        return AppColors.primaryYellow;
      default:
        return AppColors.mintGreen;
    }
  }

  static TaskModel taskFromArguments(Object? arguments) {
    if (arguments is TaskModel) {
      return arguments;
    }
    if (arguments is Map && arguments['task'] is TaskModel) {
      return arguments['task'] as TaskModel;
    }
    return tasks.first;
  }

  static bool isToday(TaskModel task) {
    final dueDate = task.dueDate;
    if (dueDate == null) {
      return false;
    }
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  static bool isOverdue(TaskModel task) {
    final dueDate = task.dueDate;
    return dueDate != null &&
        dueDate.isBefore(DateTime.now()) &&
        !task.isCompleted;
  }

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 9);
  }
}

class WeeklyStat {
  const WeeklyStat({
    required this.day,
    required this.completed,
    required this.total,
  });

  final String day;
  final int completed;
  final int total;

  double get ratio => total == 0 ? 0 : completed / total;
}
