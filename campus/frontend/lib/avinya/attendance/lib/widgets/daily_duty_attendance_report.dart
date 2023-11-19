import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';
import 'package:gallery/data/person.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:attendance/widgets/date_range_picker.dart';
import 'package:attendance/data.dart';

class DailyDutyAttendanceReport extends StatefulWidget {
  const DailyDutyAttendanceReport({super.key});

  @override
  State<DailyDutyAttendanceReport> createState() =>
      _DailyDutyAttendanceReportState();
}

class _DailyDutyAttendanceReportState extends State<DailyDutyAttendanceReport> {
  List<ActivityAttendance> _fetchedAttendance = [];

  List<Activity>  _activitiesByAvinyaType = [];
  List<DutyParticipant> _dutyParticipantsData = [];

  bool _isFetching = true;
  var activityId = 0;
  bool _isDisplayErrorMessage = false;


  List<String?> columnNames = [];

  late String formattedStartDate;
  late String formattedEndDate;

  late DataTableSource _data;

  //calendar specific variables
  DateTime? _selectedDay;

  void selectDateRange(DateTime today, activityId) async {
    // Update the variables to select the week
    final formatter = DateFormat('MMM d, yyyy');
    formattedStartDate = formatter.format(today);
    formattedEndDate = formatter.format(today);
    setState(() {
      _isFetching = false;
    });
  }

  Future<void> loadActivitiesByAvinyaType() async{

    _activitiesByAvinyaType = await fetchActivitiesByAvinyaType(91); //load avinya type =91(work) related activities
    _activitiesByAvinyaType.removeWhere((activity) => activity.name == 'work');
    
  }

  Future<void> loadDutyParticipantsData() async{

    _dutyParticipantsData = await fetchDutyParticipants(campusAppsPortalInstance.getUserPerson().organization!.id!);
  }

