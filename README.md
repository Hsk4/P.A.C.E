# flutter1

P.A.C.E is a Flutter app with Pomodoro and dynamic alarm features.

## Alarm feature

- Add and edit alarms
- Pick the time with either clock or digital input
- Repeat once, daily, weekdays, or custom days
- Choose a ringtone source:
  - system default
  - Android raw resource name in `android/app/src/main/res/raw`
  - custom URI ringtone source
- Notifications are initialized through Firebase and `flutter_local_notifications`

## Android notification setup

The Android manifest includes notification and exact-alarm permissions plus boot receivers so scheduled alarms can survive device restarts.

## Getting started

Run:

```powershell
flutter pub get
flutter test
```
