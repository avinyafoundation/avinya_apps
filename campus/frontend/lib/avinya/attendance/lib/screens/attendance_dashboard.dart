// AttendanceMarker screen class

import 'package:attendance/widgets/attedance_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import '../widgets/person_attendance_report.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({Key? key}) : super(key: key);

  @override
  _AttendanceDashboardScreenState createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateRange? selectedDateRange;

  Widget datePickerBuilder(
          BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
          [bool doubleMonth = true]) =>
      DateRangePickerWidget(
        doubleMonth: doubleMonth,
        maximumDateRangeLength: 10,
        quickDateRanges: [
          QuickDateRange(dateRange: null, label: "Remove date range"),
          QuickDateRange(
            label: 'Last 3 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 3)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 7 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 7)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 30 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 90 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 90)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 180 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 180)),
              DateTime.now(),
            ),
          ),
        ],
        minimumDateRangeLength: 3,
        initialDateRange: selectedDateRange,
        disabledDates: [DateTime(2023, 11, 20)],
        initialDisplayedDate:
            selectedDateRange?.start ?? DateTime(2023, 11, 20),
        onDateRangeChanged: onDateRangeChanged,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Attendance Dashboard'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // If the screen width is less than 600, switch to a single column layout
            if (constraints.maxWidth < 600) {
              return buildSingleColumnLayout();
            } else {
              return buildThreeColumnLayout();
            }
          },
        ),
      );
  Widget buildSingleColumnLayout() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        // Date Picker
        // TextButton(
        //   onPressed: () => showDateRangePickerDialog(
        //       context: context,
        //       builder: datePickerBuilder,
        //       offset: Offset(100, 100)),
        //   child: const Text("Open the picker"),
        // ),
        const Text("The date range picker widget:"),
        const SizedBox(height: 20),
        SizedBox(
          width: 260,
          child: DateRangePickerWidget(
              maximumDateRangeLength: 10,
              minimumDateRangeLength: 3,
              disabledDates: [DateTime(2023, 11, 20)],
              initialDisplayedDate: DateTime(2023, 11, 20),
              onDateRangeChanged: print,
              doubleMonth: false),
        ),
        SizedBox(height: 16),

        // Class Picker
        ElevatedButton(
          onPressed: () {
            // Add your class picker logic here
          },
          child: Text('Pick Class'),
        ),
        SizedBox(height: 20),

        // Gallery Cards
        buildGalleryCard('Students', '100'),
        SizedBox(height: 16),
        buildGalleryCard('Absent', '10'),
        SizedBox(height: 16),
        buildGalleryCard('Late Attendance', '5'),
        SizedBox(height: 20),

        // Tables
        buildTable('Table 1', [
          {'Name': 'Student A', 'Status': 'Present'},
          {'Name': 'Student B', 'Status': 'Absent'},
          // Add more rows as needed
        ]),
        SizedBox(height: 16),
        buildTable('Table 2', [
          {'Name': 'Student C', 'Status': 'Present'},
          {'Name': 'Student D', 'Status': 'Absent'},
          // Add more rows as needed
        ]),
        SizedBox(height: 16),
        buildTable('Table 3', [
          {'Name': 'Student E', 'Status': 'Present'},
          {'Name': 'Student F', 'Status': 'Absent'},
          // Add more rows as needed
        ]),
      ],
    );
  }

  Widget buildThreeColumnLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Row: Date Picker and Class Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date Picker
              TextButton(
                onPressed: () => showDateRangePickerDialog(
                    context: context,
                    builder: datePickerBuilder,
                    offset: Offset(310, 180)),
                child: const Text("Open the picker"),
              ),
              // Class Picker
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your class picker logic here
                    },
                    child: Text('Pick Class'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Second Row: Gallery Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildGalleryCard('Students', '100'),
              buildGalleryCard('Absent', '10'),
              buildGalleryCard('Late Attendance', '5'),
            ],
          ),
          SizedBox(height: 20),

          // Third Row: Tables
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTable('Table 1', [
                {'Name': 'Student A', 'Status': 'Present'},
                {'Name': 'Student B', 'Status': 'Absent'},
                // Add more rows as needed
              ]),
              buildTable('Table 2', [
                {'Name': 'Student C', 'Status': 'Present'},
                {'Name': 'Student D', 'Status': 'Absent'},
                // Add more rows as needed
              ]),
              buildTable('Table 3', [
                {'Name': 'Student E', 'Status': 'Present'},
                {'Name': 'Student F', 'Status': 'Absent'},
                // Add more rows as needed
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGalleryCard(String title, String count) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            Container(
              width: 250, // Set a specific width
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/3301671.jpg'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget buildTable(String title, List<Map<String, String>> data) => Expanded(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: data.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(row['Name']!)),
                        DataCell(Text(row['Status']!)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      );
}
