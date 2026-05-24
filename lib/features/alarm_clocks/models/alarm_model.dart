enum AlarmRepeatMode { once, daily, weekdays, custom }

enum AlarmRingtoneType { system, rawResource, uri }

class Alarm {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final bool enabled;
  final AlarmRepeatMode repeatMode;
  final List<int> repeatDays;
  final AlarmRingtoneType ringtoneType;
  final String ringtoneValue;
  final bool vibrate;

  const Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    required this.enabled,
    required this.repeatMode,
    this.repeatDays = const <int>[],
    this.ringtoneType = AlarmRingtoneType.system,
    this.ringtoneValue = '',
    this.vibrate = true,
  });

  String get timeLabel => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Alarm copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    bool? enabled,
    AlarmRepeatMode? repeatMode,
    List<int>? repeatDays,
    AlarmRingtoneType? ringtoneType,
    String? ringtoneValue,
    bool? vibrate,
  }) {
    return Alarm(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      repeatMode: repeatMode ?? this.repeatMode,
      repeatDays: repeatDays ?? this.repeatDays,
      ringtoneType: ringtoneType ?? this.ringtoneType,
      ringtoneValue: ringtoneValue ?? this.ringtoneValue,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'enabled': enabled,
      'repeatMode': repeatMode.name,
      'repeatDays': repeatDays,
      'ringtoneType': ringtoneType.name,
      'ringtoneValue': ringtoneValue,
      'vibrate': vibrate,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      hour: (json['hour'] as num?)?.toInt() ?? 7,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? 'Alarm',
      enabled: json['enabled'] as bool? ?? true,
      repeatMode: AlarmRepeatMode.values.firstWhere(
        (mode) => mode.name == json['repeatMode'],
        orElse: () => AlarmRepeatMode.once,
      ),
      repeatDays: (json['repeatDays'] as List<dynamic>? ?? const <dynamic>[])
          .map((day) => (day as num).toInt())
          .toList(growable: false),
      ringtoneType: AlarmRingtoneType.values.firstWhere(
        (type) => type.name == json['ringtoneType'],
        orElse: () => AlarmRingtoneType.system,
      ),
      ringtoneValue: json['ringtoneValue'] as String? ?? '',
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }
}
