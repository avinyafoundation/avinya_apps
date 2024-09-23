import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:attendance/data/activity_attendance.dart';
import 'package:attendance/data/organization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:attendance/widgets/date_range_picker.dart';

import 'attendance_summary_excel_report_export.dart';

enum AvinyaTypeId { Empower, IT, CS }

const avinyaTypeId = {
  AvinyaTypeId.Empower: 37,
  AvinyaTypeId.IT: 10,
  AvinyaTypeId.CS: 96
};

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() {
    return _StudentsState();
  }
}

class _StudentsState extends State<Students> {
  List<ActivityAttendance> _fetchedDailyAttendanceSummaryData = [];
  List<ActivityAttendance> _fetchedExcelReportData = [];
  late Future<List<Organization>> _fetchBatchData;
  bool _isFetching = false;
  Organization? _selectedValue;
  AvinyaTypeId _selectedAvinyaTypeId = AvinyaTypeId.Empower;
  List<AvinyaTypeId> filteredAvinyaTypeIdValues = [
    AvinyaTypeId.Empower,
    AvinyaTypeId.IT,
    AvinyaTypeId.CS
  ];

  List<String?> columnNames = [];

  late DataTableSource _data;

  List<ActivityAttendance> filteredStudents = [];

  //calendar specific variables

  @override
  void initState() {
    super.initState();
    _fetchBatchData = _loadBatchData();
    // filteredStudents = _fetchedDailyAttendanceSummaryData;
  }

  Future<List<Organization>> _loadBatchData() async {
    return await fetchOrganizationsByAvinyaType(86);
  }

