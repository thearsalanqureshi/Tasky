import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/planner_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/avatar_storage_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = await LocalStorageService().init();
  final avatarStorageService = AvatarStorageService();
  final notificationService = NotificationService();
  final settingsRepository = SettingsRepository(localStorageService);
  final profileRepository = ProfileRepository(
    localStorageService,
    avatarStorageService,
  );
  final taskRepository = TaskRepository(localStorageService);
  final categoryRepository = CategoryRepository(localStorageService);
  final plannerRepository = PlannerRepository(localStorageService);

  Get
    ..put<LocalStorageService>(localStorageService, permanent: true)
    ..put<AvatarStorageService>(avatarStorageService, permanent: true)
    ..put<NotificationService>(notificationService, permanent: true)
    ..put<SettingsRepository>(settingsRepository, permanent: true)
    ..put<ProfileRepository>(profileRepository, permanent: true)
    ..put<TaskRepository>(taskRepository, permanent: true)
    ..put<PlannerRepository>(plannerRepository, permanent: true)
    ..put<CategoryRepository>(categoryRepository, permanent: true);

  await Future.wait([
    settingsRepository.ensureDefaults(),
    profileRepository.ensureDefaults(),
    categoryRepository.ensureDefaultCategories(),
  ]);

  await notificationService.initialize();

  runApp(TaskyApp(initialThemeMode: settingsRepository.getThemeMode()));
}
