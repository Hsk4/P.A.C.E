class Alarm {
  final String id;
  final String time;
  final String label;
  final bool enabled;
  final List<int> repeatDays;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.enabled,
    this.repeatDays = const [],
  });

  Alarm copyWith({
    String? id,
    String? time,
    String? label,
    bool? enabled,
    List<int>? repeatDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}