  @override
  void initState() {
    super.initState();
    loadActivitiesByAvinyaType();
    loadDutyParticipantsData();
    var today = DateTime.now();
    activityId = campusAppsPortalInstance.activityIds['work']!;
    selectDateRange(today, activityId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = MyData(
        _fetchedAttendance, columnNames, updateSelected,_activitiesByAvinyaType,_dutyParticipantsData);
    DateRangePicker(updateDateRange, formattedStartDate);
  }

  void updateSelected(int index, bool value, List<bool> selected) {
    setState(() {
      selected[index] = value;
    });
  }

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
          refreshState();
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

  void refreshState() async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });

    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;

    var cols =
        columnNames.map((label) => DataColumn(label: Text(label!))).toList(); 


    _fetchedAttendance = await getLateAttendanceReportByParentOrg(
          parentOrgId!,
          activityId,
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedStartDate)),
          DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM d, yyyy').parse(this.formattedEndDate)));

    if (_fetchedAttendance.length > 0) {
                                
        columnNames.clear();
        List<String?> names = _fetchedAttendance
            .map((attendance) => attendance
                .sign_in_time
                ?.split(" ")[0])
            .where((name) =>
                name !=
                null) // Filter out null values
            .toList();
        columnNames.addAll(names);
      } else {
        columnNames.clear();
     }
      columnNames =
                columnNames.toSet().toList();
      columnNames.sort();
      columnNames.insert(0, "Name");
      columnNames.insert(1, "Digital ID");
      cols = columnNames
          .map((label) =>
              DataColumn(label: Text(label!)))
          .toList();
      print(cols.length);
      if (_fetchedAttendance.length == 0)
              _fetchedAttendance = new List.filled(
                  _dutyParticipantsData.length,
                  new ActivityAttendance(
                      person_id: -1));
      else {
        for (int i = 0;
            i <
                _dutyParticipantsData.length;
            i++) {
          if (_fetchedAttendance.indexWhere(
                  (attendance) =>
                      attendance.person_id ==
                      _dutyParticipantsData[i].person!.id) ==
              -1) {
            _fetchedAttendance.add(
                new ActivityAttendance(
                    person_id: -1));
          }
        }
      }

    setState(() {

      this._isFetching = false;
      _data = MyData(_fetchedAttendance, columnNames,
          updateSelected,_activitiesByAvinyaType,_dutyParticipantsData);
    });
  }

  @override
  Widget build(BuildContext context) {
    
    var cols =
        columnNames.map((label) => DataColumn(label: Text(label!))).toList();

    return SingleChildScrollView(
      child: campusAppsPortalPersonMetaDataInstance
              .getGroups()
              .contains('Student')
          ? Text("Please go to 'Mark Attedance' Page",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold))
          : Wrap(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // create a text widget with some padding

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, top: 20, bottom: 10),
                            child: Row(children: <Widget>[
                              ElevatedButton(
                                style: ButtonStyle(
                                  textStyle: MaterialStateProperty.all(
                                    TextStyle(fontSize: 20),
                                  ),
                                  elevation: MaterialStateProperty.all(20),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.greenAccent),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                ),
                                onPressed: _isFetching
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => DateRangePicker(
                                                  updateDateRange,
                                                  formattedStartDate)),
                                        );
                                      },
                                child: Container(
                                  height: 50, // Adjust the height as needed
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isFetching)
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: SpinKitFadingCircle(
                                            color: Colors
                                                .black, // Customize the color of the indicator
                                            size:
                                                20, // Customize the size of the indicator
                                          ),
                                        ),
                                      if (!_isFetching)
                                        Icon(Icons.calendar_today,
                                            color: Colors.black),
                                      SizedBox(width: 10),
                                      Text(
                                        '${this.formattedStartDate} - ${this.formattedEndDate}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                  ],
                ),
                Wrap(children: [
                  if (_isFetching)
                    Container(
                      margin: EdgeInsets.only(top: 180),
                      child: SpinKitCircle(
                        color: (Colors
                            .blue), // Customize the color of the indicator
                        size: 50, // Customize the size of the indicator
                      ),
                    )
                  else if (_fetchedAttendance.length > 0)
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: PaginatedDataTable(
                        showCheckboxColumn: false,
                        source: _data,
                        columns: cols,
                        // header: const Center(child: Text('Daily Attendance')),
                        columnSpacing: 100,
                        horizontalMargin: 60,
                        rowsPerPage: 25,
                      ),
                    )
                  else
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Text('No duty attendance data found'),
                    ),
                ]),
              ],
            ),
    );
  }
}

class MyData extends DataTableSource {
  MyData(this._fetchedAttendance, this.columnNames,
      this.updateSelected,this._activitiesByAvinyaType,this._dutyParticipantsData) {
    columnNames.sort((a, b) => b!.compareTo(a!));
  }

  final List<ActivityAttendance> _fetchedAttendance;
  final List<String?> columnNames;
  final List<Activity>  _activitiesByAvinyaType;
  List<DutyParticipant> _dutyParticipantsData;
  final Function(int, bool, List<bool>) updateSelected;
  List<DutyParticipant> filterParticularDutyActivityParticipants = [];
  int listIndex=0;
  int incrementActivityIdListIndex=0;
  Activity? activity;

