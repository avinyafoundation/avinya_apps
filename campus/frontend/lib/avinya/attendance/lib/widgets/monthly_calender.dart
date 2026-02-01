import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveDatePicker extends StatefulWidget {
  final int? organizationId;
  final int? batchId;
  final int year;
  final int month;
  final DateTime selectedDay;
  final double monthlyPaymentAmount;

  LeaveDatePicker({
    this.organizationId,
    this.batchId,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.monthlyPaymentAmount
  });

  @override
  _LeaveDatePickerState createState() => _LeaveDatePickerState();
}

class _LeaveDatePickerState extends State<LeaveDatePicker> {
  List<LeaveDate> _selectedDates = [];
  late DateTime _focusedDay;
  late int _year;
  late int _month;
  bool _isUpdate = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.year, widget.month, widget.selectedDay.day);
    _year = widget.year;
    _month = widget.month;
    _fetchLeaveDates(_year, _month);
  }

  Future<void> _fetchLeaveDates(int year, int month) async {
    try {
      List<LeaveDate> fetchedDates = await getLeaveDatesForMonth(
          year, month, widget.organizationId, widget.batchId!);

      setState(() {
        _selectedDates = fetchedDates;
        _isUpdate = fetchedDates.isNotEmpty;
      });
    } catch (e) {
      print("Error fetching leave dates: $e");
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      if (_selectedDates.any((d) => _isSameDay(d.date, day))) {
        // Remove the selected day if it already exists
        _selectedDates.removeWhere((d) => _isSameDay(d.date, day));
      } else {
        // Add the selected day with default values for other fields
        _selectedDates.add(
          LeaveDate(
            id: _selectedDates.length + 1,
            date: day,
            dailyAmount: 0.0, // Default value; adjust if needed
            created: DateTime.now(),
            updated: DateTime.now(),
            organizationId: 0, // Set a proper organization ID if needed
            batch_id: 0,
          ),
        );
      }
      _focusedDay = focusedDay;
    });
  }

  Future<void> _saveOrUpdateLeaveDates() async {
    if (_selectedDates.isEmpty) {
      print("No dates selected.");
      return;
    }

    int totalDaysInMonth = DateTime(_year, _month + 1, 0).day;
    List<int> leaveDatesList =
        _selectedDates.map((leaveDate) => leaveDate.date.day).toList();

    try {
      if (_isUpdate) {
        int id = _selectedDates.first.id;
        await updateMonthlyLeaveDates(
          id: id,
          year: _year,
          month: _month,
          organizationId: widget.organizationId ?? 2,
          batchId: widget.batchId!,
          totalDaysInMonth: totalDaysInMonth,
          monthlyPaymentAmount: widget.monthlyPaymentAmount,
          leaveDatesList: leaveDatesList,
        );
        print("Leave dates updated: $_selectedDates");
      } else {
        await createMonthlyLeaveDates(
          year: _year,
          month: _month,
          organizationId: widget.organizationId ?? 2,
          batchId: widget.batchId!,
          totalDaysInMonth: totalDaysInMonth,
          monthlyPaymentAmount: widget.monthlyPaymentAmount,
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
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDates.any((d) => _isSameDay(d.date, day)),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _year = focusedDay.year;
                _month = focusedDay.month;
              });
              _fetchLeaveDates(_year, _month);
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
                  .map((leaveDate) => Chip(
                        label: Text(
                          leaveDate.date.day.toString(),
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
            child:
                Text(_isUpdate ? "Update Leave Dates" : "Save Leave Dates"),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
