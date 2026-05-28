class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final String id;
  final String name;
  final String colorHex;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'colorHex': colorHex};
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      colorHex: json['colorHex'] as String? ?? '',
    );
  }
}
