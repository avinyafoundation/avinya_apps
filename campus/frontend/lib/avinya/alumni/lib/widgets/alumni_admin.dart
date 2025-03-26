import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:gallery/avinya/alumni/lib/data/organization.dart';
import 'package:gallery/data/person.dart';
import 'package:gallery/avinya/enrollment/lib/screens/student_create_screen.dart';

class AlumniAdmin extends StatefulWidget {
  const AlumniAdmin({super.key});

  @override
  State<AlumniAdmin> createState() => _AlumniAdminState();
}

class _AlumniAdminState extends State<AlumniAdmin> {
  List<Person> _fetchedAlumniListData = [];
  List<Person> _filteredAlumniStudents = [];
  late Future<List<Organization>> _fetchBranchData;
  Organization? _selectedValue;
  bool _isFetching = false;
  List<String?> columnNames = [];
  late DataTableSource _data;

  @override
  void initState() {
    super.initState();
    _fetchBranchData = _loadBranchData();
  }

  Future<List<Organization>> _loadBranchData() async {
    return await fetchOrganizationsByAvinyaType(2);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(_fetchedAlumniListData, updateSelected, context);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> ColumnNames = [];

    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 200,
        child: Center(
            child: Text('Name',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));
    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 300,
        child: Center(
            child: Text('Email',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));
    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 170,
        child: Center(
            child: Text('Phone',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));
    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 90,
        child: Center(
            child: Text('Status',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));
    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 150,
        child: Center(
            child: Text('Updated by',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));
    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 150,
        child: Center(
            child: Text('Last Updated',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));
    ColumnNames.add(DataColumn(
      label: SizedBox(
        width: 150,
        child: Center(
            child: Text('Actions',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
      ),
    ));

    return ColumnNames;
  }

  void searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAlumniStudents = _fetchedAlumniListData;
      } else {
        final lowerCaseQuery = query.toLowerCase();

        _filteredAlumniStudents = _fetchedAlumniListData.where((student) {
          print('Searching for: $query');
          print('Present count: ${student.preferred_name}');

          // Ensure preferred_name is not null and trimmed
          final presentCountString =
              student.preferred_name?.trim().toLowerCase() ?? '';

          // Check for matching query
          return presentCountString.contains(lowerCaseQuery);
        }).toList();
      }

      _data = MyData(_filteredAlumniStudents, updateSelected, context);
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
                    Text('Select a Branch :'),
                    SizedBox(
                      width: 10,
                    ),
                    FutureBuilder<List<Organization>>(
                      future: _fetchBranchData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SpinKitCircle(
                              color: (Colors.blueGrey[400]),
                              size: 70,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong...'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No branch found'),
                          );
                        }
                        final branchData = snapshot.data!;
                        return DropdownButton<Organization>(
                            value: _selectedValue,
                            items: branchData.map((Organization branch) {
                              return DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch.name!.name_en ?? ''));
                            }).toList(),
                            onChanged: (Organization? newValue) async {
                              if (newValue == null) {
                                return;
                              }

                              setState(() {
                                this._isFetching = true;
                              });

                              _fetchedAlumniListData =
                                  await fetchAlumniPersonList(newValue.id!);

                              setState(() {
                                _selectedValue = newValue;
                                this._isFetching = false;
                                _data = MyData(_fetchedAlumniListData,
                                    updateSelected, context);
                                _fetchedAlumniListData;
                                _filteredAlumniStudents =
                                    _fetchedAlumniListData;
                              });
                            });
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
                              labelText: 'Search by Name',
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
                      color: (Colors.blueGrey[
                          400]), // Customize the color of the indicator
                      size: 50, // Customize the size of the indicator
                    ),
                  )
                else if (_fetchedAlumniListData.length > 0)
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
                      columnSpacing:
                          30, // Reduce spacing to match header & row widths
                      horizontalMargin:
                          20, // Reduce margin to keep things aligned
                      rowsPerPage: 20,
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text('No Alumni Students Records found'),
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
  MyData(this._fetchedAlumniListData, this.updateSelected, this.context);

  final List<Person> _fetchedAlumniListData;
  final Function(int, bool, List<bool>) updateSelected;

  @override
  DataRow? getRow(int index) {
    if (index == 0) {
      List<DataCell> cells = List<DataCell>.filled(7, DataCell.empty);
      return DataRow(
        cells: cells,
      );
    }

    if (_fetchedAlumniListData.length > 0 &&
        index <= _fetchedAlumniListData.length) {
      List<DataCell> cells = List<DataCell>.filled(7, DataCell.empty);

      cells[0] = DataCell(SizedBox(
        width: 200,
        child: Center(
            child: Text(
                _fetchedAlumniListData[index - 1].preferred_name ?? "N/A")),
      ));

      cells[1] = DataCell(SizedBox(
        width: 300,
        child: Center(
            child: Text(
                _fetchedAlumniListData[index - 1].email?.toString() ?? "N/A")),
      ));

      cells[2] = DataCell(SizedBox(
        width: 170,
        child: Center(
            child: Text(
                _fetchedAlumniListData[index - 1].phone?.toString() ?? "N/A")),
      ));

      cells[3] = DataCell(SizedBox(
        width: 90,
        child: Center(
            child: Text(
                _fetchedAlumniListData[index - 1].alumni?.status ?? "N/A")),
      ));

      cells[4] = DataCell(SizedBox(
        width: 150,
        child: Center(
            child: Text(
                _fetchedAlumniListData[index - 1].alumni?.updated_by ?? "N/A")),
      ));

      cells[5] = DataCell(SizedBox(
        width: 150,
        child: Center(
            child: Text(_fetchedAlumniListData[index - 1]
                    .alumni
                    ?.updated
                    ?.substring(0, 11) ??
                "N/A")),
      ));

      cells[6] = DataCell(SizedBox(
        width: 150,
        child: Center(
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.contain,
            child: Container(
              alignment: Alignment.center,
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
                  'Edit',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[400],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ));

      return DataRow(cells: cells);
      // return DataRow(
      //   cells: cells,
      //   onSelectChanged: (selected) {
      //     if (selected != null && selected) {
      //       // Navigate to the new screen with the id
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => StudentUpdateScreen(
      //             id: _fetchedPersonData[index - 1].id!, // Pass the ID
      //           ),
      //         ),
      //       );
      //     }
      //   },
      // );
    }

    return null; // Return null for invalid index values
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    int count = 0;
    count = _fetchedAlumniListData.length + 1;
    return count;
  }

  @override
  int get selectedRowCount => 0;
}
