import 'package:flutter/material.dart';

class TimelineWidget extends StatelessWidget {
  final String personName;
  final List<Map<String, Object>> workTimeline;
  final List<Map<String, Object>> educationTimeline;
  final Function(Map<String, String> item, String type) onItemTap;

  const TimelineWidget({
    Key? key,
    required this.personName,
    required this.workTimeline,
    required this.educationTimeline,
    required this.onItemTap,
  }) : super(key: key);

  DateTime _parseStartDate(String duration) {
    // Extracting the start date from the duration string.
    try {
      // Assuming the duration is in the format "YYYY-MM-DD - YYYY-MM-DD" or "YYYY-MM-DD - Present"
      final startDate = duration.split(' - ')[0];
      return DateTime.parse(startDate);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(1970, 1, 1); // Default value in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort workTimeline by the start date
    List<Map<String, Object>> sortedWorkTimeline = List.from(workTimeline);
    sortedWorkTimeline.sort((a, b) => _parseStartDate(a['duration'] as String)
        .compareTo(_parseStartDate(b['duration'] as String)));
    // Sort EducationTimeline by the start date
    List<Map<String, Object>> sortedEducationTimelineTimeline =
        List.from(educationTimeline);
    sortedWorkTimeline.sort((a, b) => _parseStartDate(a['duration'] as String)
        .compareTo(_parseStartDate(b['duration'] as String)));
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Text("${personName} Work & Study Timeline",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: sortedWorkTimeline
                    .map((item) => _buildWorkTimelineItem(item, true))
                    .toList(),
              ),
              _buildTimelineArrow(),
              Column(
                children: sortedEducationTimelineTimeline
                    .map((item) => _buildEduTimelineItem(item, false))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTimelineItem(Map<String, Object> item, bool isTop) {
    return GestureDetector(
      // onTap: () => onItemTap(item, isTop ? 'work' : 'education'),
      onTap: () => onItemTap(
        item.map((key, value) =>
            MapEntry(key, value.toString())), // Convert Object to String
        isTop ? 'work' : 'education',
      ),
      child: Column(
        children: [
          if (isTop) _buildConnector(),
          Container(
            width: 150,
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
              ],
            ),
            child: Column(
              children: [
                Text(item['title'] as String? ?? 'No Title',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(item['company'] as String? ?? 'No Subtitle',
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                Text(item['duration'] as String? ?? 'No Duration',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ),
          if (!isTop) _buildConnector(),
        ],
      ),
    );
  }

  Widget _buildEduTimelineItem(Map<String, Object> item, bool isTop) {
    return GestureDetector(
      onTap: () => onItemTap(
        item.map((key, value) =>
            MapEntry(key, value.toString())), // Convert Object to String
        isTop ? 'work' : 'education',
      ),
      child: Column(
        children: [
          if (isTop) _buildConnector(),
          Container(
            width: 150,
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
              ],
            ),
            child: Column(
              children: [
                Text(item['course']?.toString() ?? 'No Title',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(item['university']?.toString() ?? 'No Subtitle',
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                Text(item['duration']?.toString() ?? 'No Duration',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ),
          if (!isTop) _buildConnector(),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 2,
      height: 40,
      color: Colors.black,
    );
  }

  Widget _buildTimelineArrow() {
    return Column(
      children: [
        Container(
          width: 5,
          height: 100,
          color: Colors.black,
        ),
        Icon(Icons.arrow_downward, color: Colors.black),
      ],
    );
  }
}
