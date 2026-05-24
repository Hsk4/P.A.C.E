import '../models/pomodoro_session.dart';

class PomodoroProgressSummary {
  const PomodoroProgressSummary({
    required this.totalWorkSessions,
    required this.totalFocusMinutes,
    required this.todayWorkSessions,
    required this.currentStreakDays,
    required this.lastSevenDayCounts,
    required this.lastSevenDayLabels,
    required this.recentSessions,
  });

  final int totalWorkSessions;
  final int totalFocusMinutes;
  final int todayWorkSessions;
  final int currentStreakDays;
  final List<int> lastSevenDayCounts;
  final List<String> lastSevenDayLabels;
  final List<PomodoroSession> recentSessions;
}

PomodoroProgressSummary buildPomodoroProgressSummary(
  List<PomodoroSession> sessions, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final workSessions = sessions.where((session) => session.isWorkSession).toList();
  workSessions.sort((left, right) => right.completedAt.compareTo(left.completedAt));

  final totalFocusMinutes = workSessions.fold<int>(
    0,
    (sum, session) => sum + session.durationSeconds ~/ 60,
  );

  final today = _dateOnly(reference);
  final todayWorkSessions = workSessions.where((session) => _dateOnly(session.completedAt) == today).length;

  final countsByDay = <DateTime, int>{};
  for (final session in workSessions) {
    final day = _dateOnly(session.completedAt);
    countsByDay[day] = (countsByDay[day] ?? 0) + 1;
  }

  final lastSevenDayCounts = <int>[];
  final lastSevenDayLabels = <String>[];
  for (var offset = 6; offset >= 0; offset--) {
    final day = _dateOnly(reference.subtract(Duration(days: offset)));
    lastSevenDayCounts.add(countsByDay[day] ?? 0);
    lastSevenDayLabels.add(_weekdayLabel(day.weekday));
  }

  final currentStreakDays = _calculateStreak(countsByDay, reference);

  return PomodoroProgressSummary(
    totalWorkSessions: workSessions.length,
    totalFocusMinutes: totalFocusMinutes,
    todayWorkSessions: todayWorkSessions,
    currentStreakDays: currentStreakDays,
    lastSevenDayCounts: lastSevenDayCounts,
    lastSevenDayLabels: lastSevenDayLabels,
    recentSessions: workSessions.take(5).toList(growable: false),
  );
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return 'Day';
  }
}

int _calculateStreak(Map<DateTime, int> countsByDay, DateTime reference) {
  var streak = 0;
  var cursor = _dateOnly(reference);
  while ((countsByDay[cursor] ?? 0) > 0) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
