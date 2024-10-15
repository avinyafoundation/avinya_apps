import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:attendance/data/organization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';
import 'package:gallery/avinya/enrollment/lib/screens/student_create_screen.dart';
import 'package:gallery/avinya/enrollment/lib/screens/student_update_screen.dart';
import 'person_data_excel_report.dart';

enum AvinyaTypeId { Empower, IT, CS, FutureEnrollees }

const avinyaTypeId = {
  AvinyaTypeId.Empower: 37,
  AvinyaTypeId.IT: 10,
  AvinyaTypeId.CS: 96,
  AvinyaTypeId.FutureEnrollees: 103,
};

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() {
    return _StudentsState();
  }
}

class _StudentsState extends State<Students> {
  List<Person> _fetchedPersonData = [];
  List<Person> _fetchedExcelReportData = [];
  late Future<List<Organization>> _fetchBatchData;
  bool _isFetching = false;
  Organization? _selectedValue;
  AvinyaTypeId _selectedAvinyaTypeId = AvinyaTypeId.Empower;
  List<AvinyaTypeId> filteredAvinyaTypeIdValues = [
    AvinyaTypeId.Empower,
    AvinyaTypeId.IT,
    AvinyaTypeId.CS,
    AvinyaTypeId.FutureEnrollees
  ];

  List<String?> columnNames = [];

  late DataTableSource _data;

  List<Person> filteredStudents = [];

  //calendar specific variables

  @override
  void initState() {
    super.initState();
    _fetchBatchData = _loadBatchData();
    // filteredStudents = _fetchedPersonData;
  }

  Future<List<Organization>> _loadBatchData() async {
    return await fetchOrganizationsByAvinyaType(86);
  }

  Future<List<AvinyaTypeId>> fetchAvinyaTypes(dynamic newValue) async {
    List<AvinyaTypeId> filteredAvinyaTypeIdValues;

    // Check if newValue is not null and contains valid metadata
    if (newValue != null &&
        newValue.organization_metadata != null &&
        newValue.organization_metadata.isNotEmpty) {
      // Parse the metadata value to a DateTime and perform date range checks
      DateTime metadataDate =
          DateTime.parse(newValue.organization_metadata[1].value.toString());

      if (newValue.organization_metadata[1].value.toString() == '2024-07-26') {
        filteredAvinyaTypeIdValues = [
          AvinyaTypeId.Empower,
          AvinyaTypeId.IT,
          AvinyaTypeId.CS,
          AvinyaTypeId.FutureEnrollees
        ];
      } else {
        filteredAvinyaTypeIdValues = [
          AvinyaTypeId.Empower,
          AvinyaTypeId.FutureEnrollees
        ];
      }
    } else {
      // Default value if newValue is null or invalid
      filteredAvinyaTypeIdValues = [
        AvinyaTypeId.Empower,
        AvinyaTypeId.FutureEnrollees
      ];
    }

    return filteredAvinyaTypeIdValues;
  }

  void updateExcelState() {
    PersonDataExcelReport(
        fetchedPersonData: _fetchedPersonData,
        columnNames: columnNames,
        updateExcelState: updateExcelState,
        isFetching: _isFetching,
        selectedAvinyaTypeId: _selectedAvinyaTypeId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedPersonData, updateSelected, context);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> ColumnNames = [];

    ColumnNames.add(DataColumn(
        label: Text('Name',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('NIC Number',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Birth Date',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Digital ID',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Gender',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));
    ColumnNames.add(DataColumn(
        label: Text('Organization',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))));

    return ColumnNames;
  }

  void searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = _fetchedPersonData;
      } else {
        final lowerCaseQuery = query.toLowerCase();

        filteredStudents = _fetchedPersonData.where((student) {
          print('Searching for: $query');
          print('Present count: ${student.preferred_name}');
          print('NIC number: ${student.nic_no}');

          // Ensure preferred_name is not null and trimmed
          final presentCountString =
              student.preferred_name?.trim().toLowerCase() ?? '';
          final attendancePercentageString = student.nic_no?.toString() ?? '';

          // Check for matching query
          return presentCountString.contains(lowerCaseQuery) ||
              attendancePercentageString.contains(lowerCaseQuery);
        }).toList();
      }

      _data = MyData(filteredStudents, updateSelected, context);
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
                              color: (Color.fromARGB(255, 74, 161, 70)),
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
                                  AvinyaTypeId.Empower,
                                  AvinyaTypeId.FutureEnrollees
                                ];
                              } else {
                                filteredAvinyaTypeIdValues = [
                                  AvinyaTypeId.Empower,
                                  AvinyaTypeId.IT,
                                  AvinyaTypeId.CS,
                                  AvinyaTypeId.FutureEnrollees
                                ];
                              }

                              setState(() {
                                this._isFetching = true;
                                filteredAvinyaTypeIdValues;
                              });

