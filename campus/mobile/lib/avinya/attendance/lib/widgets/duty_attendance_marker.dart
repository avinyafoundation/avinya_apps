import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:attendance/data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/constants.dart';
import '../data/activity_instance.dart';
import 'package:attendance/data/evaluation.dart';

class DutyAttendanceMarker extends StatefulWidget {
  const DutyAttendanceMarker({super.key});

  @override
  State<DutyAttendanceMarker> createState() => _DutyAttendanceMarkerState();
}

class _DutyAttendanceMarkerState extends State<DutyAttendanceMarker> {
  var workActivityId = 0;
  var workActivityInstance = ActivityInstance(id: -1);

  List<DutyParticipant> _dutyParticipants = [];
  List<ActivityAttendance> _fetchedDutyAttendance = [];
  List<Evaluation> _fetchedEvaluations = [];
  List<bool> selectedRows = [];

  var parentOrganizationId = 0;

  @override
  void initState() {
    super.initState();
    workActivityId = campusAppsPortalInstance.activityIds['work']!;
    parentOrganizationId = campusAppsPortalInstance
        .getUserPerson()
        .organization!
        .parent_organizations[0]
        .parent_organizations[0]
        .id!;
    loadDutyParticipants();
    loadDutyAttendance();
    loadEvaluations();
  }

