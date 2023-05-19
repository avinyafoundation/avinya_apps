// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:attendance/widgets/weekly_payment_report.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class WeekPicker extends StatefulWidget {
  WeekPicker(this.updateDateRange, this.formattedStartDate);
  final Function(DateTime, DateTime) updateDateRange;
  final String formattedStartDate;

  @override
  _WeekPickerState createState() => _WeekPickerState();
}

class _WeekPickerState extends State<WeekPicker> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  void selectWeek(DateTime selectedDay) {
    // Calculate the start of the week (excluding weekends) based on the selected day
    DateTime startOfWeek =
        selectedDay.subtract(Duration(days: selectedDay.weekday - 1));
    while (startOfWeek.weekday > DateTime.friday) {
      startOfWeek = startOfWeek.subtract(Duration(days: 1));
    }

    // Calculate the end of the week (excluding weekends) based on the start of the week
    DateTime endOfWeek = startOfWeek.add(Duration(days: 4));

    // Update the variables to select the week
    _focusedDay = startOfWeek;
    _selectedDay = selectedDay;
    _rangeStart = startOfWeek;
    _rangeEnd = endOfWeek;
  }

  @override
  void didChangeDependencies() {
    if (_selectedDay != null) {
      selectWeek(_selectedDay!);
    } else {
      String dateString = widget.formattedStartDate;
      DateTime dateTime = DateFormat('MMM d, yyyy').parse(dateString);

      _selectedDay = dateTime;
      selectWeek(_selectedDay!);
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
            title: Text('TableCalendar - Range'),
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

                  // Update the variables to select the week (excluding weekends)
                  selectWeek(selectedDay);
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

                // Update the variables to select the week (excluding weekends)
                selectWeek(start!);
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
