// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/data/campus_apps_portal.dart';
// import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/data/person.dart';
import 'package:intl/intl.dart';

class DailyAttendanceReport extends StatefulWidget {
  const DailyAttendanceReport({super.key});

  @override
  State<DailyAttendanceReport> createState() => _DailyAttendanceReportState();
}

class _RestorableAttendanceSelections extends RestorableProperty<Set<int>> {
  Set<int> _attendanceSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _attendanceSelections.contains(index);

  /// Takes a list of [_Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setAttendanceSelections(List<ActivityAttendance> attendanceList) {
    final updatedSet = <int>{};
    for (var i = 0; i < attendanceList.length; i += 1) {
      var attendance = attendanceList[i];
      if (attendance.selected!) {
        updatedSet.add(i);
      }
    }
    _attendanceSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _attendanceSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _attendanceSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _attendanceSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _attendanceSelections = value;
  }

  @override
  Object toPrimitives() => _attendanceSelections.toList();
}

class _DailyAttendanceReportState extends State<DailyAttendanceReport>
    with RestorationMixin {
  final _RestorableAttendanceSelections _dessertSelections =
      _RestorableAttendanceSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);

  List<ActivityAttendance> _fetchedAttendance = [];
  _AttendanceDataSource? _attendanceDataSource;
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;
  var afterSchoolActivityId = 0;
  Organization? _fetchedOrganization;
  List<ActivityAttendance> _fetchedAttendanceAfterSchool = [];

  @override
  void initState() {
    super.initState();
    if (campusAppsPortalInstance.isTeacher) {
      activityId = campusAppsPortalInstance.activityIds['homeroom']!;
      afterSchoolActivityId =
          campusAppsPortalInstance.activityIds['after-school']!;
    } else if (campusAppsPortalInstance.isSecurity)
      activityId = campusAppsPortalInstance.activityIds['arrival']!;
  }

  @override
  String get restorationId => 'data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    // _attendanceDataSource ??= _AttendanceDataSource(context);
    // switch (_sortColumnIndex.value) {
    //   case 0:
    //     _attendanceDataSource!._fetchedAttendance!._sort<String>((d) => d.name, _sortAscending.value);
    //     break;
    //   case 1:
    //     _attendanceDataSource!
    //         ._sort<num>((d) => d.calories, _sortAscending.value);
    //     break;
    //   case 2:
    //     _attendanceDataSource!._sort<num>((d) => d.fat, _sortAscending.value);
    //     break;
    //   case 3:
    //     _attendanceDataSource!._sort<num>((d) => d.carbs, _sortAscending.value);
    //     break;
    // }
    //    for (int i = 0; i < _attendanceDataSource!.length; i++) {
    //   String columnName = _attendanceDataSource[i].keys.first;
    //   switch (_sortColumnIndex.value) {
    //     case i:
    //       _attendanceDataSource!._sort<String>(
    //           (d) => d[columnName]!, _sortAscending.value);
    //       break;
    //   }
    // }
