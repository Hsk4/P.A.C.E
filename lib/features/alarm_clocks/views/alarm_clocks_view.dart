import 'package:flutter/material.dart';

import '../data/alarm_store.dart';
import '../models/alarm_model.dart';
import '../utils/alarm_schedule.dart';
import '../../../services/notification_service.dart';
import '../widgets/alarm_editor_sheet.dart';

class AlarmClocksView extends StatefulWidget {
  const AlarmClocksView({super.key});

  @override
  State<AlarmClocksView> createState() => _AlarmClocksViewState();
}

class _AlarmClocksViewState extends State<AlarmClocksView> {
  final AlarmStore _store = AlarmStore();
  List<Alarm> _alarms = <Alarm>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final loadedAlarms = await _store.loadAlarms();
    await NotificationService.instance.refreshAlarms(loadedAlarms);
    if (!mounted) {
      return;
    }
    setState(() {
      _alarms = loadedAlarms..sort(_compareAlarms);
      _loading = false;
    });
  }

  int _compareAlarms(Alarm left, Alarm right) {
    final leftScore = left.hour * 60 + left.minute;
    final rightScore = right.hour * 60 + right.minute;
    return leftScore.compareTo(rightScore);
  }

  Future<void> _persistAlarms() async {
    _alarms.sort(_compareAlarms);
    await _store.saveAlarms(_alarms);
  }

  Future<void> _saveAlarm(Alarm alarm, {Alarm? previousAlarm}) async {
    try {
      if (previousAlarm != null) {
        await NotificationService.instance.cancelAlarm(previousAlarm);
        final previousIndex = _alarms.indexWhere((item) => item.id == previousAlarm.id);
        if (previousIndex != -1) {
          _alarms[previousIndex] = alarm;
        }
      } else {
        _alarms.add(alarm);
      }

      await _persistAlarms();
      if (alarm.enabled) {
        await NotificationService.instance.scheduleAlarm(alarm);
      }
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not schedule alarm: $error')),
        );
      }
    }
  }

  Future<void> _editAlarm(Alarm alarm) async {
    final updatedAlarm = await showAlarmEditorSheet(context, initialAlarm: alarm);
    if (!mounted || updatedAlarm == null) {
      return;
    }
    await _saveAlarm(updatedAlarm, previousAlarm: alarm);
  }

  Future<void> _addAlarm() async {
    final newAlarm = await showAlarmEditorSheet(context);
    if (!mounted || newAlarm == null) {
      return;
    }
    await _saveAlarm(newAlarm);
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    try {
      await NotificationService.instance.cancelAlarm(alarm);
      _alarms.removeWhere((item) => item.id == alarm.id);
      await _persistAlarms();
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete alarm: $error')),
        );
      }
    }
  }

  Future<void> _toggleAlarm(Alarm alarm, bool enabled) async {
    try {
      final updatedAlarm = alarm.copyWith(enabled: enabled);
      await NotificationService.instance.cancelAlarm(alarm);
      if (enabled) {
        await NotificationService.instance.scheduleAlarm(updatedAlarm);
      }

      final index = _alarms.indexWhere((item) => item.id == alarm.id);
      if (index != -1) {
        _alarms[index] = updatedAlarm;
      }
      await _persistAlarms();
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update alarm: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No alarms set',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Add one to get started'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (ctx, idx) {
                final alarm = _alarms[idx];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: Icon(
                      alarm.enabled ? Icons.alarm : Icons.alarm_off,
                      color: alarm.enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    title: Text(alarm.label),
                    subtitle: Text(
                      [
                        alarm.timeLabel,
                        repeatModeLabel(alarm),
                        ringtoneLabel(alarm),
                      ].join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Switch(
                          value: alarm.enabled,
                          onChanged: (value) => _toggleAlarm(alarm, value),
                        ),
                        IconButton(
                          tooltip: 'Edit alarm',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editAlarm(alarm),
                        ),
                        IconButton(
                          tooltip: 'Delete alarm',
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteAlarm(alarm),
                        ),
                      ],
                    ),
                    onTap: () => _editAlarm(alarm),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