  Future<void> submitDutyAttendance(DutyParticipant dutyParticipant,
      TimeOfDay selectedTime, bool sign_in) async {
    _dutyParticipants = await fetchDutyParticipantsByDutyActivityId(
        parentOrganizationId,
        campusAppsPortalInstance.getLeaderParticipant().activity!.id!);

    _fetchedDutyAttendance =
        await getDutyAttendanceToday(parentOrganizationId, workActivityId);

    ActivityAttendance dutyActivityAttendance = ActivityAttendance(
        person_id: -1, sign_in_time: null, sign_out_time: null);

    var dutyAttendance = null;

    dutyAttendance = _fetchedDutyAttendance.firstWhere(
      (attendance) =>
          attendance.person_id == dutyParticipant.person!.id! &&
          (sign_in ? attendance.sign_in_time : attendance.sign_out_time) !=
              null,
      orElse: () => new ActivityAttendance(
        sign_in_time: null,
        sign_out_time: null,
      ),
    );

    if (dutyAttendance.sign_in_time != null ||
        dutyAttendance.sign_out_time != null) {
      await deleteActivityAttendance(dutyAttendance.id!);
    }

    if (sign_in) {
      dutyActivityAttendance = ActivityAttendance(
        activity_instance_id: workActivityInstance.id,
        person_id: dutyParticipant.person!.id,
        sign_in_time: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, selectedTime.hour, selectedTime.minute)
            .toString(),
        in_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
      );
    } else {
      dutyActivityAttendance = ActivityAttendance(
        activity_instance_id: workActivityInstance.id,
        person_id: dutyParticipant.person!.id,
        sign_out_time: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, selectedTime.hour, selectedTime.minute)
            .toString(),
        out_marked_by: campusAppsPortalInstance.getUserPerson().digital_id,
      );
    }

    await createDutyActivityAttendance(dutyActivityAttendance);
  }

  Future<void> toggleAbsent(DutyParticipant dutyParticipant, bool value) async {
    if (workActivityInstance.id == -1) {
      workActivityInstance = await campusAttendanceSystemInstance
          .getCheckinActivityInstance(workActivityId);
    }

    if (value == true) {
      var signInDutyAttendance = null;
      var signOutDutyAttendance = null;

      _fetchedDutyAttendance.forEach((attendance) {
        if (attendance.person_id == dutyParticipant.person!.id!) {
          if (attendance.sign_in_time != null) {
            signInDutyAttendance = attendance;
          } else if (attendance.sign_out_time != null) {
            signOutDutyAttendance = attendance;
          }
        }
      });

      if (signInDutyAttendance != null &&
          signInDutyAttendance.sign_in_time != null) {
        await deleteActivityAttendance(signInDutyAttendance.id!);
      }

      if (signOutDutyAttendance != null &&
          signOutDutyAttendance.sign_out_time != null) {
        await deleteActivityAttendance(signOutDutyAttendance.id!);
      }

      final Evaluation evaluation = Evaluation(
          evaluatee_id: dutyParticipant.person!.id,
          evaluator_id: campusAppsPortalInstance.getUserPerson().id,
          evaluation_criteria_id: 110,
          activity_instance_id: workActivityInstance.id,
          response: "absence",
          notes: "",
          grade: 0);
      await createDutyEvaluation(evaluation);
    } else if (value == false) {
      var evaluation = _fetchedEvaluations.firstWhere(
          (evaluation) =>
              evaluation.evaluatee_id == dutyParticipant.person!.id!,
          orElse: () => new Evaluation(evaluatee_id: -1));

      if (evaluation.evaluatee_id != null && evaluation.evaluatee_id != -1) {
        await deleteEvaluation(evaluation.id!.toString());
      }
    }
  }

  Future<void> loadDutyParticipants() async {
    final dutyParticipants = await fetchDutyParticipantsByDutyActivityId(
        parentOrganizationId,
        campusAppsPortalInstance.getLeaderParticipant().activity!.id!);

    setState(() {
      _dutyParticipants = dutyParticipants;
    });
  }

  Future<void> loadDutyAttendance() async {
    final dutyAttendance =
        await getDutyAttendanceToday(parentOrganizationId, workActivityId);

    setState(() {
      _fetchedDutyAttendance = dutyAttendance;
    });
  }

  Future<void> loadEvaluations() async {
    if (workActivityInstance.id == -1) {
      workActivityInstance = await campusAttendanceSystemInstance
          .getCheckinActivityInstance(workActivityId);
    }

    final evaluations =
        await getActivityInstanceEvaluations(workActivityInstance.id!);

    setState(() {
      _fetchedEvaluations = evaluations;
    });
  }

  TimeOfDay? _getInitialTime(DutyParticipant participant, bool isInTime) {
    var dutyAttendance = null;
    var initialTime = null;

    dutyAttendance = _fetchedDutyAttendance.firstWhere(
      (attendance) =>
          attendance.person_id == participant.person!.id! &&
          (isInTime ? attendance.sign_in_time : attendance.sign_out_time) !=
              null,
      orElse: () => new ActivityAttendance(
        sign_in_time: null,
        sign_out_time: null,
      ),
    );

    initialTime =
        isInTime ? dutyAttendance.sign_in_time : dutyAttendance.sign_out_time;

    print("initial time : ${initialTime}");

    if (initialTime != null) {
      final dateTime = DateTime.parse(initialTime.toString());
      return TimeOfDay.fromDateTime(dateTime);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Icon(
                IconData(0xe6f2, fontFamily: 'MaterialIcons'),
                size: 25,
                color: Colors.deepPurpleAccent,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Duty :',
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
              SizedBox(
                width: 20,
              ),
              Text(
                  campusAppsPortalInstance
                      .getLeaderParticipant()
                      .activity!
                      .name!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 100,
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _dutyParticipants.isEmpty ? SizedBox() : buildTable(),
                ],
              )),
        ],
      ),
    );
  }

  Widget buildTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 1200,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        "Student Name",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Digital Id",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Class",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Status",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "In Time",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Out Time",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Absent",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _dutyParticipants.map((participant) {
                    bool isAbsent = false;
                    if (_fetchedEvaluations
                            .firstWhere(
                                (evaluation) =>
                                    evaluation.evaluatee_id ==
                                    participant.person!.id!,
                                orElse: () => new Evaluation(evaluatee_id: -1))
                            .evaluatee_id !=
                        -1) isAbsent = true;

                    return DataRow(
                      cells: [
                        DataCell(Text(
                          participant.person!.preferred_name ?? 'N/A',
                        )),
                        DataCell(Text(
                          participant.person!.digital_id ?? 'N/A',
                        )),
                        DataCell(Text(
                          participant.person!.organization?.description ??
                              'N/A',
                        )),
                        DataCell(
                          _fetchedDutyAttendance
                                      .firstWhere(
                                          (attendance) =>
                                              attendance.person_id ==
                                                  participant.person!.id! &&
                                              attendance.sign_in_time != null,
                                          orElse: () => new ActivityAttendance(
                                              sign_in_time: null))
                                      .sign_in_time !=
                                  null
                              ? Text(
                                  "Present",
                                  style: TextStyle(color: Colors.green),
                                )
                              : Text(
                                  "Absent",
                                  style: TextStyle(color: Colors.red),
                                ),
                        ),
                        //In time
                        if (_fetchedDutyAttendance
                                .firstWhere(
                                    (attendance) =>
                                        attendance.person_id ==
                                            participant.person!.id! &&
                                        attendance.sign_in_time != null,
                                    orElse: () =>
                                        new ActivityAttendance(person_id: -1))
                                .person_id !=
                            -1)
                          DataCell(
                            TimePickerCell(
                              onTimeSelected: (TimeOfDay selectedTime) async {
                                await submitDutyAttendance(
                                    participant, selectedTime, true);

                                _fetchedDutyAttendance =
                                    await getDutyAttendanceToday(
                                        parentOrganizationId, workActivityId);

                                setState(() {});
                              },
                              initialTime: _getInitialTime(participant, true),
                              isButtonEnabled: isAbsent,
                            ),
                          )
                        else
                          DataCell(
                            TimePickerCell(
                              onTimeSelected: (TimeOfDay selectedTime) async {
                                await submitDutyAttendance(
                                    participant, selectedTime, true);

                                _fetchedDutyAttendance =
                                    await getDutyAttendanceToday(
                                        parentOrganizationId, workActivityId);

                                setState(() {});
                              },
                              initialTime: null,
                              isButtonEnabled: isAbsent,
                            ),
                          ),
                        //Out time
                        if (_fetchedDutyAttendance
                                .firstWhere(
                                    (attendance) =>
                                        attendance.person_id ==
                                            participant.person!.id! &&
                                        attendance.sign_out_time != null,
                                    orElse: () =>
                                        new ActivityAttendance(person_id: -1))
                                .person_id !=
                            -1)
                          DataCell(
                            TimePickerCell(
                              onTimeSelected: (TimeOfDay selectedTime) async {
                                await submitDutyAttendance(
                                    participant, selectedTime, false);

                                _fetchedDutyAttendance =
                                    await getDutyAttendanceToday(
                                        parentOrganizationId, workActivityId);

                                setState(() {});
                              },
                              initialTime: _getInitialTime(participant, false),
                              isButtonEnabled: isAbsent,
                            ),
                          )
                        else
                          DataCell(
                            TimePickerCell(
                              onTimeSelected: (TimeOfDay selectedTime) async {
                                await submitDutyAttendance(
                                    participant, selectedTime, false);

                                _fetchedDutyAttendance =
                                    await getDutyAttendanceToday(
                                        parentOrganizationId, workActivityId);

                                setState(() {});
                              },
                              initialTime: null,
                              isButtonEnabled: isAbsent,
                            ),
                          ),
                        if (_fetchedEvaluations
                                .firstWhere(
                                    (evaluation) =>
                                        evaluation.evaluatee_id ==
                                        participant.person!.id!,
                                    orElse: () =>
                                        new Evaluation(evaluatee_id: -1))
                                .evaluatee_id !=
                            -1)
                          DataCell(Checkbox(
                            // Add a Checkbox to the cell
                            value: _fetchedEvaluations
                                    .firstWhere(
                                        (evaluation) =>
                                            evaluation.evaluatee_id ==
                                            participant.person!.id!,
                                        orElse: () =>
                                            new Evaluation(evaluatee_id: -1))
                                    .evaluatee_id !=
                                -1,
                            onChanged: (bool? value) async {
                              await toggleAbsent(participant, value!);

                              _fetchedDutyAttendance =
                                  await getDutyAttendanceToday(
                                      parentOrganizationId, workActivityId);

                              _fetchedEvaluations =
                                  await getActivityInstanceEvaluations(
                                      workActivityInstance.id!);
                              setState(() {});
                            },
                          ))
                        else
                          DataCell(Checkbox(
                            // Add a Checkbox to the cell
                            value: false,
                            onChanged: (bool? value) async {
                              await toggleAbsent(participant, value!);

                              _fetchedDutyAttendance =
                                  await getDutyAttendanceToday(
                                      parentOrganizationId, workActivityId);

                              _fetchedEvaluations =
                                  await getActivityInstanceEvaluations(
                                      workActivityInstance.id!);
                              setState(() {});
                            },
                          ))
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimePickerCell extends StatefulWidget {
  final ValueChanged<TimeOfDay> onTimeSelected;
  final TimeOfDay? initialTime;
  final bool isButtonEnabled;

  TimePickerCell(
      {required this.onTimeSelected,
      this.initialTime,
      required this.isButtonEnabled});

  @override
  State<TimePickerCell> createState() => _TimePickerCellState();
}

class _TimePickerCellState extends State<TimePickerCell> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TimePickerCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the initialTime property has changed
    if (widget.initialTime != oldWidget.initialTime) {
      setState(() {
        _selectedTime = widget.initialTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: widget.isButtonEnabled
                ? null
                : () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      setState(() {
                        _selectedTime = selectedTime;
                      });

                      widget.onTimeSelected(selectedTime);
                    }
                  },
            style: widget.isButtonEnabled
                ? ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 12)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  )
                : ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 12)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.deepPurpleAccent),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
            child: Container(
              width: 85,
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Pick a Time',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