//   for (int i = 0; i < _attendanceDataSource!.length; i++) {
//   String columnName = _attendanceDataSource[i].keys.first;
//   if (_sortColumnIndex.value == i) {
//     _attendanceDataSource!._sort<String>(
//       (d) => d[columnName]!,
//       _sortAscending.value,
//     );
//     break;
//   }
// }
    _attendanceDataSource ??= _AttendanceDataSource(context);
    if (_fetchedOrganization != null) if (_fetchedOrganization!.people.length >
        0)
      _fetchedOrganization!.people.map((person) {
        _attendanceDataSource!._fetchedAttendance!
            .map((i, element) {
              String columnName = element.keys.first;
              if (_sortColumnIndex.value == i) {
                _attendanceDataSource!._fetchedAttendance!._sort<String>(
                  (d) => d[columnName]!,
                  _sortAscending.value,
                );
                return MapEntry(
                    i, _attendanceDataSource!._fetchedAttendance![i]);
              }
              return MapEntry(i, element);
            })
            .values
            .toList();

        _attendanceDataSource!.updateSelectedAttendance(_dessertSelections);
        _attendanceDataSource!
            .addListener(_updateSelectedAttendanceRowListener);
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attendanceDataSource ??= _AttendanceDataSource(context);
    _attendanceDataSource!.addListener(_updateSelectedAttendanceRowListener);
  }

  void _updateSelectedAttendanceRowListener() {
    _dessertSelections
        .setAttendanceSelections(_attendanceDataSource!._fetchedAttendance);
  }

  void _sort<T>(
    Comparable<T> Function(ActivityAttendance d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _attendanceDataSource!._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _attendanceDataSource!.removeListener(_updateSelectedAttendanceRowListener);
    _attendanceDataSource!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = GalleryLocalizations.of(context)!;

    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (var org in campusAppsPortalInstance
                        .getUserPerson()
                        .organization!
                        .child_organizations)
                      // create a text widget with some padding
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (org.child_organizations.length > 0)
                              Row(children: <Widget>[
                                Text('Select a class:'),
                                SizedBox(width: 10),
                                DropdownButton<Organization>(
                                  value: _selectedValue,
                                  onChanged: (Organization? newValue) async {
                                    _selectedValue = newValue!;
                                    print(newValue.id);
                                    _fetchedOrganization =
                                        await fetchOrganization(newValue.id!);

                                    _fetchedAttendance =
                                        await getClassActivityAttendanceReport(
                                            _fetchedOrganization!.id!,
                                            activityId,
                                            50);
                                    if (_fetchedAttendance.length == 0)
                                      _fetchedAttendance = new List.filled(
                                          _fetchedOrganization!.people.length,
                                          new ActivityAttendance(
                                              person_id: -1));
                                    else {
                                      for (int i = 0;
                                          i <
                                              _fetchedOrganization!
                                                  .people.length;
                                          i++) {
                                        if (_fetchedAttendance.indexWhere(
                                                (attendance) =>
                                                    attendance.person_id ==
                                                    _fetchedOrganization!
                                                        .people[i].id) ==
                                            -1) {
                                          _fetchedAttendance.add(
                                              new ActivityAttendance(
                                                  person_id: -1));
                                        }
                                      }
                                    }
                                    if (campusAppsPortalInstance.isTeacher) {
                                      _fetchedAttendanceAfterSchool =
                                          await getClassActivityAttendanceReport(
                                              _fetchedOrganization!.id!,
                                              afterSchoolActivityId,
                                              50);
                                      _fetchedAttendanceAfterSchool =
                                          await getClassActivityAttendanceReport(
                                              _fetchedOrganization!.id!,
                                              afterSchoolActivityId,
                                              50);
                                      if (_fetchedAttendanceAfterSchool
                                              .length ==
                                          0)
                                        _fetchedAttendanceAfterSchool =
                                            new List.filled(
                                                _fetchedOrganization!
                                                    .people.length,
                                                new ActivityAttendance(
                                                    person_id: -1));
                                      else {
                                        for (int i = 0;
                                            i <
                                                _fetchedOrganization!
                                                    .people.length;
                                            i++) {
                                          if (_fetchedAttendanceAfterSchool
                                                  .indexWhere((attendance) =>
                                                      attendance.person_id ==
                                                      _fetchedOrganization!
                                                          .people[i].id) ==
                                              -1) {
                                            _fetchedAttendanceAfterSchool.add(
                                                new ActivityAttendance(
                                                    person_id: -1));
                                          }
                                        }
                                      }
                                    }

                                    setState(() {});
                                  },
                                  items: org.child_organizations
                                      .map((Organization value) {
                                    return DropdownMenuItem<Organization>(
                                      value: value,
                                      child: Text(value.description!),
                                    );
                                  }).toList(),
                                ),
                              ]),
                          ]),
                  ],
                ),
                SizedBox(height: 16.0),
                // children: [
                if (_fetchedOrganization != null)
                  if (_fetchedOrganization!.people.length > 0)
                    ..._fetchedOrganization!.people.map((person) {
                      var columnHeaders = _attendanceDataSource!
                          ._fetchedAttendance!
                          .map((attendance) {
                        return DataColumn(
                          label: Text(attendance!.sign_in_time!.toString()),
                          numeric: true,
                          onSort: (columnIndex, ascending) => _sort<String>(
                              (d) => d.sign_in_time!.toString(),
                              columnIndex,
                              ascending),
                        );
                      }).toList();
                      return Scrollbar(
                        child: ListView(
                          restorationId: 'data_table_list_view',
                          padding: const EdgeInsets.all(16),
                          children: [
                            PaginatedDataTable(
                              header: Text("dataTableHeader"),
                              rowsPerPage: _rowsPerPage.value,
                              showCheckboxColumn: false,
                              onRowsPerPageChanged: (value) {
                                setState(() {
                                  _rowsPerPage.value = value!;
                                });
                              },
                              initialFirstRowIndex: _rowIndex.value,
                              onPageChanged: (rowIndex) {
                                setState(() {
                                  _rowIndex.value = rowIndex;
                                });
                              },
                              sortColumnIndex: _sortColumnIndex.value,
                              sortAscending: _sortAscending.value,
                              onSelectAll: _attendanceDataSource!._selectAll,

                              // columns: [
                              //   DataColumn(
                              //     label: Text("Name"),
                              //     onSort: (columnIndex, ascending) =>
                              //         _sort<String>((d) => d.name, columnIndex, ascending),
                              //   ),
                              //   DataColumn(
                              //     label: Text("Sign In"),
                              //     numeric: true,
                              //     onSort: (columnIndex, ascending) =>
                              //         _sort<num>((d) => d.calories, columnIndex, ascending),
                              //   ),
                              //   DataColumn(
                              //     label: Text("Sign Out"),
                              //     numeric: true,
                              //     onSort: (columnIndex, ascending) =>
                              //         _sort<num>((d) => d.fat, columnIndex, ascending),
                              //   ),
                              //   DataColumn(
                              //     label: Text("After School"),
                              //     numeric: true,
                              //     onSort: (columnIndex, ascending) =>
                              //         _sort<num>((d) => d.carbs, columnIndex, ascending),
                              //   ),
                              // ],
                              columns: columnHeaders,

                              source: _attendanceDataSource!,
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            ),
    );
  }
}

class _AttendanceDataSource extends DataTableSource {
  _AttendanceDataSource(this.context) {
    // final localizations = GalleryLocalizations.of(context)!;
    late List<ActivityAttendance> _fetchedAttendance = [];
  }

  final BuildContext context;

  get _fetchedAttendance => null;

  int get length => _fetchedAttendance.length;

  void _sort<T>(
      Comparable<T> Function(ActivityAttendance d) getField, bool ascending) {
    _fetchedAttendance.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  void updateSelectedAttendance(_RestorableAttendanceSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < _fetchedAttendance.length; i += 1) {
      var attendance = _fetchedAttendance[i];
      if (selectedRows.isSelected(i)) {
        attendance.selected = true;
        _selectedCount += 1;
      } else {
        attendance.selected = false;
      }
    }
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    final format = NumberFormat.decimalPercentPattern(
      locale: GalleryOptions.of(context).locale.toString(),
      decimalDigits: 0,
    );
    assert(index >= 0);
    if (index >= _fetchedAttendance.length) return null;
    final attendance = _fetchedAttendance[index];
    return DataRow.byIndex(
      index: index,
      selected: attendance.selected!,
      onSelectChanged: (value) {
        if (attendance.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          attendance.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(attendance.sign_in_time!)),
        // DataCell(Text('${dessert.calories}')),
        // DataCell(Text(dessert.fat.toStringAsFixed(1))),
        // DataCell(Text('${dessert.carbs}')),
        ...List.generate(
          _fetchedAttendance.length,
          (index) => DataCell(Text(attendance.sign_in_time!)),
        ),
      ],
    );
  }

  @override
  int get rowCount => _fetchedAttendance.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool? checked) {
    for (final attendance in _fetchedAttendance) {
      attendance.selected = checked ?? false;
    }
    _selectedCount = checked! ? _fetchedAttendance.length : 0;
    notifyListeners();
  }
}
