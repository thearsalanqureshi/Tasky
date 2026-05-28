import '../services/local_storage_service.dart';

class TaskRepository {
  const TaskRepository(this._localStorageService);

  final LocalStorageService _localStorageService;

  bool get isStorageReady => _localStorageService.isReady;
}
