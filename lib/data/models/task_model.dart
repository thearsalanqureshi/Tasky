import 'subtask_model.dart';

class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    DateTime? updatedAt,
    this.description,
    this.categoryId,
    String priority = defaultPriority,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks = const [],
    this.reminderAt,
    this.estimatedMinutes,
    String? energyLevel,
  }) : priority = safePriority(priority),
       updatedAt = updatedAt ?? createdAt,
       energyLevel = safeEnergyLevel(energyLevel);

  static const String defaultPriority = 'Medium';
  static const String defaultEnergyLevel = 'Medium';
  static const int defaultEstimatedMinutes = 30;

  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final String priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<SubtaskModel> subtasks;
  final DateTime? reminderAt;
  final int? estimatedMinutes;
  final String energyLevel;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<SubtaskModel>? subtasks,
    DateTime? reminderAt,
    int? estimatedMinutes,
    String? energyLevel,
    bool clearDescription = false,
    bool clearCategoryId = false,
    bool clearDueDate = false,
    bool clearCompletedAt = false,
    bool clearReminderAt = false,
    bool clearEstimatedMinutes = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      reminderAt: clearReminderAt ? null : reminderAt ?? this.reminderAt,
      estimatedMinutes: clearEstimatedMinutes
          ? null
          : safeEstimatedMinutes(estimatedMinutes ?? this.estimatedMinutes),
      energyLevel: energyLevel ?? this.energyLevel,
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
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'reminderAt': reminderAt?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'energyLevel': energyLevel,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final createdAt = _dateFromJson(json['createdAt']) ?? DateTime.now();
    return TaskModel(
      id: _safeString(json['id'], fallback: _fallbackId()),
      title: _safeString(json['title'], fallback: 'Untitled Task'),
      description: _safeOptionalString(json['description']),
      categoryId: _safeOptionalString(json['categoryId']),
      priority: safePriority(json['priority']),
      dueDate: _dateFromJson(json['dueDate']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _dateFromJson(json['updatedAt']) ?? createdAt,
      completedAt: _dateFromJson(json['completedAt']),
      subtasks: _subtasksFromJson(json['subtasks']),
      reminderAt:
          _dateFromJson(json['reminderAt']) ??
          _dateFromJson(json['reminderTime']),
      estimatedMinutes: safeEstimatedMinutes(json['estimatedMinutes']),
      energyLevel: safeEnergyLevel(json['energyLevel']),
    );
  }

  static String safePriority(Object? value) {
    final normalized = value is String ? value.trim().toLowerCase() : '';
    return switch (normalized) {
      'low' => 'Low',
      'high' => 'High',
      _ => defaultPriority,
    };
  }

  static String safeEnergyLevel(Object? value) {
    final normalized = value is String ? value.trim().toLowerCase() : '';
    return switch (normalized) {
      'low' => 'Low',
      'high' => 'High',
      _ => defaultEnergyLevel,
    };
  }

  static int? safeEstimatedMinutes(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String && value.trim().isEmpty) {
      return null;
    }
    final parsed = value is int ? value : int.tryParse(value.toString());
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed.clamp(1, 1440).toInt();
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static List<SubtaskModel> _subtasksFromJson(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map((item) => SubtaskModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static String _safeString(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static String? _safeOptionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static String _fallbackId() {
    return 'task-${DateTime.now().microsecondsSinceEpoch}';
  }
}
