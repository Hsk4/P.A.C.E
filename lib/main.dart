import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const PomodoroPage(),
    );
  }
}

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  // durations in seconds
  int workDuration = 25 * 60; // default 25 minutes
  int breakDuration = 5 * 60; // default 5 minutes

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
    setState(() {
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        // period finished
        _timer?.cancel();
        setState(() {
          isRunning = false;
        });
        _onPeriodComplete();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
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
    // swap modes
    setState(() {
      if (isWorkPeriod) {
        completedPomodoros++;
      }
      isWorkPeriod = !isWorkPeriod;
      remainingSeconds = isWorkPeriod ? workDuration : breakDuration;
    });
    // automatically start next period
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _start();
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double _progress() {
    final total = isWorkPeriod ? workDuration : breakDuration;
    return 1 - (remainingSeconds / total);
  }

  void _setWorkMinutes(int minutes) {
    setState(() {
      workDuration = minutes * 60;
      if (isWorkPeriod && !isRunning) remainingSeconds = workDuration;
    });
  }

  void _setBreakMinutes(int minutes) {
    setState(() {
      breakDuration = minutes * 60;
      if (!isWorkPeriod && !isRunning) remainingSeconds = breakDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isWorkPeriod ? Colors.deepOrange.shade50 : Colors.lightBlue.shade50;
    final accent = isWorkPeriod ? Colors.deepOrange : Colors.lightBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        backgroundColor: accent,
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () => _showSettings(context),
        child: const Icon(Icons.settings),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bgColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      isWorkPeriod ? 'Work' : 'Break',
                      key: ValueKey<bool>(isWorkPeriod),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: accent),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 260,
                    width: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 260,
                          width: 260,
                          child: CircularProgressIndicator(
                            value: _progress(),
                            strokeWidth: 14,
                            color: accent,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (w, a) => FadeTransition(opacity: a, child: w),
                              child: Text(
                                _formatDuration(remainingSeconds),
                                key: ValueKey<int>(remainingSeconds),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 18),
                                const SizedBox(width: 6),
                                Text('$completedPomodoros completed'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                        onPressed: isRunning ? _pause : _start,
                        icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(isRunning ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            isRunning = false;
                            remainingSeconds = isWorkPeriod ? workDuration : breakDuration;
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Tip: Open settings to change durations. Timer auto-switches between work and break.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        int tempWork = workDuration ~/ 60;
        int tempBreak = breakDuration ~/ 60;
        return StatefulBuilder(builder: (c, s) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Work: $tempWork min'),
                Slider(value: tempWork.toDouble(), min: 5, max: 90, divisions: 17, label: '$tempWork', onChanged: (v) => s(() => tempWork = v.round())),
                const SizedBox(height: 8),
                Text('Break: $tempBreak min'),
                Slider(value: tempBreak.toDouble(), min: 1, max: 30, divisions: 29, label: '$tempBreak', onChanged: (v) => s(() => tempBreak = v.round())),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _setWorkMinutes(tempWork);
                        _setBreakMinutes(tempBreak);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Save'),
                    )
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }
}
