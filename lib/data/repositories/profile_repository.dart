import '../services/avatar_storage_service.dart';
import '../services/local_storage_service.dart';

class ProfileRepository {
  const ProfileRepository(
    this._localStorageService,
    this._avatarStorageService,
  );

  final LocalStorageService _localStorageService;
  final AvatarStorageService _avatarStorageService;

  bool get isStorageReady => _localStorageService.isReady;

  Future<String?> readAvatarPath() {
    return _avatarStorageService.readAvatarPath();
  }
}
