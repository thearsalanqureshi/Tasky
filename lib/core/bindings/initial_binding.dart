import 'package:get/get.dart';

import '../../data/repositories/category_repository.dart';
import '../../data/repositories/planner_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/services/avatar_storage_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final localStorageService = Get.find<LocalStorageService>();

    if (!Get.isRegistered<NotificationService>()) {
      Get.put<NotificationService>(NotificationService(), permanent: true);
    }
    if (!Get.isRegistered<AvatarStorageService>()) {
      Get.put<AvatarStorageService>(AvatarStorageService(), permanent: true);
    }
    if (!Get.isRegistered<TaskRepository>()) {
      Get.put<TaskRepository>(
        TaskRepository(localStorageService),
        permanent: true,
      );
    }
    if (!Get.isRegistered<PlannerRepository>()) {
      Get.put<PlannerRepository>(
        PlannerRepository(localStorageService),
        permanent: true,
      );
    }
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.put<CategoryRepository>(
        CategoryRepository(localStorageService),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SettingsRepository>()) {
      Get.put<SettingsRepository>(
        SettingsRepository(localStorageService),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.put<ProfileRepository>(
        ProfileRepository(
          localStorageService,
          Get.find<AvatarStorageService>(),
        ),
        permanent: true,
      );
    }
  }
}
