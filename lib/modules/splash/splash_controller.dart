import 'package:get/get.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/notification_service.dart';

class SplashController extends GetxController {
  SplashController(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  @override
  void onReady() {
    super.onReady();
    _routeFromStorage();
  }

  Future<void> _routeFromStorage() async {
    await Future<void>.delayed(AppSizes.splashDelay);
    final targetRoute = _safeTargetRoute();
    if (Get.currentRoute == AppRoutes.splash) {
      await Get.offNamed(targetRoute);
      final launchTaskId = _notificationService.takePendingTaskId();
      if (targetRoute == AppRoutes.mainNav &&
          launchTaskId != null &&
          launchTaskId.isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (Get.currentRoute == AppRoutes.mainNav) {
          await Get.toNamed(
            AppRoutes.taskDetail,
            arguments: {'taskId': launchTaskId},
          );
        }
      }
    }
  }

  String _safeTargetRoute() {
    try {
      return _settingsRepository.getOnboardingCompleted()
          ? AppRoutes.mainNav
          : AppRoutes.onboarding;
    } catch (_) {
      return AppRoutes.onboarding;
    }
  }

  NotificationService get _notificationService =>
      Get.find<NotificationService>();
}
