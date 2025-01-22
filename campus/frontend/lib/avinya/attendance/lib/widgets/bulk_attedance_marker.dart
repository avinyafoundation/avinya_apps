import 'package:flutter/material.dart';
import 'package:attendance/data.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:attendance/data/evaluation.dart';
import 'package:attendance/widgets/evaluation_list.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../data/activity_instance.dart';

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
    _batchData = await fetchActiveOrganizationsByAvinyaType(86);
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
                      Text('Select a Batch:'),
                      SizedBox(height: 8),
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
                              value: _selectedOrganizationValue,
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

                                _fetchedOrganization =
                                    await fetchOrganization(newValue!.id!);
                                _fetchedOrganizations =
                                    _fetchedOrganization?.child_organizations ??
                                        [];

                                setState(() {
                                  _fetchedOrganizations;
                                  _selectedValue = null;
                                  _selectedOrganizationValue = newValue;
                                  batchStartDate = DateFormat('MMM d, yyyy')
                                      .format(DateTime.parse(
                                          _selectedOrganizationValue!
                                              .organization_metadata[0].value
                                              .toString()));

                                  batchEndDate = DateFormat('MMM d, yyyy')
                                      .format(DateTime.parse(
                                          _selectedOrganizationValue!
                                              .organization_metadata[1].value
                                              .toString()));
                                });
                              });
                        },
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (_fetchedOrganizations.length > 0)
                                  Row(children: <Widget>[
                                    Text('Select a class:'),
                                    SizedBox(width: 10),
                                    DropdownButton<Organization>(
                                      value: _selectedValue,
                                      onChanged:
                                          (Organization? newValue) async {
                                        _selectedValue = newValue!;
                                        print(newValue.id);
                                        _fetchedOrganization =
                                            await fetchOrganization(
                                                newValue.id!);

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
                                      items: _fetchedOrganizations
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
                    ],
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 32.0),
                  Text(
                    "Students",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(children: [
                        TableCell(
                            child: Text("Name",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        TableCell(
                            child: Text("Digital ID",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        TableCell(
                            child: Text("Sign in",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        TableCell(
                            child: Text("Sign out",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        // if (campusAppsPortalInstance.isTeacher)
                        TableCell(
                            child: Text("After school",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        // if (campusAppsPortalInstance.isTeacher)
                        TableCell(
                            child: Text("Absence Reason",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      if (_fetchedOrganization != null)
                        if (_fetchedOrganization!.people.length > 0)
                          ..._fetchedOrganization!.people.map((person) {
                            return TableRow(children: [
                              TableCell(child: Text(person.preferred_name!)),
                              TableCell(child: Text(person.digital_id!)),
                              // sign in
                              if (_fetchedAttendance.length > 0)
                                if (_fetchedAttendance
                                        .firstWhere(
                                            (attendance) =>
                                                attendance.person_id ==
                                                    person.id &&
                                                attendance.sign_in_time != null,
                                            orElse: () =>
                                                new ActivityAttendance(
                                                    person_id: -1))
                                        .person_id !=
                                    -1)
                                  TableCell(
                                    child: Checkbox(
                                      value: _fetchedAttendance
                                              .firstWhere(
                                                (attendance) =>
                                                    attendance.person_id ==
                                                        person.id &&
                                                    attendance.sign_in_time !=
                                                        null,
                                              )
                                              .sign_in_time !=
                                          null,
                                      onChanged: (bool? value) async {
                                        await toggleAttendance(
                                            person.id!, value!, true, false);
                                        setState(() {});
                                      },
                                    ),
                                  )
                                else
                                  TableCell(
                                    child: Checkbox(
                                      value: false,
                                      onChanged: (bool? value) async {
                                        await toggleAttendance(
                                            person.id!, value!, true, false);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                              // sign out
                              if (_fetchedAttendance.length > 0)
                                if (_fetchedAttendance
                                        .firstWhere(
                                            (attendance) =>
                                                attendance.person_id ==
                                                    person.id &&
                                                attendance.sign_out_time !=
                                                    null,
                                            orElse: () =>
                                                new ActivityAttendance(
                                                    person_id: -1))
                                        .person_id !=
                                    -1)
                                  TableCell(
                                    child: Checkbox(
                                      value: _fetchedAttendance
                                              .firstWhere(
                                                (attendance) =>
                                                    attendance.person_id ==
                                                        person.id &&
                                                    attendance.sign_out_time !=
                                                        null,
                                              )
                                              .sign_out_time !=
                                          null,
                                      onChanged: (bool? value) async {
                                        await toggleAttendance(
                                            person.id!, value!, false, false);
                                        setState(() {});
                                      },
                                    ),
                                  )
                                else
                                  TableCell(
                                    child: Checkbox(
                                      value: false,
                                      onChanged: (bool? value) async {
                                        await toggleAttendance(
                                            person.id!, value!, false, false);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                              // if (campusAppsPortalInstance.isTeacher)
                              if (_fetchedAttendanceAfterSchool.length > 0)
                                if (_fetchedAttendanceAfterSchool
                                        .firstWhere(
                                            (attendance) =>
                                                attendance.person_id ==
                                                    person.id &&
                                                attendance.sign_in_time != null,
                                            orElse: () =>
                                                new ActivityAttendance(
                                                    person_id: -1))
                                        .person_id !=
                                    -1)
                                  TableCell(
                                    child: Checkbox(
                                      value: _fetchedAttendanceAfterSchool
                                              .firstWhere(
                                                (attendance) =>
                                                    attendance.person_id ==
                                                        person.id &&
                                                    attendance.sign_in_time !=
                                                        null,
                                              )
                                              .sign_in_time !=
                                          null,
                                      onChanged: (bool? value) async {
                                        await toggleAttendance(
                                            person.id!, value!, true, true);
                                        setState(() {});
                                      },
                                    ),
                                  )
                                else
                                  TableCell(
                                    child: Checkbox(
                                      value: false,
                                      onChanged: (bool? value) async {
                                        await toggleAttendance(
                                            person.id!, value!, true, true);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                              // if (campusAppsPortalInstance.isTeacher)
                              if (_fetchedEvaluations.length > 0)
                                if (_fetchedEvaluations
                                        .firstWhere(
                                            (evaluation) =>
                                                evaluation.evaluatee_id ==
                                                person.id,
                                            orElse: () => new Evaluation(
                                                evaluatee_id: -1))
                                        .evaluatee_id !=
                                    -1)
                                  TableCell(
                                    child: Row(children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(_fetchedEvaluations
                                              .firstWhere((evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  person.id)
                                              .response!),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          var evaluation = _fetchedEvaluations
                                              .firstWhere((evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  person.id);

                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditEvaluationPage(
                                                        evaluation:
                                                            evaluation)),
                                          );
                                          _fetchedEvaluations =
                                              await getActivityInstanceEvaluations(
                                                  activityInstance.id!);
                                          setState(() {});
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          var evaluation = _fetchedEvaluations
                                              .firstWhere((evaluation) =>
                                                  evaluation.evaluatee_id ==
                                                  person.id);
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DeleteEvaluationPage(
                                                        evaluation:
                                                            evaluation)),
                                          );
                                          _fetchedEvaluations =
                                              await getActivityInstanceEvaluations(
                                                  activityInstance.id!);
                                          setState(() {});
                                        },
                                      ),
                                    ]),
                                  )
                                else
                                  TableCell(
                                    child: Row(children: [
                                      Text(""),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () async {
                                          if (activityInstance.id == -1) {
                                            activityInstance =
                                                await campusAttendanceSystemInstance
                                                    .getCheckinActivityInstance(
                                                        activityId);
                                          }
                                          var evaluation = Evaluation(
                                            evaluator_id:
                                                campusAppsPortalInstance
                                                    .getUserPerson()
                                                    .id,
                                            evaluatee_id: person.id,
                                            activity_instance_id:
                                                activityInstance.id,
                                            grade: 0,
                                            evaluation_criteria_id: 54,
                                            response: "Unexcused absence",
                                          );
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddEvaluationPage(
                                                      evaluation: evaluation,
                                                    )),
                                          );
                                          _fetchedEvaluations =
                                              await getActivityInstanceEvaluations(
                                                  activityInstance.id!);
                                          setState(() {});
                                        },
                                      ),
                                    ]),
                                  )
                              else
                                TableCell(
                                  child: Row(children: [
                                    Text(""),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        if (activityInstance.id == -1) {
                                          activityInstance =
                                              await campusAttendanceSystemInstance
                                                  .getCheckinActivityInstance(
                                                      activityId);
                                        }
                                        var evaluation = Evaluation(
                                          evaluator_id: campusAppsPortalInstance
                                              .getUserPerson()
                                              .id,
                                          evaluatee_id: person.id,
                                          activity_instance_id:
                                              activityInstance.id,
                                          grade: 0,
                                          evaluation_criteria_id: 54,
                                          response: "Unexcused absence",
                                        );
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddEvaluationPage(
                                                    evaluation: evaluation,
                                                  )),
                                        );
                                        _fetchedEvaluations =
                                            await getActivityInstanceEvaluations(
                                                activityInstance.id!);
                                        setState(() {});
                                      },
                                    ),
                                  ]),
                                ),
                            ]);
                          }).toList()
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
