// AttendanceMarker screen class

import 'package:attendance/widgets/attedance_marker.dart';
import 'package:flutter/material.dart';
import '../widgets/person_attendance_report.dart';

class AttendanceMarkerScreen extends StatefulWidget {
  const AttendanceMarkerScreen({Key? key}) : super(key: key);

  @override
  _AttendanceMarkerScreenState createState() => _AttendanceMarkerScreenState();
}

class _AttendanceMarkerScreenState extends State<AttendanceMarkerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1600),
            padding: EdgeInsets.all(isMobile ? 20 : 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Person Attendance Report Card
                Container(
                  padding: const EdgeInsets.all(25),
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
                      // Card Title
                      Container(
                        padding: const EdgeInsets.only(bottom: 15),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Color(0xFFECF0F1))),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.person_search,
                              color: Color(0xFF1BB6E8),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Person Attendance Report',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Person Attendance Report Widget
                      SizedBox(
                        width: double.infinity,
                        height: 500,
                        child: PersonAttendanceMarkerReport(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
