import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

class AlarmClocksView extends StatefulWidget {
  const AlarmClocksView({super.key});

  @override
  State<AlarmClocksView> createState() => _AlarmClocksViewState();
}

class _AlarmClocksViewState extends State<AlarmClocksView> {
  List<Alarm> alarms = [];

  void _addAlarm() {
    setState(() {
      alarms.add(Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        time: '09:00',
        label: 'New Alarm',
        enabled: true,
      ));
    });
  }

  void _deleteAlarm(String id) {
    setState(() {
      alarms.removeWhere((a) => a.id == id);
    });
  }

  void _toggleAlarm(String id) {
    setState(() {
      final idx = alarms.indexWhere((a) => a.id == id);
      if (idx != -1) {
        alarms[idx] = alarms[idx].copyWith(enabled: !alarms[idx].enabled);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Clocks')),
      body: alarms.isEmpty
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
              itemCount: alarms.length,
              itemBuilder: (ctx, idx) {
                final alarm = alarms[idx];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: Icon(
                      alarm.enabled ? Icons.access_alarm : Icons.alarm_off,
                      color: alarm.enabled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: Text(alarm.label),
                    subtitle: Text(alarm.time),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(alarm.enabled
                              ? Icons.toggle_on
                              : Icons.toggle_off),
                          onPressed: () => _toggleAlarm(alarm.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAlarm(alarm.id),
                        ),
                      ],
                    ),
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

