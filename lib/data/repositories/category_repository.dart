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
    final categories = _localStorageService
        .getJsonList(StorageKeys.categoriesList)
        .map(CategoryModel.fromJson)
        .toList();
    return categories.isEmpty ? defaultCategories : categories;
  }

  Future<bool> saveCategories(List<CategoryModel> categories) {
    return _localStorageService.setJsonList(
      StorageKeys.categoriesList,
      categories.map((category) => category.toJson()).toList(),
    );
  }

  Future<bool> ensureDefaultCategories() async {
    if (_localStorageService.getString(StorageKeys.categoriesList) != null) {
      return true;
    }
    return saveCategories(defaultCategories);
  }
}
