import 'package:flutter/material.dart';

import '../models/pomodoro_session.dart';
import '../../../services/firebase_sync_service.dart';
import '../utils/pomodoro_progress.dart';

class PomodoroProgressView extends StatelessWidget {
  const PomodoroProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro Progress')),
      body: StreamBuilder<List<PomodoroSession>>(
        stream: FirebaseSyncService.instance.watchPomodoroSessions(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? <PomodoroSession>[];
          final summary = buildPomodoroProgressSummary(sessions);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total work sessions: ${summary.totalWorkSessions}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Total focus minutes: ${summary.totalFocusMinutes}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Today: ${summary.todayWorkSessions} sessions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Current streak: ${summary.currentStreakDays} days', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Text('Last 7 days', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildSevenDayBars(context, summary.lastSevenDayCounts, summary.lastSevenDayLabels),
                const SizedBox(height: 16),
                Text('Recent sessions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: summary.recentSessions.length,
                    itemBuilder: (context, index) {
                      final s = summary.recentSessions[index];
                      return ListTile(
                        title: Text(s.isWorkSession ? 'Work' : 'Break'),
                        subtitle: Text('${s.durationSeconds ~/ 60} min — ${s.completedAt}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSevenDayBars(BuildContext context, List<int> counts, List<String> labels) {
    final maxCount = counts.isEmpty ? 1 : (counts.reduce((a, b) => a > b ? a : b));
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(counts.length, (i) {
          final value = counts[i];
          final label = labels[i];
          final height = maxCount == 0 ? 0.0 : (value / maxCount) * 80.0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  width: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 6),
                Text(label),
              ],
            ),
          );
        }),
      ),
    );
  }
}
