import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/routes/app_routes.dart';
import '../models/task_model.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _isInitialized = false;
  String? _pendingTaskId;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );
      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      await _createTaskyChannel();
      _isInitialized = true;

      try {
        final launchDetails = await _plugin.getNotificationAppLaunchDetails();
        if (launchDetails?.didNotificationLaunchApp ?? false) {
          _pendingTaskId = _payloadToTaskId(
            launchDetails?.notificationResponse?.payload,
          );
        }
      } catch (_) {
        _pendingTaskId = null;
      }
    } catch (_) {
      _isInitialized = false;
    }
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return (await android?.requestNotificationsPermission()) ?? true;
      }

      if (Platform.isIOS || Platform.isMacOS) {
        final darwin = _plugin
            .resolvePlatformSpecificImplementation<
              DarwinFlutterLocalNotificationsPlugin
            >();
        return (await darwin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            )) ??
            true;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> areNotificationsAllowed() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return (await android?.areNotificationsEnabled()) ?? true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> scheduleTaskReminder(TaskModel task) async {
    if (!_isInitialized) {
      return false;
    }

    final reminderAt = task.reminderAt;
    if (task.isCompleted || reminderAt == null) {
      await cancelTaskReminder(task.id);
      return false;
    }

    if (!reminderAt.isAfter(DateTime.now())) {
      await cancelTaskReminder(task.id);
      return false;
    }

    if (!await areNotificationsAllowed()) {
      return false;
    }

    try {
      final notificationDetails = _buildNotificationDetails();
      final scheduledDate = tz.TZDateTime.from(reminderAt.toUtc(), tz.UTC);
      await _plugin.zonedSchedule(
        buildNotificationId(task.id),
        'Tasky reminder',
        task.title.trim().isEmpty
            ? 'Open Tasky to review this task.'
            : task.title,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: task.id,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rescheduleTaskReminder(TaskModel task) async {
    await cancelTaskReminder(task.id);
    return scheduleTaskReminder(task);
  }

  Future<void> cancelTaskReminder(String taskId) async {
    if (!_isInitialized || taskId.trim().isEmpty) {
      return;
    }

    try {
      await _plugin.cancel(buildNotificationId(taskId));
    } catch (_) {
      return;
    }
  }

  Future<void> cancelAllTaskReminders() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _plugin.cancelAll();
    } catch (_) {
      return;
    }
  }

  Future<bool> syncTaskReminder(
    TaskModel task, {
    required bool notificationsEnabled,
    bool requestPermissionIfNeeded = false,
  }) async {
    if (!notificationsEnabled) {
      await cancelTaskReminder(task.id);
      return true;
    }

    final reminderAt = task.reminderAt;
    if (task.isCompleted || reminderAt == null) {
      await cancelTaskReminder(task.id);
      return true;
    }

    if (!reminderAt.isAfter(DateTime.now())) {
      await cancelTaskReminder(task.id);
      return false;
    }

    if (requestPermissionIfNeeded) {
      if (!await requestPermissions()) {
        return false;
      }
    } else {
      final allowed = await areNotificationsAllowed();
      if (!allowed) {
        return false;
      }
    }

    return scheduleTaskReminder(task);
  }

  int buildNotificationId(String taskId) {
    var hash = 0x1fffffff;
    for (final codeUnit in taskId.codeUnits) {
      hash = 0x1fffffff & (hash + codeUnit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= (hash >> 6);
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= (hash >> 11);
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    final id = hash & 0x7fffffff;
    return id == 0 ? 1 : id;
  }

  String? takePendingTaskId() {
    final taskId = _pendingTaskId;
    _pendingTaskId = null;
    return taskId;
  }

  Future<void> _createTaskyChannel() async {
    try {
      if (!Platform.isAndroid) {
        return;
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) {
        return;
      }
      const channel = AndroidNotificationChannel(
        'tasky_reminders',
        'Tasky reminders',
        description: 'Offline reminders for Tasky tasks.',
        importance: Importance.max,
      );
      await android.createNotificationChannel(channel);
    } catch (_) {
      return;
    }
  }

  NotificationDetails _buildNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'tasky_reminders',
        'Tasky reminders',
        channelDescription: 'Offline reminders for Tasky tasks.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final taskId = _payloadToTaskId(response.payload);
    if (taskId == null) {
      return;
    }

    if (_tryOpenTaskDetail(taskId)) {
      return;
    }

    _pendingTaskId = taskId;
  }

  bool _tryOpenTaskDetail(String taskId) {
    try {
      if (Get.currentRoute.isNotEmpty &&
          Get.currentRoute != AppRoutes.splash &&
          Get.currentRoute != '/') {
        Get.toNamed(AppRoutes.taskDetail, arguments: {'taskId': taskId});
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  String? _payloadToTaskId(String? payload) {
    final taskId = payload?.trim();
    if (taskId == null || taskId.isEmpty) {
      return null;
    }
    return taskId;
  }
}
