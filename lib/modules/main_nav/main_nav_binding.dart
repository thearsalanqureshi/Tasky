import 'package:get/get.dart';

import '../home/home_controller.dart';
import '../insights/insights_controller.dart';
import '../planner/planner_controller.dart';
import '../tasks/tasks_controller.dart';
import 'main_nav_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainNavController>()) {
      Get.lazyPut<MainNavController>(
        () => MainNavController(Get.find(), Get.find()),
      );
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(Get.find(), Get.find(), Get.find()),
      );
    }
    if (!Get.isRegistered<TasksController>()) {
      Get.lazyPut<TasksController>(
        () => TasksController(Get.find(), Get.find()),
      );
    }
    if (!Get.isRegistered<PlannerController>()) {
      Get.lazyPut<PlannerController>(
        () => PlannerController(Get.find(), Get.find(), Get.find()),
      );
    }
    if (!Get.isRegistered<InsightsController>()) {
      Get.lazyPut<InsightsController>(
        () => InsightsController(Get.find(), Get.find()),
      );
    }
  }
}