                              if (filteredAvinyaTypeIdValues
                                  .contains(_selectedAvinyaTypeId)) {
                                _fetchedPersonData = await fetchPersons(
                                    newValue.id!,
                                    avinyaTypeId[_selectedAvinyaTypeId]!);
                              } else {
                                _selectedAvinyaTypeId =
                                    filteredAvinyaTypeIdValues.first;

                                _fetchedPersonData = await fetchPersons(
                                    newValue.id!,
                                    avinyaTypeId[_selectedAvinyaTypeId]!);
                              }

                              setState(() {
                                _selectedValue = newValue;
                                this._isFetching = false;
                                _selectedAvinyaTypeId;
                                _data = MyData(_fetchedPersonData,
                                    updateSelected, context);
                                filteredStudents = _fetchedPersonData;
                              });
                            });
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Select a Programme :'),
                    SizedBox(
                      width: 10,
                    ),
                    FutureBuilder<List<AvinyaTypeId>>(
                      future: fetchAvinyaTypes(_selectedValue),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                              color: Colors.deepPurpleAccent,
                              size: 70,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong...'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No Avinya Type found'),
                          );
                        }

                        final avinyaTypeData = snapshot.data!;
                        return DropdownButton<AvinyaTypeId>(
                          value: _selectedAvinyaTypeId,
                          items: avinyaTypeData.map((typeId) {
                            return DropdownMenuItem<AvinyaTypeId>(
                              value: typeId,
                              child: Text(
                                typeId.name == 'FutureEnrollees'
                                    ? 'FUTURE ENROLLEES'
                                    : typeId.name.toUpperCase(),
                              ),
                            );
                          }).toList(),
                          onChanged: (AvinyaTypeId? value) async {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedAvinyaTypeId = value;
                              _isFetching = true;
                            });

                            if (avinyaTypeId[value] == 103 ||
                                _selectedValue == null) {
                              _fetchedPersonData =
                                  await fetchPersons(-1, avinyaTypeId[value]!);
                            } else {
                              _fetchedPersonData = await fetchPersons(
                                  _selectedValue!.id!, avinyaTypeId[value]!);
                            }

                            setState(() {
                              _isFetching = false;
                              _data = MyData(
                                  _fetchedPersonData, updateSelected, context);
                              filteredStudents = _fetchedPersonData;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 250,
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
                    FittedBox(
                      alignment: Alignment.topLeft,
                      fit: BoxFit.contain,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.only(right: 20.0),
                        width: 100.0,
                        height: 30.0,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentCreateScreen(
                                  id: null, // Since it's for creating a new student, no ID is passed
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Create New',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    FittedBox(
                      alignment: Alignment.topLeft,
                      fit: BoxFit.contain,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(right: 10.0),
                          width: 140.0,
                          height: 50.0,
                          child: PersonDataExcelReport(
                              fetchedPersonData: filteredStudents,
                              columnNames: columnNames,
                              updateExcelState: updateExcelState,
                              isFetching: _isFetching,
                              selectedAvinyaTypeId: _selectedAvinyaTypeId)),
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
                else if (_fetchedPersonData.length > 0)
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
  final BuildContext context;
  MyData(this._fetchedPersonData, this.updateSelected, this.context);

  final List<Person> _fetchedPersonData;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {
    if (index == 0) {
      List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);
      return DataRow(
        cells: cells,
      );
    }

    if (_fetchedPersonData.length > 0 && index <= _fetchedPersonData.length) {
      List<DataCell> cells = List<DataCell>.filled(6, DataCell.empty);

      cells[0] = DataCell(Center(
          child: Text(_fetchedPersonData[index - 1].preferred_name ?? "N/A")));

      cells[1] = DataCell(Center(
          child:
              Text(_fetchedPersonData[index - 1].nic_no?.toString() ?? "N/A")));

      cells[2] = DataCell(Center(
          child: Text(_fetchedPersonData[index - 1].date_of_birth?.toString() ??
              "N/A")));

      cells[3] = DataCell(Center(
          child: Text(
              _fetchedPersonData[index - 1].digital_id?.toString() ?? "N/A")));

      cells[4] = DataCell(
          Center(child: Text(_fetchedPersonData[index - 1].sex ?? "N/A")));

      cells[5] = DataCell(Center(
        child: Text(
          _fetchedPersonData[index - 1].organization?.avinya_type?.name ??
              "N/A",
        ),
      ));

      // return DataRow(cells: cells);
      return DataRow(
        cells: cells,
        onSelectChanged: (selected) {
          if (selected != null && selected) {
            // Navigate to the new screen with the id
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentUpdateScreen(
                  id: _fetchedPersonData[index - 1].id!, // Pass the ID
                ),
              ),
            );
          }
        },
      );
    }

    return null; // Return null for invalid index values
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    count = _fetchedPersonData.length + 1;
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
