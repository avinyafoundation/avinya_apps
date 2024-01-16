// AttendanceMarker screen class

import 'package:attendance/widgets/attedance_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/person_attendance_report.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({Key? key}) : super(key: key);

  @override
  _AttendanceDashboardScreenState createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  List<Person> _fetchedStudentList = [];
  Organization? _fetchedOrganization;
  var _selectedValue;
  bool _isFetching = true;
  //calendar specific variables
  DateTime? _selectedDay;
  late DateTime today;

  String formattedStartDate = "";
  String formattedEndDate = "";

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    formattedStartDate = DateFormat('MMM d, yyyy').format(today);
    formattedEndDate = DateFormat('MMM d, yyyy').format(today);
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateRange? selectedDateRange;

  void updateDateRange(_rangeStart, _rangeEnd) async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });
      try {
        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          this._fetchedStudentList = _fetchedStudentList;
          refreshState(this._selectedValue);
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        setState(() {
          _isFetching = false; // Set _isFetching to false in case of error
        });
        // Perform error handling, e.g., show an error message
      }
    }
  }

  void onDateRangeChanged(DateRange? newDateRange) {
    // Handle the updated date range here
    print('Selected Date Range: $newDateRange');

    // You can update the state or perform any other actions based on the selected date range
    setState(() {
      selectedDateRange = newDateRange;
    });
  }

  void refreshState(Organization? newValue) async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    _selectedValue = newValue ?? null;

    if (_selectedValue == null) {
      _fetchedStudentList = await fetchOrganizationForAll(parentOrgId!);
      if (_fetchedOrganization != null) {
        _fetchedOrganization!.people = _fetchedStudentList;
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      } else {
        _fetchedOrganization = Organization();
        _fetchedOrganization!.people = _fetchedStudentList;
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      }
      // _fetchedAttendance = await getLateAttendanceReportByParentOrg(
      //     parentOrgId,
      //     activityId,
      //     DateFormat('yyyy-MM-dd')
      //         .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
      //     DateFormat('yyyy-MM-dd')
      //         .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));
    } else {
      _fetchedOrganization = await fetchOrganization(newValue!.id!);
      // _fetchedAttendance = await getLateAttendanceReportByDate(
      //     _fetchedOrganization!.id!,
      //     activityId,
      //     DateFormat('yyyy-MM-dd')
      //         .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
      //     DateFormat('yyyy-MM-dd')
      //         .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));
    }

    String? newSelectedVal;
    if (_selectedValue != null) {
      newSelectedVal = _selectedValue.description;
    }

    setState(() {
      _fetchedOrganization;
      this._isFetching = false;
      // _data = MyData(_fetchedAttendance, newSelectedVal, updateSelected);
    });
  }

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
        onDateRangeChanged: (DateRange? value) {
          print(value);
          var _rangeStart = value!.start;
          var _rangeEnd = value.end;
          updateDateRange(_rangeStart, _rangeEnd);
          // Handle the selected date range here
        },
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
    print(_fetchedStudentList);
    print(_fetchedOrganization);
    print(_selectedValue);
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
        // buildGalleryCard('Students', '100', 'assets/icons/Documents.svg',
        //     Color(0xFFFFA113), 20, '20 GB', 1328),
        // SizedBox(height: 16),
        // buildGalleryCard('Absent', '10', 'assets/icons/media.svg',
        //     Color(0xFFFFA113), 70, '10 GB', 140),
        // SizedBox(height: 16),
        // buildGalleryCard('Late Attendance', '5', 'assets/icons/folder.svg',
        //     Color(0xFFFFA113), 30, '5 GB', 1328),
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // Date Picker
            // ElevatedButton(
            //   onPressed: () => showDateRangePickerDialog(
            //       context: context,
            //       builder: datePickerBuilder,
            //       offset: Offset(310, 180)),
            //   child: const Text("Open the picker"),
            // ),
            ElevatedButton(
              onPressed: () => showDateRangePickerDialog(
                  context: context,
                  builder: datePickerBuilder,
                  offset: Offset(310, 180)),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 16),
                ),
                elevation:
                    MaterialStateProperty.all(20), // increase the elevation
                // Add outline around button
                backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
              child: Text(formattedStartDate + " - " + formattedEndDate),
            ),
            // Class Picker
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: 8.0),
              child: Row(children: <Widget>[
                for (var org in campusAppsPortalInstance
                    .getUserPerson()
                    .organization!
                    .child_organizations)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (org.child_organizations.length > 0)
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, top: 20, bottom: 10),
                            child: Row(children: <Widget>[
                              Text('Select a class:'),
                              SizedBox(width: 10),
                              DropdownButton<Organization>(
                                value: _selectedValue,
                                onChanged: (Organization? newValue) async {
                                  _selectedValue = newValue ?? null;
                                  int? parentOrgId = campusAppsPortalInstance
                                      .getUserPerson()
                                      .organization!
                                      .id;
                                  if (_selectedValue == null) {
                                    // _fetchedOrganization = null;
                                    _fetchedStudentList =
                                        await fetchOrganizationForAll(
                                            parentOrgId!);
                                  } else {
                                    // _fetchedStudentList = <Person>[];
                                    _fetchedOrganization =
                                        await fetchOrganization(newValue!.id!);
                                  }

                                  // if (_selectedValue == null) {
                                  //   _fetchedAttendance =
                                  //       await getLateAttendanceReportByParentOrg(
                                  //           parentOrgId!,
                                  //           activityId,
                                  //           DateFormat('yyyy-MM-dd')
                                  //               .format(DateFormat(
                                  //                       'MMM d, yyyy')
                                  //                   .parse(this
                                  //                       .formattedStartDate)),
                                  //           DateFormat('yyyy-MM-dd')
                                  //               .format(DateFormat(
                                  //                       'MMM d, yyyy')
                                  //                   .parse(this
                                  //                       .formattedEndDate)));
                                  // } else {
                                  //   _fetchedAttendance =
                                  //       await getLateAttendanceReportByDate(
                                  //           _fetchedOrganization!.id!,
                                  //           activityId,
                                  //           DateFormat('yyyy-MM-dd')
                                  //               .format(DateFormat(
                                  //                       'MMM d, yyyy')
                                  //                   .parse(this
                                  //                       .formattedStartDate)),
                                  //           DateFormat('yyyy-MM-dd')
                                  //               .format(DateFormat(
                                  //                       'MMM d, yyyy')
                                  //                   .parse(this
                                  //                       .formattedEndDate)));
                                  // }

                                  if (_selectedValue == null) {
                                    setState(() {
                                      if (_fetchedOrganization != null) {
                                        _fetchedOrganization!.people =
                                            _fetchedStudentList;
                                        _fetchedOrganization!.id = parentOrgId;
                                        _fetchedOrganization!.description =
                                            "Select All";
                                      } else {
                                        _fetchedOrganization = Organization();
                                        _fetchedOrganization!.people =
                                            _fetchedStudentList;
                                        _fetchedOrganization!.id = parentOrgId;
                                        _fetchedOrganization!.description =
                                            "Select All";
                                      }
                                      _fetchedStudentList;
                                      // _data = MyData(
                                      //     _fetchedAttendance,
                                      //     _selectedValue,
                                      //     updateSelected);
                                    });
                                  } else {
                                    setState(() {
                                      _fetchedOrganization;
                                      _fetchedStudentList;
                                      // _data = MyData(
                                      //     _fetchedAttendance,
                                      //     _selectedValue.description,
                                      //     updateSelected);
                                    });
                                  }
                                },
                                items: [
                                  // Add "Select All" option
                                  DropdownMenuItem<Organization>(
                                    value: null,
                                    child: Text("Select All"),
                                  ),
                                  // Add other organization options
                                  ...org.child_organizations
                                      .map((Organization value) {
                                    return DropdownMenuItem<Organization>(
                                      value: value,
                                      child: Text(value.description!),
                                    );
                                  }),
                                ],
                              ),
                            ]),
                          ),
                      ]),
              ]),
            )),
          ]),
          SizedBox(height: 20),

          // Second Row: Gallery Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildGalleryCard('Students', 'assets/icons/Documents.svg',
                  Color(0xFFFFA113), 20, '20 GB', 1328),
              // buildGalleryCard('Absent', '10', 'assets/icons/media.svg',
              //     Color(0xFFFFA113), 70, '10 GB', 140),
              // buildGalleryCard(
              //     'Late Attendance',
              //     '5',
              //     'assets/icons/folder.svg',
              //     Color(0xFFFFA113),
              //     30,
              //     '5 GB',
              //     1328),
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

  // Widget buildGalleryCard(String title, String count) => Card(
  //       elevation: 5,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       child: Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           // Background image
  //           Container(
  //             width: 250, // Set a specific width
  //             height: 150,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10.0),
  //               image: DecorationImage(
  //                 image: AssetImage(
  //                     'assets/images/3301671.jpg'), // Replace with your image path
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(16.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white, // Text color
  //                   ),
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   count,
  //                   style: TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white, // Text color
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  Widget buildGalleryCard(String title, String svgSrc, Color color,
          int percentage, String totalStorage, int numOfFiles) =>
      Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3E),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0 * 0.75),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFA113).withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SvgPicture.asset(
                    svgSrc!,
                    colorFilter: ColorFilter.mode(
                        color ?? Colors.black, BlendMode.srcIn),
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.white54)
              ],
            ),
            Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // ProgressLine(
            //   color: color,
            //   percentage: percentage,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${numOfFiles} Files",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white70),
                ),
                Text(
                  totalStorage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                ),
              ],
            )
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

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = const Color(0xFF2697FF),
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