  @override
  DataRow? getRow(int index) {

  
    if (index == 0 ) {
      List<DataCell> cells = new List.filled(
        columnNames.toSet().toList().length,
        new DataCell(Container(child: Text("Absent"), color: Colors.red)),
      );
        cells[0] = DataCell(Text(''));
        cells[1] = DataCell(Text(''));
        for (final date in columnNames) {
          print("date ${date}");
          if (columnNames.indexOf(date) == 0 ||
              columnNames.indexOf(date) == 1) {
            continue;
          }

          date == '$date 00:00:00';
          cells[columnNames.indexOf(date)] = DataCell(Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Text(DateFormat.EEEE().format(DateTime.parse(date!)),
                style: TextStyle(
                  color: Color.fromARGB(255, 14, 72, 90),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ));
        }
      
      listIndex= 0;
      incrementActivityIdListIndex=0;

      activity = _activitiesByAvinyaType[incrementActivityIdListIndex];

      filterParticularDutyActivityParticipants = 
                            _dutyParticipantsData.where((participant) => participant.activity!.id == activity!.id)
                            .toList();

      return DataRow(
        cells: cells,
      );
    }
    if(index==1){
       List<DataCell> cells = new List.filled(
        columnNames.toSet().toList().length,
        new DataCell(Container(
            alignment: Alignment.center,
            child: Text("",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )))),
      );

        cells[0] = DataCell(Text(''));
        cells[1] = DataCell(Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          child: Text('${activity!.name}',
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ));
       return DataRow(
        color: MaterialStateProperty.all(Colors.blue[100]),
        cells: cells,
      );
    }

  if(_activitiesByAvinyaType.isNotEmpty &&
     _dutyParticipantsData.isNotEmpty &&  
      columnNames.length > 0) {

    if(listIndex < filterParticularDutyActivityParticipants.length){

      List<DataCell> cells = new List.filled(
        columnNames.toSet().toList().length,
        new DataCell(Container(
            alignment: Alignment.center,
            child: Text("Absent",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )))),
      );

      var dutyParticipant = filterParticularDutyActivityParticipants[listIndex];

      cells[0] = DataCell(Text(dutyParticipant.person!.preferred_name.toString()));
      cells[1] = DataCell(Text(dutyParticipant.person!.digital_id.toString()));

      for (final attendance in _fetchedAttendance) {
        if (attendance.person_id == dutyParticipant.person!.id) {
          for (final date in columnNames) {
            print("split date:${dutyParticipant.person!.preferred_name}==${date}==,${attendance.sign_in_time!.split(" ")[0]}");
            if (attendance.sign_in_time != null &&
                attendance.sign_in_time!.split(" ")[0] == date) {
              cells[columnNames.indexOf(date)] = DataCell(Container(
                  alignment: Alignment.center, child: Text("Present")));
            }
          }
        }
      }


      listIndex++;

      int numItems = _dutyParticipantsData.length+_activitiesByAvinyaType.length;
      List<bool> selected = List<bool>.generate(numItems, (int index) => false);
      return DataRow(
        cells: cells,
        onSelectChanged: (value) {
          updateSelected(index, value!,
              selected); // Call the callback to update the selected state
        },
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.grey.withOpacity(0.4);
          }
          if (index.isEven) {
            return Colors.grey.withOpacity(0.2);
          }
          return null;
        }),
      );
    }else{
     incrementActivityIdListIndex++;
     if(incrementActivityIdListIndex < _activitiesByAvinyaType.length){

      filterParticularDutyActivityParticipants.clear();
      activity = _activitiesByAvinyaType[incrementActivityIdListIndex];
      filterParticularDutyActivityParticipants = 
                            _dutyParticipantsData.where((participant) => participant.activity!.id == activity!.id)
                            .toList();
      listIndex=0;
      
      List<DataCell> cells = new List.filled(columnNames.toSet().toList().length,new DataCell(Container(
            alignment: Alignment.center,
            child: Text("",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )))),
      );
        cells[0] = DataCell(Text(''));
        cells[1] = DataCell(Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          child: Text('${activity!.name}',
              style: TextStyle(
                color: Color.fromARGB(255, 14, 72, 90),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ));
        return DataRow(
        color: MaterialStateProperty.all(Colors.blue[100]),
        cells: cells,
      );
     }else{
       return null;
     }

    }
  }  
  return null;
}

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount {
    int count = 0;
    count = _dutyParticipantsData.length+1 ?? 0;
    count += _activitiesByAvinyaType.length; //to facilitate additional rows

    return count;
  }

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
