import 'package:timezone/timezone.dart' as tz;

import '../models/alarm_model.dart';

const List<int> kWeekdays = <int>[
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
];

const Map<int, String> kWeekdayShortLabels = <int, String>{
  DateTime.monday: 'Mon',
  DateTime.tuesday: 'Tue',
  DateTime.wednesday: 'Wed',
  DateTime.thursday: 'Thu',
  DateTime.friday: 'Fri',
  DateTime.saturday: 'Sat',
  DateTime.sunday: 'Sun',
};

String repeatModeLabel(Alarm alarm) {
  return switch (alarm.repeatMode) {
    AlarmRepeatMode.once => 'Once',
    AlarmRepeatMode.daily => 'Every day',
    AlarmRepeatMode.weekdays => 'Weekdays',
    AlarmRepeatMode.custom => alarm.repeatDays.isEmpty
        ? 'Custom'
        : alarm.repeatDays.map(weekdayShortLabel).join(', '),
  };
}

String weekdayShortLabel(int weekday) => kWeekdayShortLabels[weekday] ?? 'Day $weekday';

String ringtoneLabel(Alarm alarm) {
  return switch (alarm.ringtoneType) {
    AlarmRingtoneType.system => 'System default',
    AlarmRingtoneType.rawResource => alarm.ringtoneValue.isEmpty
        ? 'Custom raw resource'
        : 'Raw resource: ${alarm.ringtoneValue}',
    AlarmRingtoneType.uri => alarm.ringtoneValue.isEmpty
        ? 'Custom URI'
        : 'URI: ${alarm.ringtoneValue}',
  };
}

List<int> defaultWeekdayRepeat() => <int>[
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
];

tz.TZDateTime nextOccurrence({
  required tz.TZDateTime now,
  required int hour,
  required int minute,
}) {
  var candidate = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
  if (!candidate.isAfter(now)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}

tz.TZDateTime nextOccurrenceForWeekday({
  required tz.TZDateTime now,
  required int weekday,
  required int hour,
  required int minute,
}) {
  var candidate = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
  final daysUntil = (weekday - candidate.weekday) % 7;
  candidate = candidate.add(Duration(days: daysUntil));
  if (!candidate.isAfter(now)) {
    candidate = candidate.add(const Duration(days: 7));
  }
  return candidate;
}

List<int> normalizedRepeatDays(Alarm alarm) {
  if (alarm.repeatMode == AlarmRepeatMode.weekdays && alarm.repeatDays.isEmpty) {
    return defaultWeekdayRepeat();
  }
  final days = alarm.repeatDays.toSet().toList();
  days.sort();
  return days;
}

bool isRecurring(Alarm alarm) => alarm.repeatMode != AlarmRepeatMode.once;

