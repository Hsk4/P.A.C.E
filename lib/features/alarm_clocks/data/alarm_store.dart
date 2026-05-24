import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';
import '../../../services/firebase_sync_service.dart';

class AlarmStore {
  AlarmStore({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _storageKey = 'alarm_clocks.alarms';
  final SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    return _preferences ?? SharedPreferences.getInstance();
  }

  Future<List<Alarm>> loadAlarms() async {
    final preferences = await _prefs();
    final encodedAlarms = preferences.getStringList(_storageKey) ?? <String>[];
    final localAlarms = encodedAlarms
        .map((encoded) => Alarm.fromJson(jsonDecode(encoded) as Map<String, dynamic>))
        .toList();

    try {
      await FirebaseSyncService.instance.initialize();
      final cloudAlarms = await FirebaseSyncService.instance.loadAlarmsFromCloud();
      if (cloudAlarms.isNotEmpty) {
        await _saveLocal(preferences, cloudAlarms);
        return cloudAlarms;
      }

      if (localAlarms.isNotEmpty) {
        await FirebaseSyncService.instance.saveAlarmsToCloud(localAlarms);
      }
    } catch (_) {
      if (kDebugMode) {
        // Firebase sync is optional when the network is unavailable.
      }
    }

    return localAlarms;
  }

  Future<void> saveAlarms(List<Alarm> alarms) async {
    final preferences = await _prefs();
    await _saveLocal(preferences, alarms);

    try {
      await FirebaseSyncService.instance.saveAlarmsToCloud(alarms);
    } catch (_) {
      if (kDebugMode) {
        // Local persistence remains the source of truth if cloud sync fails.
      }
    }
  }

  Future<void> _saveLocal(
    SharedPreferences preferences,
    List<Alarm> alarms,
  ) async {
    final encodedAlarms = alarms.map((alarm) => jsonEncode(alarm.toJson())).toList(growable: false);
    await preferences.setStringList(_storageKey, encodedAlarms);
  }
}

