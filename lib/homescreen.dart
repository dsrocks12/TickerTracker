import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticker/db_services/database.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int selectedWeek = 1;
  String selectedDay = 'Mon';
  double percentage = 0.0;

  final DatabaseService _databaseService = DatabaseService();
  final Map<int, Map<String, Map<String, bool>>> schedule = {};
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  final List<String> hours = [
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

  @override
  void initState() {
    super.initState();
    _loadAllWeeks();
  }

  void showError(String errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _loadAllWeeks() async {
    try {
      for (int i = 1; i <= 4; i++) {
        final weekData = await _databaseService.getWeekSchedule(i);
        schedule[i] = weekData;
      }
      _updatePercentage();
      setState(() {});
    } catch (e) {
      showError("Error loading weeks: $e");
    }
  }

  void _toggleTick(int week, String day, String hour) async {
    try {
      if (!schedule.containsKey(week)) {
        schedule[week] = {};
      }
      if (!schedule[week]!.containsKey(day)) {
        schedule[week]![day] = {};
      }
      if (!schedule[week]![day]!.containsKey(hour)) {
        schedule[week]![day]![hour] = false;
      }

      final current = schedule[week]![day]![hour]!;
      final newValue = !current;

      setState(() {
        schedule[week]![day]![hour] = newValue;
      });

      await _databaseService.updateHour(week, day, hour, newValue);
      _updatePercentage();
    } catch (e) {
      showError("Toggle error: $e");
    }
  }

  void _updatePercentage() {
    final dayData = schedule[selectedWeek]?[selectedDay] ?? {};
    int total = dayData.length;
    int completed = dayData.values.where((v) => v).length;

    setState(() {
      percentage = total == 0 ? 0.0 : (completed / total) * 100;
    });
  }

  String _getDateForSelectedDay() {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

      while (firstDayOfMonth.weekday != DateTime.monday) {
        firstDayOfMonth = firstDayOfMonth.add(const Duration(days: 1));
      }

      final int dayOffset = days.indexOf(selectedDay);
      final int weekOffset = (selectedWeek - 1) * 7;
      final targetDate =
          firstDayOfMonth.add(Duration(days: dayOffset + weekOffset));

      return DateFormat('EEE, MMM d').format(targetDate);
    } catch (e) {
      showError("Date formatting error: $e");
      return "Invalid Date";
    }
  }

  Widget buildDayTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          final isSelected = day == selectedDay;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDay = day;
                });
                _updatePercentage();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black26),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTimeGridForSelectedDay() {
    final dayData = schedule[selectedWeek]?[selectedDay] ?? {};
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hours.map((hour) {
        final isChecked = dayData[hour] ?? false;
        return GestureDetector(
          onTap: () => _toggleTick(selectedWeek, selectedDay, hour),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isChecked ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hour,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget weekButton(int weekNumber) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWeek = weekNumber;
        });
        _updatePercentage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: selectedWeek == weekNumber
              ? Colors.greenAccent.shade200
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          "Week $weekNumber",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white70],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hii,", style: TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "DS",
                    style: TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: Text(
                      DateFormat.MMMM().format(DateTime.now()),
                      style: const TextStyle(fontSize: 40),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Let the Work begin!!",
                  style: TextStyle(fontSize: 18, color: Colors.black54)),
              const SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    weekButton(1),
                    const SizedBox(width: 10),
                    weekButton(2),
                    const SizedBox(width: 10),
                    weekButton(3),
                    const SizedBox(width: 10),
                    weekButton(4),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              buildDayTabs(),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getDateForSelectedDay(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: buildTimeGridForSelectedDay(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
