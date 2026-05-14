class AppSettingsModel {
  const AppSettingsModel({
    this.themeMode = defaultThemeMode,
    this.dailyGoal = defaultDailyGoal,
    this.notificationsEnabled = false,
    this.defaultReminderTime = defaultReminderTimeValue,
    this.onboardingCompleted = false,
  });

  static const String defaultThemeMode = 'system';
  static const int defaultDailyGoal = 5;
  static const String defaultReminderTimeValue = '09:00';

  final String themeMode;
  final int dailyGoal;
  final bool notificationsEnabled;
  final String defaultReminderTime;
  final bool onboardingCompleted;

  AppSettingsModel copyWith({
    String? themeMode,
    int? dailyGoal,
    bool? notificationsEnabled,
    String? defaultReminderTime,
    bool? onboardingCompleted,
  }) {
    return AppSettingsModel(
      themeMode: safeThemeMode(themeMode ?? this.themeMode),
      dailyGoal: safeDailyGoal(dailyGoal ?? this.dailyGoal),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderTime: safeReminderTime(
        defaultReminderTime ?? this.defaultReminderTime,
      ),
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'dailyGoal': dailyGoal,
      'notificationsEnabled': notificationsEnabled,
      'defaultReminderTime': defaultReminderTime,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      themeMode: safeThemeMode(json['themeMode']),
      dailyGoal: safeDailyGoal(json['dailyGoal']),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      defaultReminderTime: safeReminderTime(json['defaultReminderTime']),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }

  static String safeThemeMode(Object? value) {
    final normalized = value is String ? value.trim().toLowerCase() : '';
    return switch (normalized) {
      'light' => 'light',
      'dark' => 'dark',
      _ => defaultThemeMode,
    };
  }

  static int safeDailyGoal(Object? value) {
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      return defaultDailyGoal;
    }
    return parsed.clamp(1, 99).toInt();
  }

  static String safeReminderTime(Object? value) {
    if (value is String && RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
      return value;
    }
    return defaultReminderTimeValue;
  }
}
