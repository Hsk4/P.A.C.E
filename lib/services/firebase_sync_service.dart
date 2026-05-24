import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../features/alarm_clocks/models/alarm_model.dart';
import '../features/pomodoro/models/pomodoro_session.dart';
import '../firebase_options.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class FirebaseSyncService {
  FirebaseSyncService._();

  static final FirebaseSyncService instance = FirebaseSyncService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  User? get currentUser => _auth.currentUser;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _ensureSignedIn();
    await _configureMessaging();
    _initialized = true;
  }

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser != null) {
      return;
    }

    await _auth.signInAnonymously();
  }

  Future<void> _configureMessaging() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      await _saveMessagingToken(token);

      _messaging.onTokenRefresh.listen(_saveMessagingToken);
      FirebaseMessaging.onMessage.listen((message) async {
        final notification = message.notification;
        if (notification == null) {
          return;
        }

        await NotificationService.instance.showInstantNotification(
          title: notification.title ?? 'P.A.C.E update',
          body: notification.body ?? 'You have a new message from Firebase',
        );
      });
    } catch (_) {
      // Messaging is optional when permissions or platform support are unavailable.
    }
  }

  Future<void> _saveMessagingToken(String? token) async {
    if (token == null || token.isEmpty) {
      return;
    }

    await _userDocument().set(
      <String, dynamic>{
        'fcmToken': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  DocumentReference<Map<String, dynamic>> _userDocument() {
    final userId = _auth.currentUser?.uid ?? 'anonymous';
    return _firestore.collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _alarmsCollection() {
    return _userDocument().collection('alarms');
  }

  CollectionReference<Map<String, dynamic>> _pomodoroSessionsCollection() {
    return _userDocument().collection('pomodoro_sessions');
  }

  Future<List<Alarm>> loadAlarmsFromCloud() async {
    await initialize();
    try {
      final snapshot = await _alarmsCollection().get();
      return snapshot.docs
          .map((doc) => Alarm.fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
          .toList(growable: false);
    } catch (_) {
      return <Alarm>[];
    }
  }

  Future<void> saveAlarmsToCloud(List<Alarm> alarms) async {
    await initialize();
    final collection = _alarmsCollection();
    final existingDocs = await collection.get();
    final desiredIds = alarms.map((alarm) => alarm.id).toSet();
    final batch = _firestore.batch();

    for (final doc in existingDocs.docs) {
      if (!desiredIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final alarm in alarms) {
      batch.set(
        collection.doc(alarm.id),
        <String, dynamic>{
          ...alarm.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  Future<List<PomodoroSession>> loadPomodoroSessions({int limit = 100}) async {
    await initialize();
    try {
      final snapshot = await _pomodoroSessionsCollection()
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => PomodoroSession.fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
          .toList(growable: false);
    } catch (_) {
      return <PomodoroSession>[];
    }
  }

  Stream<List<PomodoroSession>> watchPomodoroSessions({int limit = 100}) {
    return _pomodoroSessionsCollection()
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PomodoroSession.fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
              .toList(growable: false),
        );
  }

  Future<void> recordPomodoroSession(PomodoroSession session) async {
    await initialize();
    await _pomodoroSessionsCollection().doc(session.id).set(
      <String, dynamic>{
        ...session.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
