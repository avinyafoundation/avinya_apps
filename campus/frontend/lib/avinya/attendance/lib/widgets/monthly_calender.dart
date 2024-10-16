import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:table_calendar/table_calendar.dart';

class LeaveDatePicker extends StatefulWidget {
  @override
  _LeaveDatePickerState createState() => _LeaveDatePickerState();
}

class _LeaveDatePickerState extends State<LeaveDatePicker> {
  // This will hold the selected dates
  List<DateTime> _selectedDates = [];

  // Date selection function
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      // Toggle selection on/off for the selected day
      if (_selectedDates.contains(day)) {
        _selectedDates.remove(day);
      } else {
        _selectedDates.add(day);
      }
    });
  }

  // Function to format date in a more readable way
  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date); // e.g., October 15, 2024
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Leave Dates"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) {
              // Highlight the days that have been selected
              return _selectedDates.contains(day);
            },
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
          ),
          SizedBox(height: 20),
          // Display the selected leave dates prominently
          Text(
            "Selected Leave Dates",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _selectedDates.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, // Display 2 items per row
                        childAspectRatio: 3, // Height-to-width ratio
                      ),
                      itemCount: _selectedDates.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    _formatDate(_selectedDates[index]),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      "No dates selected yet.",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Save or use the selected dates as needed
          print("Selected Leave Dates: $_selectedDates");
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
