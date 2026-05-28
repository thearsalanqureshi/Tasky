import 'package:get/get.dart';

import 'insights_controller.dart';

class InsightsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<InsightsController>()) {
      Get.lazyPut<InsightsController>(InsightsController.new);
    }
  }
}
