import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentMonth => DateFormat.MMMM().format(DateTime.now());

  final List<String> defaultDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> defaultHours = [
    "10:00 AM",
    "10:50 AM",
    "11:40 AM",
    "12:30 PM",
    "1:20 PM",
    "2:10 PM",
    "3:00 PM",
    "3:50 PM",
    "4:40 PM",
    "5:30 PM",
    "6:20 PM",
    "7:10 PM",
    "8:00 PM",
    "8:50 PM",
    "9:40 PM",
  ];

  Future<Map<String, Map<String, bool>>> getWeekSchedule(int week) async {
    final docRef = _firestore.collection(currentMonth).doc('week_$week');
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      Map<String, Map<String, bool>> parsed = {};

      for (var day in defaultDays) {
        final hoursMap = Map<String, bool>.from(
            data[day] != null ? Map<String, dynamic>.from(data[day]) : {});
        parsed[day] = {
          for (var hour in defaultHours) hour: hoursMap[hour] ?? false,
        };
      }

      return parsed;
    } else {
      // Initialize and save a blank schedule if it doesn't exist
      Map<String, Map<String, bool>> defaultMap = {
        for (var day in defaultDays)
          day: {for (var hour in defaultHours) hour: false}
      };
      await docRef.set(defaultMap);
      return defaultMap;
    }
  }

  Future<void> updateHour(int week, String day, String hour, bool value) async {
    final docRef = _firestore.collection(currentMonth).doc('week_$week');
    await docRef.set({
      day: {hour: value}
    }, SetOptions(merge: true));
  }
}
