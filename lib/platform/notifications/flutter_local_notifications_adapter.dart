import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:worker_rest_calendar/features/reminders/application/reminder_platform_adapter.dart';
import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';

final class FlutterLocalNotificationsAdapter
    implements ReminderPlatformAdapter {
  FlutterLocalNotificationsAdapter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Set<int> _knownIds = {};
  var _initialized = false;
  var _supported = true;
  static var _timeZonesInitialized = false;

  static const _androidDetails = AndroidNotificationDetails(
    'schedule_reminders',
    '排班提醒',
    channelDescription: '明日状态、调休上班、周预览和休息倒计时',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _darwinDetails = DarwinNotificationDetails();
  static const _windowsDetails = WindowsNotificationDetails();

  @override
  Future<void> initialize({
    required void Function(String payload) onTap,
  }) async {
    if (_initialized) {
      return;
    }
    try {
      final result = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          windows: WindowsInitializationSettings(
            appName: '工作日历',
            appUserModelId: 'com.workerrestcalendar.app',
            guid: 'd45db8f3-88cf-4d6c-a23e-9d267d671ab0',
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null) {
            onTap(payload);
          }
        },
      );
      _supported = result ?? false;
      _initialized = true;

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      final launchPayload = launchDetails?.notificationResponse?.payload;
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchPayload != null) {
        onTap(launchPayload);
      }
    } on MissingPluginException {
      _supported = false;
      _initialized = true;
    } on PlatformException {
      _supported = false;
      _initialized = true;
    } on UnsupportedError {
      _supported = false;
      _initialized = true;
    }
  }

  @override
  Future<ReminderPermissionStatus> getPermissionStatus() async {
    if (!_supported) {
      return ReminderPermissionStatus.unsupported;
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final enabled = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled();
        return enabled == true
            ? ReminderPermissionStatus.granted
            : ReminderPermissionStatus.systemDisabled;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.checkPermissions();
        return options?.isEnabled == true
            ? ReminderPermissionStatus.granted
            : ReminderPermissionStatus.systemDisabled;
      }
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.checkPermissions();
        return options?.isEnabled == true
            ? ReminderPermissionStatus.granted
            : ReminderPermissionStatus.systemDisabled;
      }
      if (defaultTargetPlatform == TargetPlatform.windows) {
        return ReminderPermissionStatus.granted;
      }
      return ReminderPermissionStatus.unsupported;
    } on Object {
      return ReminderPermissionStatus.unsupported;
    }
  }

  @override
  Future<ReminderPermissionStatus> requestPermission() async {
    if (!_supported) {
      return ReminderPermissionStatus.unsupported;
    }
    try {
      bool? granted;
      if (defaultTargetPlatform == TargetPlatform.android) {
        granted = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        granted = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        granted = await _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        return ReminderPermissionStatus.granted;
      }
      return granted == true
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.systemDisabled;
    } on Object {
      return ReminderPermissionStatus.unsupported;
    }
  }

  @override
  Future<int> replaceAll(
    List<ScheduledReminder> reminders, {
    required String timeZoneId,
  }) async {
    if (!_supported) {
      return 0;
    }
    final existingIds = await _ownedPendingIds();
    for (final id in existingIds) {
      await _plugin.cancel(id: id);
    }
    _knownIds.clear();

    final location = await _resolveLocation(timeZoneId);
    final limited =
        defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS
        ? reminders.take(64)
        : reminders;
    for (final reminder in limited) {
      final moment = reminder.moment;
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime(
          location,
          moment.date.year,
          moment.date.month,
          moment.date.day,
          moment.hour,
          moment.minute,
        ),
        notificationDetails: const NotificationDetails(
          android: _androidDetails,
          iOS: _darwinDetails,
          macOS: _darwinDetails,
          windows: _windowsDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.payload,
      );
      _knownIds.add(reminder.id);
    }
    return _knownIds.length;
  }

  @override
  Future<int> pendingCount() async {
    if (!_supported) {
      return 0;
    }
    return (await _ownedPendingIds()).length;
  }

  Future<Set<int>> _ownedPendingIds() async {
    try {
      final requests = await _plugin.pendingNotificationRequests();
      return requests.map((request) => request.id).where(_isOwnedId).toSet();
    } on Object {
      return Set.of(_knownIds);
    }
  }

  bool _isOwnedId(int id) => id >= 100000000 && id < 500000000;

  Future<tz.Location> _resolveLocation(String configuredId) async {
    if (!_timeZonesInitialized) {
      tz_data.initializeTimeZones();
      _timeZonesInitialized = true;
    }
    var locationId = configuredId;
    if (locationId == 'local') {
      try {
        locationId = (await FlutterTimezone.getLocalTimezone()).identifier;
      } on Object {
        return _fixedOffsetLocation();
      }
    }
    try {
      return tz.getLocation(locationId);
    } on Object {
      return _fixedOffsetLocation();
    }
  }

  tz.Location _fixedOffsetLocation() =>
      tz.Location('device-local-fixed', const [], const [], [
        tz.TimeZone(
          DateTime.now().timeZoneOffset,
          isDst: false,
          abbreviation: DateTime.now().timeZoneName,
        ),
      ]);
}
