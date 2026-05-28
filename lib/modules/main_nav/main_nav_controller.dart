import 'package:get/get.dart';

import '../../data/mock/tasky_mock_data.dart';

class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString username = TaskyMockData.usernameFallback.obs;
  final RxInt dailyGoal = 5.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      final providedUsername = arguments['username'];
      final providedDailyGoal = arguments['dailyGoal'];
      if (providedUsername is String && providedUsername.trim().isNotEmpty) {
        username.value = providedUsername.trim();
      }
      if (providedDailyGoal is int) {
        dailyGoal.value = providedDailyGoal;
      }
    }
  }

  void changeTab(int index) {
    if (index < 0 || index > 3) {
      return;
    }
    currentIndex.value = index;
  }
}
