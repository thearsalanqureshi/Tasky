import 'subtask_model.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description,
    this.categoryId,
    this.priority = 'medium',
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks = const [],
    this.estimatedMinutes = 30,
    this.reminderTime,
  });

  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final String priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<SubtaskModel> subtasks;
  final int estimatedMinutes;
  final DateTime? reminderTime;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    List<SubtaskModel>? subtasks,
    int? estimatedMinutes,
    DateTime? reminderTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'estimatedMinutes': estimatedMinutes,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      dueDate: _dateFromJson(json['dueDate']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      completedAt: _dateFromJson(json['completedAt']),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SubtaskModel.fromJson)
          .toList(),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 30,
      reminderTime: _dateFromJson(json['reminderTime']),
    );
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
