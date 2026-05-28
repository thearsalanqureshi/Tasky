import 'dart:convert';
import '../../core/constants/storage_keys.dart';
import '../models/category_model.dart';
import '../services/local_storage_service.dart';

class CategoryRepository {
  const CategoryRepository(this._localStorageService);

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(id: 'study', name: 'Study', colorHex: '#FFD84D'),
    CategoryModel(id: 'personal', name: 'Personal', colorHex: '#F47BD5'),
    CategoryModel(id: 'work', name: 'Work', colorHex: '#A7D8FF'),
    CategoryModel(id: 'health', name: 'Health', colorHex: '#8CF28A'),
    CategoryModel(id: 'project', name: 'Project', colorHex: '#FFFFFF'),
  ];

  final LocalStorageService _localStorageService;

  List<CategoryModel> getCategories() {
    final jsonString = _localStorageService.readString(StorageKeys.categoriesList);
    if (jsonString == null || jsonString.isEmpty) {
      return defaultCategories;
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final categories = decoded
            .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return categories.isEmpty ? defaultCategories : categories;
      }
    } catch (_) {
      // fallback
    }
    return defaultCategories;
  }

  Future<bool> saveCategories(List<CategoryModel> categories) {
    final jsonString = jsonEncode(
      categories.map((category) => category.toJson()).toList(),
    );
    return _localStorageService.writeString(
      StorageKeys.categoriesList,
      jsonString,
    );
  }

  Future<bool> ensureDefaultCategories() async {
    if (_localStorageService.readString(StorageKeys.categoriesList) != null) {
      return true;
    }
    return saveCategories(defaultCategories);
  }
}
