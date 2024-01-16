// import 'package:attendance/responsive.dart';
import 'package:flutter/material.dart';
import 'package:gallery/avinya/attendance/lib/screens/dashboard/components/my_fields.dart';
import 'package:gallery/avinya/attendance/lib/screens/responsive.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import './constants.dart';
// import 'components/header.dart';

import 'components/recent_files.dart';
import 'components/storage_details.dart';
import 'package:gallery/data/person.dart';
import 'package:gallery/data/campus_apps_portal.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(),
                      SizedBox(height: defaultPadding),
                      RecentFiles(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) StorageDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: StorageDetails(),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
