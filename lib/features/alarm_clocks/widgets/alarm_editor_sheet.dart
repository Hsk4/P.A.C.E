import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../utils/alarm_schedule.dart';

Future<Alarm?> showAlarmEditorSheet(
  BuildContext context, {
  Alarm? initialAlarm,
}) {
  return showModalBottomSheet<Alarm>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return AlarmEditorSheet(initialAlarm: initialAlarm);
    },
  );
}

class AlarmEditorSheet extends StatefulWidget {
  const AlarmEditorSheet({super.key, this.initialAlarm});

  final Alarm? initialAlarm;

  @override
  State<AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends State<AlarmEditorSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _ringtoneController;
  late TimeOfDay _timeOfDay;
  late AlarmRepeatMode _repeatMode;
  late AlarmRingtoneType _ringtoneType;
  late bool _enabled;
  late bool _vibrate;
  late Set<int> _selectedDays;
  TimePickerEntryMode _timePickerEntryMode = TimePickerEntryMode.dial;

  @override
  void initState() {
    super.initState();
    final alarm = widget.initialAlarm;
    _labelController = TextEditingController(text: alarm?.label ?? 'Alarm');
    _ringtoneController = TextEditingController(text: alarm?.ringtoneValue ?? 'alarm_tone');
    _timeOfDay = TimeOfDay(hour: alarm?.hour ?? 7, minute: alarm?.minute ?? 0);
    _repeatMode = alarm?.repeatMode ?? AlarmRepeatMode.once;
    _ringtoneType = alarm?.ringtoneType ?? AlarmRingtoneType.rawResource;
    _enabled = alarm?.enabled ?? true;
    _vibrate = alarm?.vibrate ?? true;
    _selectedDays = <int>{
      ...((alarm?.repeatMode == AlarmRepeatMode.weekdays) ? defaultWeekdayRepeat() : alarm?.repeatDays ?? const <int>[]),
    };
  }

  @override
  void dispose() {
    _labelController.dispose();
    _ringtoneController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
      initialEntryMode: _timePickerEntryMode,
    );
    if (!mounted || pickedTime == null) {
      return;
    }
    setState(() => _timeOfDay = pickedTime);
  }

  void _toggleDay(int weekday) {
    setState(() {
      if (_selectedDays.contains(weekday)) {
        _selectedDays.remove(weekday);
      } else {
        _selectedDays.add(weekday);
      }
    });
  }

  void _applyPresetDays() {
    if (_repeatMode == AlarmRepeatMode.weekdays) {
      _selectedDays = defaultWeekdayRepeat().toSet();
    }
  }

  Alarm _buildAlarm() {
    final ringtoneValue = _ringtoneController.text.trim();
    final effectiveRepeatDays = _repeatMode == AlarmRepeatMode.weekdays
        ? defaultWeekdayRepeat()
        : (_selectedDays.toList()..sort());

    return (widget.initialAlarm ?? Alarm(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      hour: _timeOfDay.hour,
      minute: _timeOfDay.minute,
      label: _labelController.text.trim().isEmpty ? 'Alarm' : _labelController.text.trim(),
      enabled: _enabled,
      repeatMode: _repeatMode,
    )).copyWith(
      hour: _timeOfDay.hour,
      minute: _timeOfDay.minute,
      label: _labelController.text.trim().isEmpty ? 'Alarm' : _labelController.text.trim(),
      enabled: _enabled,
      repeatMode: _repeatMode,
      repeatDays: effectiveRepeatDays,
      ringtoneType: _ringtoneType,
      ringtoneValue: ringtoneValue,
      vibrate: _vibrate,
    );
  }

  Widget _buildDayChip(int weekday) {
    final selected = _selectedDays.contains(weekday);
    final enabled = _repeatMode == AlarmRepeatMode.custom;

    return ChoiceChip(
      label: Text(weekdayShortLabel(weekday)),
      selected: selected,
      onSelected: enabled ? (_) => _toggleDay(weekday) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialAlarm != null;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit alarm' : 'New alarm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: _timePickerEntryMode == TimePickerEntryMode.dial ? 'Use digital input' : 'Use clock',
                    icon: Icon(
                      _timePickerEntryMode == TimePickerEntryMode.dial
                          ? Icons.keyboard_outlined
                          : Icons.access_time,
                    ),
                    onPressed: () {
                      setState(() {
                        _timePickerEntryMode = _timePickerEntryMode == TimePickerEntryMode.dial
                            ? TimePickerEntryMode.input
                            : TimePickerEntryMode.dial;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time'),
                subtitle: Text(_timeOfDay.format(context)),
                trailing: FilledButton.tonalIcon(
                  onPressed: _pickTime,
                  icon: Icon(
                    _timePickerEntryMode == TimePickerEntryMode.dial
                        ? Icons.watch_later_outlined
                        : Icons.keyboard_outlined,
                  ),
                  label: Text(
                    _timePickerEntryMode == TimePickerEntryMode.dial ? 'Clock' : 'Digital',
                  ),
                ),
              ),
               const SizedBox(height: 8),
                DropdownButtonFormField<AlarmRepeatMode>(
                  initialValue: _repeatMode,
                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                   border: OutlineInputBorder(),
                 ),
                items: AlarmRepeatMode.values
                    .map(
                      (mode) => DropdownMenuItem<AlarmRepeatMode>(
                        value: mode,
                        child: Text(
                          switch (mode) {
                            AlarmRepeatMode.once => 'Once',
                            AlarmRepeatMode.daily => 'Daily',
                            AlarmRepeatMode.weekdays => 'Weekdays',
                            AlarmRepeatMode.custom => 'Custom days',
                          },
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _repeatMode = value;
                    _applyPresetDays();
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_repeatMode == AlarmRepeatMode.weekdays || _repeatMode == AlarmRepeatMode.custom) ...<Widget>[
                Text(
                  _repeatMode == AlarmRepeatMode.weekdays
                      ? 'Repeats on weekdays'
                      : 'Select repeat days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kWeekdays.map(_buildDayChip).toList(growable: false),
                ),
                const SizedBox(height: 12),
               ],
                DropdownButtonFormField<AlarmRingtoneType>(
                  initialValue: _ringtoneType,
                  decoration: const InputDecoration(
                    labelText: 'Ringtone source',
                    border: OutlineInputBorder(),
                  ),
                items: AlarmRingtoneType.values
                    .map(
                      (type) => DropdownMenuItem<AlarmRingtoneType>(
                        value: type,
                        child: Text(
                          switch (type) {
                            AlarmRingtoneType.system => 'System default',
                            AlarmRingtoneType.rawResource => 'Android raw resource',
                            AlarmRingtoneType.uri => 'Custom URI',
                          },
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _ringtoneType = value);
                },
              ),
              const SizedBox(height: 12),
              if (_ringtoneType != AlarmRingtoneType.system)
                TextField(
                  controller: _ringtoneController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: _ringtoneType == AlarmRingtoneType.rawResource
                        ? 'Raw resource name'
                        : 'URI',
                    hintText: _ringtoneType == AlarmRingtoneType.rawResource
                        ? 'my_alarm_sound'
                        : 'content:// or file:// URI',
                    helperText: _ringtoneType == AlarmRingtoneType.rawResource
                        ? 'Put the audio file in android/app/src/main/res/raw'
                        : 'Use a content URI or file URI for a device sound',
                    border: const OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibrate'),
                value: _vibrate,
                onChanged: (value) => setState(() => _vibrate = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enabled'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_buildAlarm()),
                      child: Text(isEditing ? 'Save' : 'Add alarm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

