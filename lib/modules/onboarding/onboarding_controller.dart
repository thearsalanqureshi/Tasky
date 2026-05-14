import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/mock/tasky_mock_data.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._profileRepository, this._settingsRepository);

  final ProfileRepository _profileRepository;
  final SettingsRepository _settingsRepository;

  final PageController pageController = PageController();
  final TextEditingController usernameController = TextEditingController();
  final RxInt currentPage = 0.obs;
  final RxInt dailyGoal = 5.obs;

  bool get isLastPage => currentPage.value == 2;

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  Future<void> nextPage() async {
    if (isLastPage) {
      await getStarted();
      return;
    }
    await pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> skip() async {
    await _openMainNav();
  }

  Future<void> getStarted() async {
    await _openMainNav();
  }

  void incrementGoal() {
    if (dailyGoal.value < 12) {
      dailyGoal.value++;
    }
  }

  void decrementGoal() {
    if (dailyGoal.value > 1) {
      dailyGoal.value--;
    }
  }

  Future<void> _openMainNav() async {
    final username = usernameController.text.trim().isEmpty
        ? TaskyMockData.usernameFallback
        : usernameController.text.trim();
    await Future.wait([
      _profileRepository.saveUsername(username),
      _settingsRepository.saveDailyGoal(dailyGoal.value),
      _settingsRepository.saveOnboardingCompleted(true),
    ]);
    await Get.offAllNamed(AppRoutes.mainNav);
  }

  @override
  void onClose() {
    pageController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
