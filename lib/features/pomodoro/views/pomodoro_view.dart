import "dart:async";
import "package:flutter/material.dart";

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
    setState(() {
      if (isWorkPeriod) completedPomodoros++;
      isWorkPeriod = !isWorkPeriod;
      remainingSeconds = isWorkPeriod ? workDuration : breakDuration;
    });
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
    final bgColor = isWorkPeriod ? Colors.orange.shade50 : Colors.blue.shade50;
    final accent = isWorkPeriod ? Colors.deepOrange : Colors.lightBlue;

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: bgColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isWorkPeriod ? 'Work' : 'Break',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: accent),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 260,
                  width: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _progress(),
                        strokeWidth: 14,
                        color: accent,
                        backgroundColor: Colors.grey.shade200,
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
                    ElevatedButton.icon(
                      onPressed: isRunning ? _pause : _start,
                      icon:
                          Icon(isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(isRunning ? 'Pause' : 'Start'),
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
            ),
          ),
        ),
      ),
    );
  }
}
