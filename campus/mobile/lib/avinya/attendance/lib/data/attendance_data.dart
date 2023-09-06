// ignore_for_file: non_constant_identifier_names

class AttendanceData {
  final int? activity_instance_id;
  final int? person_id;
  final String? preferred_name;
  final String? organization;
  final String sign_in_time;
  final String sign_out_time;
  final String? in_marked_by;

  AttendanceData({
    required this.activity_instance_id,
    required this.person_id,
    required this.preferred_name,
    required this.organization,
    required this.sign_in_time,
    required this.sign_out_time,
    required this.in_marked_by,
  });

  // Factory constructor for deserialization
  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      activity_instance_id: json['activity_instance_id'],
      person_id: json['person_id'],
      preferred_name: json['preferred_name'],
      organization: json['organization'],
      sign_in_time: json['sign_in_time'],
      sign_out_time: json['sign_out_time'],
      in_marked_by: json['in_marked_by'],
    );
  }

  // Method to convert the object to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'activity_instance_id': activity_instance_id,
      'person_id': person_id,
      'preferred_name': preferred_name,
      'organization': organization,
      'sign_in_time': sign_in_time,
      'sign_out_time': sign_out_time,
      'in_marked_by': in_marked_by,
    };
  }
}
