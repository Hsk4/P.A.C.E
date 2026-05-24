import 'package:cloud_firestore/cloud_firestore.dart';

class PomodoroSession {
  const PomodoroSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.isWorkSession,
  });

  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final bool isWorkSession;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'durationSeconds': durationSeconds,
      'isWorkSession': isWorkSession,
    };
  }

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      startedAt: _readDateTime(json['startedAt']) ?? DateTime.now(),
      completedAt: _readDateTime(json['completedAt']) ?? DateTime.now(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      isWorkSession: json['isWorkSession'] as bool? ?? true,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}

