import 'package:get/get.dart';

import '../../modules/main_nav/main_nav_binding.dart';
import '../../modules/main_nav/main_nav_view.dart';
import '../../modules/onboarding/onboarding_binding.dart';
import '../../modules/onboarding/onboarding_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/tasks/add_edit_task_view.dart';
import '../../modules/tasks/task_detail_view.dart';
import '../../modules/tasks/tasks_binding.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: AppRoutes.addEditTask,
      page: () => const AddEditTaskView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.taskDetail,
      page: () => const TaskDetailView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
