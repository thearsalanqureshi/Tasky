class AppSettingsModel {
  const AppSettingsModel({
    this.themeMode = 'system',
    this.dailyGoal = 5,
    this.notificationsEnabled = false,
    this.defaultReminderTime,
  });

  final String themeMode;
  final int dailyGoal;
  final bool notificationsEnabled;
  final String? defaultReminderTime;

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'dailyGoal': dailyGoal,
      'notificationsEnabled': notificationsEnabled,
      'defaultReminderTime': defaultReminderTime,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      themeMode: json['themeMode'] as String? ?? 'system',
      dailyGoal: json['dailyGoal'] as int? ?? 5,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      defaultReminderTime: json['defaultReminderTime'] as String?,
    );
  }
}
