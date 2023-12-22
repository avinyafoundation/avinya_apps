// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:attendance/widgets/weekly_payment_report.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class DateRangePicker extends StatefulWidget {
  DateRangePicker(this.updateDateRange, this.formattedStartDate);
  final Function(DateTime, DateTime) updateDateRange;
  final String formattedStartDate;

  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  void selectDateRange(DateTime startDay, DateTime endDay) {
    _focusedDay = startDay;
    _selectedDay = startDay;
    _rangeStart = startDay;
    _rangeEnd = endDay;
  }

  @override
  void didChangeDependencies() {
    if (_rangeStart != null && _rangeEnd != null) {
      selectDateRange(_rangeStart!, _rangeEnd!);
    } else {
      String dateString = widget.formattedStartDate;
      DateTime dateTime = DateFormat('MMM d, yyyy').parse(dateString);

      _selectedDay = dateTime;
      selectDateRange(dateTime, dateTime);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_rangeStart != null && _rangeEnd != null) {
          widget.updateDateRange(_rangeStart!, _rangeEnd!);
        }
        return true; // Return true to allow the back navigation
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('TableCalendar - Range',style: TextStyle(color: Colors.black)),
            backgroundColor: Color.fromARGB(255, 236, 230, 253),
          ),
          body: TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _rangeStart = null; // Important to clean those
                  _rangeEnd = null;
                  _rangeSelectionMode = RangeSelectionMode.toggledOff;
                });
              }
            },
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _selectedDay = null;
                _focusedDay = focusedDay;
                _rangeStart = start;
                _rangeEnd = end;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepPurpleAccent,
            onPressed: () async {
              if (_rangeStart != null && _rangeEnd != null) {
                widget.updateDateRange(_rangeStart!, _rangeEnd!);
              }
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.save),
          )),
    );
  }
}
