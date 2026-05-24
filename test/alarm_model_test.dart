import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter1/features/alarm_clocks/models/alarm_model.dart';
import 'package:flutter1/features/alarm_clocks/utils/alarm_schedule.dart';

void main() {
  setUpAll(() {
    tz.setLocalLocation(tz.UTC);
  });

  test('Alarm JSON round trips all fields', () {
    const alarm = Alarm(
      id: '123',
      hour: 7,
      minute: 30,
      label: 'Morning run',
      enabled: true,
      repeatMode: AlarmRepeatMode.custom,
      repeatDays: <int>[DateTime.monday, DateTime.wednesday],
      ringtoneType: AlarmRingtoneType.rawResource,
      ringtoneValue: 'morning_alarm',
      vibrate: false,
    );

    final restored = Alarm.fromJson(alarm.toJson());

    expect(restored.id, alarm.id);
    expect(restored.hour, alarm.hour);
    expect(restored.minute, alarm.minute);
    expect(restored.label, alarm.label);
    expect(restored.enabled, alarm.enabled);
    expect(restored.repeatMode, alarm.repeatMode);
    expect(restored.repeatDays, alarm.repeatDays);
    expect(restored.ringtoneType, alarm.ringtoneType);
    expect(restored.ringtoneValue, alarm.ringtoneValue);
    expect(restored.vibrate, alarm.vibrate);
  });

  test('Repeat labels reflect the configured schedule', () {
    const dailyAlarm = Alarm(
      id: '1',
      hour: 8,
      minute: 0,
      label: 'Daily',
      enabled: true,
      repeatMode: AlarmRepeatMode.daily,
    );

    const customAlarm = Alarm(
      id: '2',
      hour: 9,
      minute: 15,
      label: 'Custom',
      enabled: true,
      repeatMode: AlarmRepeatMode.custom,
      repeatDays: <int>[DateTime.tuesday, DateTime.friday],
    );

    expect(repeatModeLabel(dailyAlarm), 'Every day');
    expect(repeatModeLabel(customAlarm), 'Tue, Fri');
    expect(ringtoneLabel(customAlarm), 'System default');
  });

  test('Next occurrence moves to tomorrow after the alarm time passes', () {
    final now = tz.TZDateTime.utc(2026, 5, 24, 10, 0);

    final next = nextOccurrence(now: now, hour: 9, minute: 30);

    expect(next.year, 2026);
    expect(next.month, 5);
    expect(next.day, 25);
    expect(next.hour, 9);
    expect(next.minute, 30);
  });
}

