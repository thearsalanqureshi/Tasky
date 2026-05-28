import '../services/local_storage_service.dart';

class SettingsRepository {
  const SettingsRepository(this._localStorageService);

  final LocalStorageService _localStorageService;

  bool get isStorageReady => _localStorageService.isReady;
}
