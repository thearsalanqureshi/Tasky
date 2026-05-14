import '../../core/constants/storage_keys.dart';
import '../models/user_profile_model.dart';
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

  UserProfileModel getProfile() {
    return UserProfileModel(
      username: getUsername(),
      avatarPath: getAvatarPath(),
    );
  }

  Future<bool> saveProfile(UserProfileModel profile) async {
    final results = await Future.wait([
      saveUsername(profile.username),
      if (profile.avatarPath == null)
        _localStorageService.remove(StorageKeys.avatarPath)
      else
        saveAvatarPath(profile.avatarPath!),
    ]);
    return results.every((result) => result);
  }

  String getUsername() {
    final storedUsername = _localStorageService.getString(
      StorageKeys.username,
      fallback: UserProfileModel.defaultUsername,
    );
    return UserProfileModel(
      username: storedUsername ?? UserProfileModel.defaultUsername,
    ).username;
  }

  Future<bool> saveUsername(String username) {
    final safeUsername = UserProfileModel(username: username).username;
    return _localStorageService.setString(StorageKeys.username, safeUsername);
  }

  String? getAvatarPath() {
    return _localStorageService.getString(StorageKeys.avatarPath);
  }

  Future<bool> saveAvatarPath(String path) async {
    final savedPath = await _avatarStorageService.saveAvatarPath(path);
    if (savedPath == null) {
      return false;
    }
    return _localStorageService.setString(StorageKeys.avatarPath, savedPath);
  }

  Future<bool> clearAvatarPath() async {
    final avatarPath = getAvatarPath();
    if (avatarPath != null) {
      await _avatarStorageService.deleteAvatarFile(avatarPath);
    }
    return _localStorageService.remove(StorageKeys.avatarPath);
  }

  Future<bool> clearProfile() async {
    final results = await Future.wait([
      _localStorageService.remove(StorageKeys.username),
      _localStorageService.remove(StorageKeys.avatarPath),
    ]);
    await _avatarStorageService.clearAvatar();
    return results.every((result) => result);
  }

  Future<bool> ensureDefaults() {
    return saveUsername(getUsername());
  }
}
