import "dart:async";
import "package:flutter/material.dart";

import '../models/pomodoro_session.dart';
import '../../../services/firebase_sync_service.dart';
import 'pomodoro_progress_view.dart';

class PomodoroView extends StatefulWidget {
  const PomodoroView({super.key});

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  int workDuration = 25 * 60;
  int breakDuration = 5 * 60;
  late int remainingSeconds;
  Timer? _timer;
  bool isRunning = false;
  bool isWorkPeriod = true;
  int completedPomodoros = 0;

  @override
  void initState() {
    super.initState();
    remainingSeconds = workDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (isRunning) return;
    setState(() => isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => isRunning = false);
        _onPeriodComplete();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      isWorkPeriod = true;
      remainingSeconds = workDuration;
      completedPomodoros = 0;
    });
  }

  void _onPeriodComplete() {
    final completedWasWork = isWorkPeriod;
    setState(() {
      if (isWorkPeriod) completedPomodoros++;
      isWorkPeriod = !isWorkPeriod;
      remainingSeconds = isWorkPeriod ? workDuration : breakDuration;
    });

    if (completedWasWork) {
      final now = DateTime.now();
      final session = PomodoroSession(
        id: now.microsecondsSinceEpoch.toString(),
        startedAt: now.subtract(Duration(seconds: workDuration)),
        completedAt: now,
        durationSeconds: workDuration,
        isWorkSession: true,
      );
      // Fire-and-forget recording to cloud; local app state remains authoritative.
      FirebaseSyncService.instance.recordPomodoroSession(session);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _start();
    });
  }

  String _format(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double _progress() {
    final total = isWorkPeriod ? workDuration : breakDuration;
    return 1 - (remainingSeconds / total);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A0D14);
    final accent = isWorkPeriod
        ? const Color(0xFFFF7A00)
        : const Color(0xFFDC143C);
    const accentGradient = LinearGradient(
      colors: [Color(0xFFFF7A00), Color(0xFFDC143C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        actions: [
          IconButton(
            tooltip: 'Progress',
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PomodoroProgressView()));
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bgColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final timerSize =
                    (constraints.biggest.shortestSide * 0.48).clamp(180.0, 300.0);

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => accentGradient.createShader(bounds),
                      child: Text(
                        isWorkPeriod ? 'Work' : 'Break',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: timerSize,
                      width: timerSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161C28),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2E3748)),
                            ),
                          ),
                          SizedBox(
                            height: timerSize,
                            width: timerSize,
                            child: CircularProgressIndicator(
                              value: _progress(),
                              strokeWidth: 14,
                              color: accent,
                              backgroundColor: const Color(0xFF3A465A),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _format(remainingSeconds),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text('Completed: $completedPomodoros'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: accentGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: isRunning ? _pause : _start,
                            icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                            label: Text(isRunning ? 'Pause' : 'Start'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            _timer?.cancel();
                            setState(() {
                              isRunning = false;
                              remainingSeconds = isWorkPeriod
                                  ? workDuration
                                  : breakDuration;
                            });
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
