class PlannerDayModel {
  PlannerDayModel({
    required this.dateKey,
    required this.createdAt,
    DateTime? updatedAt,
    List<String> selectedTaskIds = const [],
    this.reflectionText = '',
  }) : selectedTaskIds = _safeTaskIds(selectedTaskIds),
       updatedAt = updatedAt ?? createdAt;

  final String dateKey;
  final List<String> selectedTaskIds;
  final String reflectionText;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PlannerDayModel.empty(DateTime date) {
    final now = DateTime.now();
    return PlannerDayModel(
      dateKey: dateKeyFor(date),
      createdAt: now,
      updatedAt: now,
    );
  }

  PlannerDayModel copyWith({
    String? dateKey,
    List<String>? selectedTaskIds,
    String? reflectionText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlannerDayModel(
      dateKey: dateKey ?? this.dateKey,
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      reflectionText: reflectionText ?? this.reflectionText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'selectedTaskIds': selectedTaskIds,
      'reflectionText': reflectionText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PlannerDayModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final createdAt = _dateFromJson(json['createdAt']) ?? now;
    return PlannerDayModel(
      dateKey: _safeDateKey(json['dateKey']),
      selectedTaskIds: _idsFromJson(json['selectedTaskIds']),
      reflectionText: _safeString(json['reflectionText']),
      createdAt: createdAt,
      updatedAt: _dateFromJson(json['updatedAt']) ?? createdAt,
    );
  }

  static String dateKeyFor(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static List<String> _idsFromJson(Object? value) {
    if (value is! List) {
      return const [];
    }
    return _safeTaskIds(value.whereType<String>());
  }

  static List<String> _safeTaskIds(Iterable<String> value) {
    final seenIds = <String>{};
    final taskIds = <String>[];
    for (final id in value) {
      final trimmed = id.trim();
      if (trimmed.isEmpty || !seenIds.add(trimmed)) {
        continue;
      }
      taskIds.add(trimmed);
      if (taskIds.length == 3) {
        break;
      }
    }
    return List.unmodifiable(taskIds);
  }

  static String _safeDateKey(Object? value) {
    if (value is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return value;
    }
    return dateKeyFor(DateTime.now());
  }

  static String _safeString(Object? value) {
    if (value is String) {
      return value.trim();
    }
    return '';
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
