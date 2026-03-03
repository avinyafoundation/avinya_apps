import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:attendance/data.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
import 'package:attendance/widgets/evaluation_list.dart';
import 'package:intl/intl.dart';
import 'package:gallery/avinya/attendance/lib/widgets/common/drop_down.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../data/activity_instance.dart';
import 'absence_reason_dialog.dart';
import 'delete_absence_reason_dialog.dart';

class BulkAttendanceMarker extends StatefulWidget {
  const BulkAttendanceMarker({super.key});
  @override
  _BulkAttendanceMarkerState createState() => _BulkAttendanceMarkerState();
}

class _BulkAttendanceMarkerState extends State<BulkAttendanceMarker> {
  List<Map<String, bool>> attendanceList = [];
  var _selectedValue;
  var activityId = 0;
  var afterSchoolActivityId = 0;
  var activityInstance = ActivityInstance(id: -1);
  var activityInstanceAfterSchool = ActivityInstance(id: -1);
  Organization? _fetchedOrganization;
  List<ActivityAttendance> _fetchedAttendance = [];
  List<ActivityAttendance> _fetchedAttendanceAfterSchool = [];
  List<Evaluation> _fetchedEvaluations = [];
  late Future<List<Organization>> _fetchBatchData;
  Organization? _selectedOrganizationValue;
  List<Organization> _batchData = [];
  List<Organization> _fetchedOrganizations = [];
  String batchStartDate = "";
  String batchEndDate = "";
  List<Person> _filteredStudents = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _fetchBatchData = _loadBatchData();
    if (campusAppsPortalInstance.isTeacher ||
        campusAppsPortalInstance.isFoundation ||
        campusAppsPortalInstance.isSecurity) {
      activityId = campusAppsPortalInstance.activityIds['homeroom']!;
      afterSchoolActivityId =
          campusAppsPortalInstance.activityIds['after-school']!;
    }
  }

  Future<List<Organization>> _loadBatchData() async {
    //_batchData = await fetchActiveOrganizationsByAvinyaType();
    _batchData = await fetchOrganizationsByAvinyaTypeAndStatus(null, 1);
    _selectedOrganizationValue = _batchData.isNotEmpty ? _batchData.last : null;
    batchStartDate = DateFormat('MMM d, yyyy').format(DateTime.parse(
        _selectedOrganizationValue!.organization_metadata[0].value.toString()));
    batchEndDate = DateFormat('MMM d, yyyy').format(DateTime.parse(
        _selectedOrganizationValue!.organization_metadata[1].value.toString()));
    if (_selectedOrganizationValue != null) {
      int orgId = _selectedOrganizationValue!.id!;
      _fetchedOrganization = await fetchOrganization(orgId);
      _fetchedOrganizations = _fetchedOrganization?.child_organizations ?? [];
      setState(() {
        _fetchedOrganizations = _fetchedOrganizations;
      });
    }
    // this.updateDateRange(today, today);
    return _batchData;
  }

  Future<void> toggleAttendance(
      int person_id, bool value, bool sign_in, bool after_school) async {
    // handle activity id fetch case

    _fetchedOrganization = await fetchOrganization(_selectedValue.id!);

    _fetchedAttendance = await getClassActivityAttendanceToday(
        _fetchedOrganization!.id!, activityId);
    if (_fetchedAttendance.length == 0)
      _fetchedAttendance = new List.filled(
          _fetchedOrganization!.people.length *
              2, // add 2 records for eign in and out
          new ActivityAttendance(person_id: -1));
    else {
      for (int i = 0; i < _fetchedOrganization!.people.length; i++) {
        if (_fetchedAttendance.indexWhere((attendance) =>
                attendance.person_id == _fetchedOrganization!.people[i].id) ==
            -1) {
          // add 2 records for sing in and out
          _fetchedAttendance.add(new ActivityAttendance(person_id: -1));
          _fetchedAttendance.add(new ActivityAttendance(person_id: -1));
        }
      }
    }

    // handle after achool
    if (after_school) {
      if (activityInstanceAfterSchool.id == -1) {
        activityInstanceAfterSchool = await campusAttendanceSystemInstance
            .getCheckinActivityInstance(afterSchoolActivityId);
      }
      int index = -1;
      index = _fetchedAttendanceAfterSchool.indexWhere((attendance) =>
          attendance.person_id == person_id && attendance.sign_in_time != null);

      if (index == -1)
        index = _fetchedAttendanceAfterSchool
            .indexWhere((attendance) => attendance.person_id == -1);
      if (value == false) {
        if (index != -1) {
          await deleteActivityAttendance(
              _fetchedAttendanceAfterSchool[index].id!);
        }

        _fetchedAttendanceAfterSchool[index] =
            ActivityAttendance(person_id: -1, sign_in_time: null);
      } else {
        ActivityAttendance activityAttendance = ActivityAttendance(
            person_id: -1, sign_in_time: null, sign_out_time: null);
        ;

        activityAttendance = await createActivityAttendance(ActivityAttendance(
          activity_instance_id: activityInstanceAfterSchool.id,
          person_id: person_id,
          sign_in_time: DateTime.now().toString(),
          in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        ));

        _fetchedAttendanceAfterSchool[index] = activityAttendance;
      }

      return;
    }

    // handle normal attendance sing in and out

    if (activityInstance.id == -1) {
      activityInstance = await campusAttendanceSystemInstance
          .getCheckinActivityInstance(activityId);
    }
    int index = -1;

    if (sign_in)
      index = _fetchedAttendance.indexWhere((attendance) =>
          attendance.person_id == person_id && attendance.sign_in_time != null);
    else
      index = _fetchedAttendance.indexWhere((attendance) =>
          attendance.person_id == person_id &&
          attendance.sign_out_time != null);

    print(
        'index: $index  person_id: $person_id  value: $value _fetchedAttendance lenth ${_fetchedAttendance.length}');

    if (index == -1) {
      index = _fetchedAttendance
          .indexWhere((attendance) => attendance.person_id == -1);
      if (index == -1) {
        print(
            'index is still -1 => index: $index  person_id: $person_id  value: $value');
        // if index is still -1 then there is no empty slot
        // so we need to create a new slot
        _fetchedAttendance.add(ActivityAttendance(
            person_id: -1, sign_in_time: null, sign_out_time: null));
        index = _fetchedAttendance.length - 1;
      }
    }

    if (value == false) {
      if (index != -1) {
        // deletePersonActivityAttendance(_fetchedAttendance[index].id!);
        deleteActivityAttendance(_fetchedAttendance[index].id!);
      }
      if (sign_in)
        _fetchedAttendance[index] =
            ActivityAttendance(person_id: -1, sign_in_time: null);
      else
        _fetchedAttendance[index] =
            ActivityAttendance(person_id: -1, sign_out_time: null);
    } else {
      ActivityAttendance activityAttendance = ActivityAttendance(
          person_id: -1, sign_in_time: null, sign_out_time: null);
      ;
      if (sign_in) {
        activityAttendance = ActivityAttendance(
          activity_instance_id: activityInstance.id,
          person_id: person_id,
          sign_in_time: DateTime.now().toString(),
          in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        );
        createActivityAttendance(
            activityAttendance); // make the call async and returrn withtout waiting
      } else {
        activityAttendance = ActivityAttendance(
          activity_instance_id: activityInstance.id,
          person_id: person_id,
          sign_out_time: DateTime.now().toString(),
          out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        );
        createActivityAttendance(
            activityAttendance); // make the call async and returrn withtout waiting
      }

      _fetchedAttendance[index] = activityAttendance;
    }
  }

  void searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents =_fetchedOrganization!.people;
        print('Query is empty:');
      } else {
        final lowerCaseQuery = query.toLowerCase();

        _filteredStudents = _fetchedOrganization!.people.where((student) {
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
    });
  }

  Future<void> _showAbsenceReasonDialog(Person person,
      {Evaluation? evaluation}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AbsenceReasonDialog(
          person: person,
          evaluation: evaluation,
          activityId: activityId,
          activityInstance: activityInstance,
          onEvaluationSaved: (newActivityInstance, savedEvaluation) async {
            // Logic to refresh evaluations
            _fetchedEvaluations =
                await getActivityInstanceEvaluations(newActivityInstance.id!);
            setState(() {});
          },
        );
      },
    );
  }

  Future<void> _showDeleteAbsenceReasonDialog(Evaluation evaluation) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteAbsenceReasonDialog(
          evaluation: evaluation,
          onEvaluationDeleted: (deletedEvaluation) async {
            // Logic to refresh evaluations
            _fetchedEvaluations =
                await getActivityInstanceEvaluations(activityInstance.id!);
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (_fetchedOrganizations.length > 0)
                                  Row(children: <Widget>[
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 200,
                                      child: DropDown<Organization>(
                                        label: 'Select a class',
                                        items: _fetchedOrganizations,
                                        selectedValues: _selectedValue?.id,
                                        valueField: (org) => org.id!,
                                        displayField: (org) =>
                                            org.description ?? '',
                                        onChanged: (int? newValueId) async {
                                          final newValue = newValueId != null
                                              ? _fetchedOrganizations
                                                  .firstWhere((org) =>
                                                      org.id == newValueId)
                                              : null;
                                          if (newValue == null) return;
                                          _selectedValue = newValue!;
                                          print(newValue.id);
                                          _fetchedOrganization =
                                              await fetchOrganization(
                                                  newValue.id!);

                                          _filteredStudents =_fetchedOrganization!.people;

                                          _fetchedAttendance =
                                              await getClassActivityAttendanceToday(
                                                  _fetchedOrganization!.id!,
                                                  activityId);
                                          if (_fetchedAttendance.length == 0)
                                            _fetchedAttendance = new List.filled(
                                                _fetchedOrganization!
                                                        .people.length *
                                                    2, // add 2 records for eign in and out
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
                                                // add 2 records for sing in and out
                                                _fetchedAttendance.add(
                                                    new ActivityAttendance(
                                                        person_id: -1));
                                                _fetchedAttendance.add(
                                                    new ActivityAttendance(
                                                        person_id: -1));
                                              }
                                            }
                                          }
                                          // if (campusAppsPortalInstance.isTeacher) {
                                          _fetchedAttendanceAfterSchool =
                                              await getClassActivityAttendanceToday(
                                                  _fetchedOrganization!.id!,
                                                  afterSchoolActivityId);
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

                                          if (activityInstance.id == -1) {
                                            activityInstance =
                                                await campusAttendanceSystemInstance
                                                    .getCheckinActivityInstance(
                                                        activityId);
                                          }

                                          _fetchedEvaluations =
                                              await getActivityInstanceEvaluations(
                                                  activityInstance.id!);
                                          if (_fetchedEvaluations.length == 0)
                                            _fetchedEvaluations = new List.filled(
                                                    _fetchedOrganization!
                                                        .people.length,
                                                    new Evaluation(evaluatee_id: -1));
                                          else {
                                            for (int i = 0;
                                                i <
                                                    _fetchedOrganization!
                                                        .people.length;
                                                i++) {
                                              if (_fetchedEvaluations.indexWhere(
                                                      (evaluation) =>
                                                          evaluation
                                                              .evaluatee_id ==
                                                          _fetchedOrganization!
                                                              .people[i].id) ==
                                                  -1) {
                                                _fetchedEvaluations.add(
                                                    new Evaluation(
                                                        evaluatee_id: -1));
                                              }
                                            }
                                          }
                                          // }

                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ]),
                              ]),
                        ],
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Center(
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
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Container(
                          padding: const EdgeInsets.only(bottom: 15),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFECF0F1)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: const Color(0xFF1BB6E8),
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Student Attendance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const Spacer(),
                              if (_selectedValue != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F8F5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _selectedValue!.description ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Data Table Content
                        if (_isLoadingData)
                          Container(
                            padding: const EdgeInsets.all(60),
                            alignment: Alignment.center,
                            child: SpinKitCircle(
                              color: const Color(0xFF1BB6E8),
                              size: 50,
                            ),
                          )
                        else if (_fetchedOrganization != null &&
                            _filteredStudents.length > 0)
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            }),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dataTableTheme: DataTableThemeData(
                                  headingRowColor: WidgetStateProperty.all(
                                      const Color(0xFFF8F9FA)),
                                  headingTextStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                  dataRowColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return const Color(0xFFF5F7FA);
                                    }
                                    return null;
                                  }),
                                  dataTextStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  bool isMobile =
                                      MediaQuery.of(context).size.width < 600;
                                  final tableColumnSpacing =
                                      isMobile ? 30.0 : 80.0;
                                  final int effectiveRows =
                                      (_filteredStudents.length > 0)
                                          ? math.min(
                                              22, _filteredStudents.length)
                                          : 1;
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: PaginatedDataTable(
                                      showCheckboxColumn: false,
                                      source: AttendanceDataSource(
                                        _filteredStudents,
                                        _fetchedAttendance,
                                        _fetchedEvaluations,
                                        activityInstance,
                                        activityId,
                                        toggleAttendance,
                                        setState,
                                        getActivityInstanceEvaluations,
                                        context,
                                        _showAbsenceReasonDialog,
                                        _showDeleteAbsenceReasonDialog,
                                      ),
                                      columns: [
                                        DataColumn(
                                          label: Expanded(
                                            child: Center(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF2C3E50))),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Center(
                                              child: Text('NIC',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF2C3E50))),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Center(
                                              child: Text('Sign In',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF2C3E50))),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Center(
                                              child: Text('Sign Out',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF2C3E50))),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Center(
                                              child: Text('Absence Reason',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF2C3E50))),
                                            ),
                                          ),
                                        ),
                                      ],
                                      columnSpacing: tableColumnSpacing,
                                      horizontalMargin: isMobile ? 15 : 24,
                                      rowsPerPage: effectiveRows,
                                      showFirstLastButtons: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(40),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No class selected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class AttendanceDataSource extends DataTableSource {
  final List<Person> filteredStudents;
  final List<ActivityAttendance> fetchedAttendance;
  final List<Evaluation> fetchedEvaluations;
  final ActivityInstance activityInstance;
  final int activityId;
  final Function(int, bool, bool, bool) toggleAttendance;
  final Function(void Function()) setState;
  final Function(int) getActivityInstanceEvaluations;
  final BuildContext context;
  final Function(Person, {Evaluation? evaluation}) showAbsenceReasonDialog;
  final Function(Evaluation) showDeleteAbsenceReasonDialog;

  AttendanceDataSource(
    this.filteredStudents,
    this.fetchedAttendance,
    this.fetchedEvaluations,
    this.activityInstance,
    this.activityId,
    this.toggleAttendance,
    this.setState,
    this.getActivityInstanceEvaluations,
    this.context,
    this.showAbsenceReasonDialog,
    this.showDeleteAbsenceReasonDialog,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= filteredStudents.length) return null;

    final person = filteredStudents[index];

    return DataRow(
      cells: [
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(
            person.preferred_name!,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
          ),
        )),
        DataCell(Center(
          child: Text(
            person.nic_no!,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
          ),
        )),
        // Sign In
        DataCell(Center(
          child: fetchedAttendance.length > 0 &&
                  fetchedAttendance
                          .firstWhere(
                              (attendance) =>
                                  attendance.person_id == person.id &&
                                  attendance.sign_in_time != null,
                              orElse: () => ActivityAttendance(person_id: -1))
                          .person_id !=
                      -1
              ? Checkbox(
                  value: fetchedAttendance
                          .firstWhere(
                            (attendance) =>
                                attendance.person_id == person.id &&
                                attendance.sign_in_time != null,
                          )
                          .sign_in_time !=
                      null,
                  onChanged: (bool? value) async {
                    await toggleAttendance(person.id!, value!, true, false);
                    setState(() {});
                    notifyListeners();
                  },
                )
              : Checkbox(
                  value: false,
                  onChanged: (bool? value) async {
                    await toggleAttendance(person.id!, value!, true, false);
                    setState(() {});
                    notifyListeners();
                  },
                ),
        )),
        // Sign Out
        DataCell(Center(
          child: () {
            // Check if student has signed in first
            final bool hasSignedIn = fetchedAttendance.length > 0 &&
                fetchedAttendance
                        .firstWhere(
                            (attendance) =>
                                attendance.person_id == person.id &&
                                attendance.sign_in_time != null,
                            orElse: () => ActivityAttendance(person_id: -1))
                        .person_id !=
                    -1;

            final bool hasSignedOut = fetchedAttendance.length > 0 &&
                fetchedAttendance
                        .firstWhere(
                            (attendance) =>
                                attendance.person_id == person.id &&
                                attendance.sign_out_time != null,
                            orElse: () => ActivityAttendance(person_id: -1))
                        .person_id !=
                    -1;

            return Checkbox(
              value: hasSignedOut
                  ? fetchedAttendance
                          .firstWhere(
                            (attendance) =>
                                attendance.person_id == person.id &&
                                attendance.sign_out_time != null,
                          )
                          .sign_out_time !=
                      null
                  : false,
              onChanged: hasSignedIn
                  ? (bool? value) async {
                      await toggleAttendance(person.id!, value!, false, false);
                      setState(() {});
                      notifyListeners();
                    }
                  : null, // Disabled when student hasn't signed in
              fillColor: hasSignedIn
                  ? null // Use default color when enabled
                  : WidgetStateProperty.all(
                      Colors.grey[100]), // Light color when disabled
              checkColor: hasSignedIn ? null : Colors.grey[200],
            );
          }(),
        )),
        // Absence Reason
        DataCell(
          fetchedEvaluations.length > 0 &&
                  fetchedEvaluations
                          .firstWhere(
                              (evaluation) =>
                                  evaluation.evaluatee_id == person.id,
                              orElse: () => Evaluation(evaluatee_id: -1))
                          .evaluatee_id !=
                      -1
              ? Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          fetchedEvaluations
                              .firstWhere((evaluation) =>
                                  evaluation.evaluatee_id == person.id)
                              .response!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 18),
                      onPressed: () async {
                        var evaluation = fetchedEvaluations.firstWhere(
                            (evaluation) =>
                                evaluation.evaluatee_id == person.id);

                        await showAbsenceReasonDialog(person,
                            evaluation: evaluation);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 18),
                      onPressed: () async {
                        var evaluation = fetchedEvaluations.firstWhere(
                            (evaluation) =>
                                evaluation.evaluatee_id == person.id);
                        await showDeleteAbsenceReasonDialog(evaluation);
                      },
                    ),
                  ],
                )
              : Center(
                  child: () {
                    // Check if student is present (has sign in time)
                    final bool isPresent = fetchedAttendance.length > 0 &&
                        fetchedAttendance
                                .firstWhere(
                                    (attendance) =>
                                        attendance.person_id == person.id &&
                                        attendance.sign_in_time != null,
                                    orElse: () =>
                                        ActivityAttendance(person_id: -1))
                                .person_id !=
                            -1;

                    return IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: isPresent
                            ? Colors
                                .grey[300] // Light disabled color when present
                            : Colors.grey[600], // Normal color when absent
                      ),
                      onPressed: isPresent
                          ? null // Disabled when student is present
                          : () async {
                              showAbsenceReasonDialog(person);
                            },
                    );
                  }(),
                ),
        ),
      ],
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.blue.withOpacity(0.05);
        }
        if (index.isEven) {
          return Colors.grey.withOpacity(0.05);
        }
        return null;
      }),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => filteredStudents.length;

  @override
  int get selectedRowCount => 0;
}
