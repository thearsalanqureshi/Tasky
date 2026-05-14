import 'package:flutter/material.dart';

import '../../core/constants/storage_keys.dart';
import '../models/app_settings_model.dart';
import '../services/local_storage_service.dart';

class SettingsRepository {
  const SettingsRepository(this._localStorageService);

  final LocalStorageService _localStorageService;

  bool get isStorageReady => _localStorageService.isReady;

  AppSettingsModel getSettings() {
    return AppSettingsModel(
      themeMode: getThemeModeName(),
      dailyGoal: getDailyGoal(),
      notificationsEnabled: getNotificationsEnabled(),
      defaultReminderTime: getDefaultReminderTime(),
      onboardingCompleted: getOnboardingCompleted(),
    );
  }

  Future<bool> saveSettings(AppSettingsModel settings) async {
    final results = await Future.wait([
      saveThemeModeName(settings.themeMode),
      saveDailyGoal(settings.dailyGoal),
      saveNotificationsEnabled(settings.notificationsEnabled),
      saveDefaultReminderTime(settings.defaultReminderTime),
      saveOnboardingCompleted(settings.onboardingCompleted),
    ]);
    return results.every((result) => result);
  }

  ThemeMode getThemeMode() {
    return _themeModeFromString(getThemeModeName());
  }

  String getThemeModeName() {
    return AppSettingsModel.safeThemeMode(
      _localStorageService.getString(
        StorageKeys.themeMode,
        fallback: AppSettingsModel.defaultThemeMode,
      ),
    );
  }

  Future<bool> saveThemeMode(ThemeMode themeMode) {
    return saveThemeModeName(_themeModeToString(themeMode));
  }

  Future<bool> saveThemeModeName(String themeMode) {
    return _localStorageService.setString(
      StorageKeys.themeMode,
      AppSettingsModel.safeThemeMode(themeMode),
    );
  }

  int getDailyGoal() {
    return AppSettingsModel.safeDailyGoal(
      _localStorageService.getInt(
        StorageKeys.dailyGoal,
        fallback: AppSettingsModel.defaultDailyGoal,
      ),
    );
  }

  Future<bool> saveDailyGoal(int dailyGoal) {
    return _localStorageService.setInt(
      StorageKeys.dailyGoal,
      AppSettingsModel.safeDailyGoal(dailyGoal),
    );
  }

  bool getNotificationsEnabled() {
    return _localStorageService.getBool(
          StorageKeys.notificationsEnabled,
          fallback: false,
        ) ??
        false;
  }

  Future<bool> saveNotificationsEnabled(bool enabled) {
    return _localStorageService.setBool(
      StorageKeys.notificationsEnabled,
      enabled,
    );
  }

  String getDefaultReminderTime() {
    return AppSettingsModel.safeReminderTime(
      _localStorageService.getString(
        StorageKeys.defaultReminderTime,
        fallback: AppSettingsModel.defaultReminderTimeValue,
      ),
    );
  }

  Future<bool> saveDefaultReminderTime(String reminderTime) {
    return _localStorageService.setString(
      StorageKeys.defaultReminderTime,
      AppSettingsModel.safeReminderTime(reminderTime),
    );
  }

  bool getOnboardingCompleted() {
    return _localStorageService.getBool(
          StorageKeys.onboardingCompleted,
          fallback: false,
        ) ??
        false;
  }

  Future<bool> saveOnboardingCompleted(bool completed) {
    return _localStorageService.setBool(
      StorageKeys.onboardingCompleted,
      completed,
    );
  }

  Future<bool> ensureDefaults() {
    return saveSettings(getSettings());
  }

  ThemeMode _themeModeFromString(String value) {
    return switch (AppSettingsModel.safeThemeMode(value)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  String _themeModeToString(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
