import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../features/alarm_clocks/models/alarm_model.dart';
import '../features/alarm_clocks/utils/alarm_schedule.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'alarm_notifications';
  static const String _channelName = 'Alarm notifications';
  static const String _channelDescription = 'Notification channel for scheduled alarms';

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    await _configureTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initializationSettings);

    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> _configureTimeZone() async {
    try {
      final dynamic timeZoneNameOrInfo = await FlutterTimezone.getLocalTimezone();
      final timeZoneName = timeZoneNameOrInfo is String ? timeZoneNameOrInfo : (timeZoneNameOrInfo?.toString() ?? 'UTC');
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> refreshAlarms(List<Alarm> alarms) async {
	await initialize();
	for (final alarm in alarms) {
	  await cancelAlarm(alarm);
	  if (alarm.enabled) {
		await scheduleAlarm(alarm);
	  }
	}
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
	if (!alarm.enabled) {
	  return;
	}

	await initialize();
	final details = _notificationDetailsFor(alarm);
	final now = tz.TZDateTime.now(tz.local);
	final scheduledRepeatDays = normalizedRepeatDays(alarm);

	switch (alarm.repeatMode) {
	  case AlarmRepeatMode.once:
		await _plugin.zonedSchedule(
		  _notificationId(alarm.id),
		  alarm.label,
		  'Alarm for ${alarm.timeLabel}',
		  nextOccurrence(
			now: now,
			hour: alarm.hour,
			minute: alarm.minute,
		  ),
		  details,
		  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
		  uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
		  payload: alarm.id,
		);
	  case AlarmRepeatMode.daily:
		final firstOccurrence = nextOccurrence(
		  now: now,
		  hour: alarm.hour,
		  minute: alarm.minute,
		);
		await _plugin.zonedSchedule(
		  _notificationId(alarm.id),
		  alarm.label,
		  'Alarm for ${alarm.timeLabel}',
		  firstOccurrence,
		  details,
		  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
		  uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
		  matchDateTimeComponents: DateTimeComponents.time,
		  payload: alarm.id,
		);
	  case AlarmRepeatMode.weekdays:
	  case AlarmRepeatMode.custom:
		if (scheduledRepeatDays.isEmpty) {
		  await _plugin.zonedSchedule(
			_notificationId(alarm.id),
			alarm.label,
			'Alarm for ${alarm.timeLabel}',
			nextOccurrence(
			  now: now,
			  hour: alarm.hour,
			  minute: alarm.minute,
			),
			details,
			androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
			uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
			payload: alarm.id,
		  );
		  return;
		}

		for (final weekday in scheduledRepeatDays) {
		  final weekdayDate = nextOccurrenceForWeekday(
			now: now,
			weekday: weekday,
			hour: alarm.hour,
			minute: alarm.minute,
		  );
		  await _plugin.zonedSchedule(
			_notificationId(alarm.id, suffix: weekday),
			alarm.label,
			'Alarm for ${alarm.timeLabel}',
			weekdayDate,
			details,
			androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
			uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
			matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
			payload: alarm.id,
		  );
		}
	}
  }

  Future<void> cancelAlarm(Alarm alarm) async {
	await initialize();
	final ids = <int>[
	  _notificationId(alarm.id),
	  ...normalizedRepeatDays(alarm).map((weekday) => _notificationId(alarm.id, suffix: weekday)),
	];

	for (final id in ids.toSet()) {
	  await _plugin.cancel(id);
	}
  }

  NotificationDetails _notificationDetailsFor(Alarm alarm) {
	return NotificationDetails(
	  android: AndroidNotificationDetails(
		_channelId,
		_channelName,
		channelDescription: _channelDescription,
		importance: Importance.max,
		priority: Priority.high,
		category: AndroidNotificationCategory.alarm,
		playSound: true,
		enableVibration: alarm.vibrate,
		visibility: NotificationVisibility.public,
		fullScreenIntent: true,
		sound: _androidNotificationSound(alarm),
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

  AndroidNotificationSound? _androidNotificationSound(Alarm alarm) {
	return switch (alarm.ringtoneType) {
	  AlarmRingtoneType.system => null,
	  AlarmRingtoneType.rawResource => alarm.ringtoneValue.isEmpty
		  ? null
		  : RawResourceAndroidNotificationSound(alarm.ringtoneValue),
	  AlarmRingtoneType.uri => alarm.ringtoneValue.isEmpty
		  ? null
		  : UriAndroidNotificationSound(alarm.ringtoneValue),
	};
  }

  int _notificationId(String alarmId, {int suffix = 0}) {
	final baseId = int.tryParse(alarmId) ?? alarmId.hashCode.abs();
	return ((baseId * 31) + suffix) % 2147483647;
  }

  Future<void> showInstantNotification({
	required String title,
	required String body,
  }) async {
	await initialize();
	await _plugin.show(
	  DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
	  title,
	  body,
	  _genericNotificationDetails(),
	);
  }

  NotificationDetails _genericNotificationDetails() {
	return const NotificationDetails(
	  android: AndroidNotificationDetails(
		_channelId,
		_channelName,
		channelDescription: _channelDescription,
		importance: Importance.max,
		priority: Priority.high,
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
}
