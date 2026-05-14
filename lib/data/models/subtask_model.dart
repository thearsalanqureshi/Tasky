class SubtaskModel {
  const SubtaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  SubtaskModel copyWith({String? id, String? title, bool? isCompleted}) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: _safeString(json['id'], fallback: _fallbackId()),
      title: _safeString(json['title'], fallback: 'Untitled step'),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static String _safeString(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static String _fallbackId() {
    return 'subtask-${DateTime.now().microsecondsSinceEpoch}';
  }
}
