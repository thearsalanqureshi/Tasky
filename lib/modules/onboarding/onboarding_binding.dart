import 'package:get/get.dart';

import 'onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OnboardingController>()) {
      Get.lazyPut<OnboardingController>(OnboardingController.new);
    }
  }
}