  void updateExcelState() {
    AttendanceSummaryExcelReportExport(
      fetchedDailyAttendanceSummaryData: _fetchedDailyAttendanceSummaryData,
      columnNames: columnNames,
      updateExcelState: updateExcelState,
      isFetching: _isFetching,
      formattedStartDate: _selectedValue!.organization_metadata[0].value!,
      formattedEndDate: _selectedValue!.organization_metadata[1].value!,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedDailyAttendanceSummaryData, updateSelected);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> ColumnNames = [];

    ColumnNames.add(DataColumn(
        label: Text('Date',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Daily Count',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Daily Attendance Percentage',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Late Count',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Late Attendance Percentage',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Total Count',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    return ColumnNames;
  }

  // void searchStudents(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       filteredStudents = _fetchedDailyAttendanceSummaryData;
  //     } else {
  //       query = query.toLowerCase();

  //       filteredStudents = _fetchedDailyAttendanceSummaryData.where((student) {
  //         final presentCountString =
  //             student.present_count?.toString().toLowerCase() ?? '';
  //         final attendancePercentageString =
  //             student.present_attendance_percentage?.toString().toLowerCase() ??
  //                 '';

  //         return presentCountString.contains(query) ||
  //             attendancePercentageString.contains(query);
  //       }).toList();
  //     }
  //   });
  // }
  void searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = _fetchedDailyAttendanceSummaryData;
      } else {
        filteredStudents = _fetchedDailyAttendanceSummaryData.where((student) {
          print('Searching for: $query');
          print('Present count: ${student.present_count}');
          print(
              'Attendance percentage: ${student.present_attendance_percentage}');

          final lowerCaseQuery = query.toLowerCase();
          final presentCountString = student.present_count?.toString() ?? '';
          final attendancePercentageString =
              student.present_attendance_percentage?.toString() ?? '';

          return presentCountString.contains(lowerCaseQuery) ||
              attendancePercentageString.contains(lowerCaseQuery);
        }).toList();
      }
      _data = MyData(filteredStudents, updateSelected);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Row(
                  children: [
                    Text('Select a Batch :'),
                    SizedBox(
                      width: 10,
                    ),
                    FutureBuilder<List<Organization>>(
                      future: _fetchBatchData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                              color: (Colors.deepPurpleAccent),
                              size: 70,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong...'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No batch found'),
                          );
                        }
                        final batchData = snapshot.data!;
                        return DropdownButton<Organization>(
                            value: _selectedValue,
                            items: batchData.map((Organization batch) {
                              return DropdownMenuItem(
                                  value: batch,
                                  child: Text(batch.name!.name_en ?? ''));
                            }).toList(),
                            onChanged: (Organization? newValue) async {
                              if (newValue == null) {
                                return;
                              }

                              if (newValue.organization_metadata.isEmpty) {
                                return;
                              }

                              if (DateTime.parse(newValue
                                      .organization_metadata[1].value
                                      .toString())
                                  .isBefore(DateTime.parse('2024-03-01'))) {
                                filteredAvinyaTypeIdValues = [
                                  AvinyaTypeId.Empower
                                ];
                              } else {
                                filteredAvinyaTypeIdValues = [
                                  AvinyaTypeId.Empower,
                                  AvinyaTypeId.IT,
                                  AvinyaTypeId.CS
                                ];
                              }

                              setState(() {
                                this._isFetching = true;
                                filteredAvinyaTypeIdValues;
                              });

                              if (filteredAvinyaTypeIdValues
                                  .contains(_selectedAvinyaTypeId)) {
                                _fetchedDailyAttendanceSummaryData =
                                    await getDailyAttendanceSummaryReport(
                                  newValue.id!,
                                  avinyaTypeId[_selectedAvinyaTypeId]!,
                                  newValue.organization_metadata[0].value!,
                                  newValue.organization_metadata[1].value!,
                                );
                              } else {
                                _selectedAvinyaTypeId =
                                    filteredAvinyaTypeIdValues.first;

                                _fetchedDailyAttendanceSummaryData =
                                    await getDailyAttendanceSummaryReport(
                                  newValue.id!,
                                  avinyaTypeId[_selectedAvinyaTypeId]!,
                                  newValue.organization_metadata[0].value!,
                                  newValue.organization_metadata[1].value!,
                                );
                              }

                              setState(() {
                                _selectedValue = newValue;
                                this._isFetching = false;
                                _selectedAvinyaTypeId;
                                _data = MyData(
                                    _fetchedDailyAttendanceSummaryData,
                                    updateSelected);
                                filteredStudents =
                                    _fetchedDailyAttendanceSummaryData;
                              });
                            });
                      },
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Text('Select a Programme :'),
                    SizedBox(
                      width: 10,
                    ),
                    DropdownButton(
                        value: _selectedAvinyaTypeId,
                        items: filteredAvinyaTypeIdValues
                            .map(
                              (typeId) => DropdownMenuItem(
                                value: typeId,
                                child: Text(typeId.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (AvinyaTypeId? value) async {
                          if (value == null) {
                            return;
                          }

                          if (_selectedValue == null ||
                              _selectedValue!.organization_metadata.length ==
                                  0) {
                            return;
                          }

                          setState(() {
                            this._isFetching = true;
                          });

                          _fetchedDailyAttendanceSummaryData =
                              await getDailyAttendanceSummaryReport(
                            _selectedValue!.id!,
                            avinyaTypeId[value]!,
                            _selectedValue!.organization_metadata[0].value!,
                            _selectedValue!.organization_metadata[1].value!,
                          );

                          setState(() {
                            _selectedAvinyaTypeId = value;
                            this._isFetching = false;
                            _data = MyData(_fetchedDailyAttendanceSummaryData,
                                updateSelected);
                            filteredStudents =
                                _fetchedDailyAttendanceSummaryData;
                          });
                        }),
                    SizedBox(
                      width: 30,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Search by Name or NIC',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (query) {
                              searchStudents(query);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.only(right: 20.0),
                        width: 25.0,
                        height: 30.0,
                        child: _selectedValue != null
                            ? AttendanceSummaryExcelReportExport(
                                fetchedDailyAttendanceSummaryData:
                                    filteredStudents,
                                columnNames: columnNames,
                                updateExcelState: updateExcelState,
                                isFetching: _isFetching,
                                formattedStartDate: _selectedValue!
                                    .organization_metadata[0].value!,
                                formattedEndDate: _selectedValue!
                                    .organization_metadata[1].value!,
                              )
                            : SizedBox(),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Wrap(children: [
                if (_isFetching)
                  Container(
                    margin: EdgeInsets.only(top: 180),
                    child: SpinKitCircle(
                      color: (Color.fromARGB(255, 74, 161,
                          70)), // Customize the color of the indicator
                      size: 50, // Customize the size of the indicator
                    ),
                  )
                else if (_fetchedDailyAttendanceSummaryData.length > 0)
                  ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: PaginatedDataTable(
                      showCheckboxColumn: false,
                      source: _data,
                      columns: _buildDataColumns(),
                      // header: const Center(child: Text('Daily Attendance')),
                      columnSpacing: 100,
                      horizontalMargin: 60,
                      rowsPerPage: 20,
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text('No Students Records found'),
                  ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedDailyAttendanceSummaryData, this.updateSelected);

  final List<ActivityAttendance> _fetchedDailyAttendanceSummaryData;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {
    if (index == 0) {
      List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);
      return DataRow(
        cells: cells,
      );
    }

    if (_fetchedDailyAttendanceSummaryData.length > 0 &&
        index <= _fetchedDailyAttendanceSummaryData.length) {
      List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);

      cells[0] = DataCell(Center(
          child: Text(
              _fetchedDailyAttendanceSummaryData[index - 1].sign_in_date!)));

      cells[1] = DataCell(Center(
          child: Text(_fetchedDailyAttendanceSummaryData[index - 1]
              .present_count!
              .toString())));

      cells[2] = DataCell(Center(
          child: Text(_fetchedDailyAttendanceSummaryData[index - 1]
                  .present_attendance_percentage!
                  .toString() +
              " %")));

      cells[3] = DataCell(Center(
          child: Text(_fetchedDailyAttendanceSummaryData[index - 1]
              .late_count!
              .toString())));

      cells[4] = DataCell(Center(
          child: Text(_fetchedDailyAttendanceSummaryData[index - 1]
                  .late_attendance_percentage!
                  .toString() +
              " %")));

      cells[5] = DataCell(Center(
          child: Text(_fetchedDailyAttendanceSummaryData[index - 1]
              .total_count
              .toString())));

      return DataRow(cells: cells);
    }

    return null; // Return null for invalid index values
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    count = _fetchedDailyAttendanceSummaryData.length + 1;
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
