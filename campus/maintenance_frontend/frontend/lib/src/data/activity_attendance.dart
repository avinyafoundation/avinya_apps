import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../config/app_config.dart';

class ActivityAttendance {
  int? id;
  int? activity_instance_id;
  int? person_id;
  String? created;
  String? updated;
  String? sign_in_time;
  String? sign_out_time;
  String? in_marked_by;
  String? out_marked_by;
  bool? selected = false;
  int? person;
  String? description;
  String? preferred_name;
  String? digital_id;
  int? present_count;
  String? svg_src;
  int? color;
  int? total_student_count;
  int? daily_total;
  String? attendance_date;
  double? y;
  double? x;
  String? sign_in_date;
  int? late_count;
  int? absent_count;
  int? total_count;
  double? present_attendance_percentage;
  double? late_attendance_percentage;

  ActivityAttendance(
      {this.id,
      this.activity_instance_id,
      this.person_id,
      this.created,
      this.updated,
      this.sign_in_time,
      this.sign_out_time,
      this.in_marked_by,
      this.out_marked_by,
      this.person,
      this.description,
      this.preferred_name,
      this.digital_id,
      this.present_count,
      this.svg_src,
      this.color,
      this.total_student_count,
      this.daily_total,
      this.attendance_date,
      this.x,
      this.y,
      this.sign_in_date,
      this.late_count,
      this.absent_count,
      this.total_count,
      this.present_attendance_percentage,
      this.late_attendance_percentage});

  factory ActivityAttendance.fromJson(Map<String, dynamic> json) {
    return ActivityAttendance(
        id: json['id'],
        activity_instance_id: json['activity_instance_id'],
        person_id: json['person_id'],
        created: json['created'],
        updated: json['updated'],
        sign_in_time: json['sign_in_time'],
        sign_out_time: json['sign_out_time'],
        in_marked_by: json['in_marked_by'],
        out_marked_by: json['out_marked_by'],
        preferred_name: json['preferred_name'],
        digital_id: json['digital_id'],
        description: json['description'],
        person: json['person'] != null ? json['person']['id'] : null,
        present_count: json['present_count'],
        svg_src: json['svg_src'],
        color: json['color'] != null
            ? int.parse(json['color'].substring(2), radix: 16)
            : 0xFFFFFFFF, // Assuming 0xFFFFFFFF as default
        total_student_count: json['total_student_count'],
        daily_total: json['daily_total'],
        attendance_date: json['attendance_date'],
        x: json['attendance_date'] != null
            ? DateTime.parse(json['attendance_date'])
                .millisecondsSinceEpoch
                .toDouble()
            : 0.0,
        y: json['daily_total']?.toDouble() ?? 0.0,
        sign_in_date: json['sign_in_date'],
        late_count: json['late_count'],
        absent_count: json['absent_count'],
        total_count: json['total_count'],
        present_attendance_percentage: json['present_attendance_percentage'],
        late_attendance_percentage: json['late_attendance_percentage']);
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (activity_instance_id != null)
          'activity_instance_id': activity_instance_id,
        if (person_id != null) 'person_id': person_id,
        if (created != null) 'created': created,
        if (updated != null) 'updated': updated,
        if (sign_in_time != null) 'sign_in_time': sign_in_time,
        if (sign_out_time != null) 'sign_out_time': sign_out_time,
        if (in_marked_by != null) 'in_marked_by': in_marked_by,
        if (out_marked_by != null) 'out_marked_by': out_marked_by,
        if (preferred_name != null) 'preferred_name': preferred_name,
        if (digital_id != null) 'digital_id': digital_id,
        if (description != null) 'description': description,
        if (person != null) 'person': person,
      };

  static Color? _parseColor(String? colorString) {
    if (colorString == null) {
      return null;
    }

    final hexColorRegExp = RegExp(r'^#?([0-9a-fA-F]{6})$');
    if (!hexColorRegExp.hasMatch(colorString)) {
      // Invalid hex color code, handle accordingly
      print("Invalid hex color code: $colorString");
      return null; // or return a default color, like Colors.grey
    }

    try {
      // Assuming colorString is a hex color representation
      return Color(int.parse(colorString.replaceAll("#", ""), radix: 16));
    } catch (e) {
      // Handle the exception, e.g., return a default color or null
      print("Error parsing color: $e");
      return null; // or return a default color, like Colors.grey
    }
  }
}

Future<ActivityAttendance> createActivityAttendance(
    ActivityAttendance activityAttendance) async {
  final response = await http.post(
    Uri.parse('${AppConfig.campusAttendanceBffApiUrl}/activity_attendance'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'api-key': AppConfig.attendanceAppBffApiKey,
    },
    body: jsonEncode(activityAttendance.toJson()),
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    return ActivityAttendance.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create Activity Participant Attendance.');
  }
}

class BatchPaymentPlan {
  int? id;
  int? organization_id;
  int? batch_id;
  double? monthly_payment_amount;
  String? valid_from;
  String? valid_to;
  String? created;

  BatchPaymentPlan(
      {required this.id,
      required this.organization_id,
      required this.batch_id,
      required this.monthly_payment_amount,
      required this.valid_from,
      required this.valid_to
      });

  factory BatchPaymentPlan.fromJson(Map<String, dynamic> json) {
    return BatchPaymentPlan(
        id: json['id'],
        organization_id: json['organization_id'],
        batch_id: json['batch_id'],
        monthly_payment_amount: json['monthly_payment_amount'],
        valid_from:json['valid_from'],
        valid_to: json['valid_to']
        );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (organization_id != null) 'organization_id': organization_id,
        if (batch_id != null) 'batch_id': batch_id,
        if (monthly_payment_amount != null)
          'monthly_payment_amount': monthly_payment_amount,
        if (valid_from != null)
          'valid_from': valid_from,
        if (valid_to != null)
          'valid_to': valid_to
      };
}

class LeaveDate {
  final int id;
  final DateTime date;
  final double dailyAmount;
  final DateTime created;
  final DateTime updated;
  final int organizationId;
  final int batch_id;

  LeaveDate({
    required this.id,
    required this.date,
    required this.dailyAmount,
    required this.created,
    required this.updated,
    required this.organizationId,
    required this.batch_id
  });
}

Future<List<ActivityAttendance>> getDailyStudentsAttendanceByParentOrg(
  int? parent_organization_id,
) async {
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/daily_students_attendance_by_parent_org/$parent_organization_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'api-key': AppConfig.attendanceAppBffApiKey,
    },
  );
  if (response.statusCode > 199 && response.statusCode < 300) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ActivityAttendance> activityAttendances = await resultsJson
        .map<ActivityAttendance>((json) => ActivityAttendance.fromJson(json))
        .toList();
    return activityAttendances;
  } else {
    throw Exception(
        'Failed to get Activity Participant Attendances  by parent org');
  }
}

Future<List<Map<String, dynamic>>> getLateAttendanceSummary(
  int organizationId,
  int activityId,
) async {
  final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  final response = await http.get(
    Uri.parse(
        '${AppConfig.campusAttendanceBffApiUrl}/organizations/$organizationId/late-attendance-summary?date=$dateStr&activity_id=$activityId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'api-key': AppConfig.attendanceAppBffApiKey,
    },
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to get Late Attendance Summary');
  }
}