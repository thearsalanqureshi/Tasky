import 'package:get/get.dart';

import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/avatar_storage_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalStorageService>(LocalStorageService.new, fenix: true);
    Get.lazyPut<NotificationService>(NotificationService.new, fenix: true);
    Get.lazyPut<AvatarStorageService>(AvatarStorageService.new, fenix: true);
    Get.lazyPut<TaskRepository>(
      () => TaskRepository(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut<SettingsRepository>(
      () => SettingsRepository(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(
        Get.find<LocalStorageService>(),
        Get.find<AvatarStorageService>(),
      ),
      fenix: true,
    );
  }
}
