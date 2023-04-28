import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/data.dart';
import 'package:gallery/avinya/attendance/lib/data/activity_attendance.dart';

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

  Future<void> toggleAttendance(
      int person_id, bool value, bool sign_in, bool after_school) async {
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

    print('index: $index  person_id: $person_id  value: $value');

    if (index == -1)
      index = _fetchedAttendance
          .indexWhere((attendance) => attendance.person_id == -1);

    if (value == false) {
      if (index != -1) {
        await deleteActivityAttendance(_fetchedAttendance[index].id!);
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
      if (sign_in)
        activityAttendance = await createActivityAttendance(ActivityAttendance(
          activity_instance_id: activityInstance.id,
          person_id: person_id,
          sign_in_time: DateTime.now().toString(),
          in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        ));
      else {
        activityAttendance = await createActivityAttendance(ActivityAttendance(
          activity_instance_id: activityInstance.id,
          person_id: person_id,
          sign_out_time: DateTime.now().toString(),
          out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
        ));
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
                                          await getClassActivityAttendanceToday(
                                              _fetchedOrganization!.id!,
                                              activityId);
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
                                            await getClassActivityAttendanceToday(
                                                _fetchedOrganization!.id!,
                                                afterSchoolActivityId);
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
                        if (campusAppsPortalInstance.isTeacher)
                          TableCell(
                              child: Text("After school",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
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
                              if (campusAppsPortalInstance.isTeacher)
                                if (_fetchedAttendanceAfterSchool.length > 0)
                                  if (_fetchedAttendanceAfterSchool
                                          .firstWhere(
                                              (attendance) =>
                                                  attendance.person_id ==
                                                      person.id &&
                                                  attendance.sign_in_time !=
                                                      null,
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
