import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveDatePicker extends StatefulWidget {
  final int? organizationId;

  LeaveDatePicker({this.organizationId});

  @override
  _LeaveDatePickerState createState() => _LeaveDatePickerState();
}

class _LeaveDatePickerState extends State<LeaveDatePicker> {
  List<DateTime> _selectedDates = []; // Store selected dates
  int? _year;
  int? _month;
  bool _isUpdate = false; // Track if we are in update mode

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _month = DateTime.now().month;
    _fetchLeaveDates(); // Check if leave dates already exist for the current month
  }

  Future<void> _fetchLeaveDates() async {
    List<DateTime> fetchedDates = await getLeaveDatesForMonth(
      _year!,
      _month!,
      widget.organizationId,
    );

    setState(() {
      _selectedDates = fetchedDates;
      _isUpdate = fetchedDates.isNotEmpty; // Set update mode if dates exist
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      // Toggle date selection
      if (_selectedDates.any((d) => _isSameDay(d, day))) {
        _selectedDates.removeWhere((d) => _isSameDay(d, day));
      } else {
        _selectedDates.add(day);
      }
    });
  }

  Future<void> _saveOrUpdateLeaveDates() async {
    if (_selectedDates.isEmpty) {
      print("No dates selected.");
      return;
    }

    int totalDaysInMonth = DateTime(_year!, _month! + 1, 0).day;
    List<int> leaveDatesList = _selectedDates.map((date) => date.day).toList();

    try {
      if (_isUpdate) {
        // Update leave dates if they exist
        await updateMonthlyLeaveDates(
          year: _year!,
          month: _month!,
          organizationId: widget.organizationId ?? 2,
          totalDaysInMonth: totalDaysInMonth,
          leaveDatesList: leaveDatesList,
        );
        print("Leave dates updated: $_selectedDates");
      } else {
        // Create new leave dates if they don't exist
        await createMonthlyLeaveDates(
          year: _year!,
          month: _month!,
          organizationId: widget.organizationId ?? 2,
          totalDaysInMonth: totalDaysInMonth,
          leaveDatesList: leaveDatesList,
        );
        print("New leave dates created: $_selectedDates");
      }
    } catch (e) {
      print("Error saving leave dates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Leave Dates"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) =>
                _selectedDates.any((d) => _isSameDay(d, day)),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            onPageChanged: (focusedDay) {
              setState(() {
                _year = focusedDay.year;
                _month = focusedDay.month;
                _fetchLeaveDates(); // Fetch leave dates for the selected month
              });
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Selected Leave Days",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 10,
              children: _selectedDates
                  .map((date) => Chip(
                        label: Text(
                          date.day.toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveOrUpdateLeaveDates,
            child: Text(_isUpdate ? "Update Leave Dates" : "Save Leave Dates"),
          ),
        ],
      ),
    );
  }

  // Helper function to compare dates without time
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
