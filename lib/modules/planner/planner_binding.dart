import 'package:get/get.dart';

import 'planner_controller.dart';

class PlannerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PlannerController>()) {
      Get.lazyPut<PlannerController>(
        () => PlannerController(Get.find(), Get.find(), Get.find()),
      );
    }
  }
}
