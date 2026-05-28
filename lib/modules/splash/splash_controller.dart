import 'package:get/get.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _openOnboarding();
  }

  Future<void> _openOnboarding() async {
    await Future<void>.delayed(AppSizes.splashDelay);
    if (Get.currentRoute == AppRoutes.splash) {
      // TODO: Phase 3 should check onboardingCompleted from local storage.
      await Get.offNamed(AppRoutes.onboarding);
    }
  }
}
