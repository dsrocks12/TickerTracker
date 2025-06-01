  import 'dart:math';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:ticker/homescreen.dart';
  import 'package:workmanager/workmanager.dart';
  import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
  import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
  import 'package:flutter_callkit_incoming/entities/android_params.dart';
  import 'package:permission_handler/permission_handler.dart';

  const String taskName = "show_fake_call";

  @pragma('vm:entry-point')
  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      print("⚙️ Background task triggered: $task");
      print("inputData: $inputData");

      if (task == taskName) {
        final callId = Random().nextInt(1000000).toString();

        final params = CallKitParams(
          id: callId,
          nameCaller: "Chart Alert",
          handle: "9876543210",
          type: 0, // incoming call
          duration: 45000, // 30 seconds
          textAccept: "YES!",
          textDecline: "NO!",
          extra: {"userId": "scheduled_user"},
          android: AndroidParams(
            isCustomNotification: true,
            isShowLogo: true,
            ringtonePath: 'system_ringtone_default',
            backgroundColor: "#2196F3",
          ),
        );

        await FlutterCallkitIncoming.showCallkitIncoming(params);
      }
      return Future.value(true);
    });
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Request necessary permissions
    await Permission.notification.request();
    await Permission.systemAlertWindow.request();

    // Initialize Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    await scheduleAlarms();

    runApp(const MyApp());
  }

  /// Generates all TimeOfDay instances starting from 10:00 AM to 10:00 PM every 50 mins
  List<TimeOfDay> generateTimes() {
    List<TimeOfDay> times = [];
    int startHour = 10;
    int startMinute = 0;
    while (startHour < 22 || (startHour == 22 && startMinute == 0)) {
      times.add(TimeOfDay(hour: startHour, minute: startMinute));
      startMinute += 50;
      if (startMinute >= 60) {
        startHour += startMinute ~/ 60;
        startMinute = startMinute % 60;
      }
    }
    return times;
  }

  /// Schedule all alarms based on calculated delays
  Future<void> scheduleAlarms() async {
    final times = generateTimes();

    for (int i = 0; i < times.length; i++) {
      final delay = getDelayUntil(times[i]);

      await Workmanager().registerOneOffTask(
        "unique_task_id_$i",
        taskName,
        initialDelay: delay,
        inputData: {"index": "$i"},
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
      );
    }
  }

  /// Calculates the delay duration from now to the target time
  Duration getDelayUntil(TimeOfDay time) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final scheduled =
        target.isBefore(now) ? target.add(const Duration(days: 1)) : target;
    return scheduled.difference(now);
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Homescreen(),
      );
    }
  }
