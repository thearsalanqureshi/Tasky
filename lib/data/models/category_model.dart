class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final String id;
  final String name;
  final String colorHex;

  CategoryModel copyWith({String? id, String? name, String? colorHex}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'colorHex': colorHex};
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _safeString(json['id'], fallback: 'personal'),
      name: _safeString(json['name'], fallback: 'Personal'),
      colorHex: _safeColorHex(json['colorHex']),
    );
  }

  static String _safeString(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static String _safeColorHex(Object? value) {
    if (value is String && RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) {
      return value.toUpperCase();
    }
    return '#F47BD5';
  }
}
