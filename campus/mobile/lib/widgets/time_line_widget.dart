import 'package:flutter/material.dart';

class TimelineWidget extends StatelessWidget {
  final List<Map<String, String>> workTimeline;
  final List<Map<String, String>> educationTimeline;
  final Function(Map<String, String> item, String type) onItemTap;

  const TimelineWidget({
    Key? key,
    required this.workTimeline,
    required this.educationTimeline,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Text(
            "Your Work & Study Timeline",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: workTimeline
                    .map((item) => _buildTimelineItem(item, true))
                    .toList(),
              ),
              _buildTimelineArrow(),
              Column(
                children: educationTimeline
                    .map((item) => _buildTimelineItem(item, false))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, String> item, bool isTop) {
    return GestureDetector(
      onTap: () => onItemTap(item, isTop ? 'work' : 'education'),
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
                Text(item['title'] ?? 'No Title',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(item['subtitle'] ?? 'No Subtitle',
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                Text(item['duration'] ?? 'No Duration',
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
      color: Colors.blue,
    );
  }

  Widget _buildTimelineArrow() {
    return Column(
      children: [
        Container(
          width: 5,
          height: 100,
          color: Colors.blue,
        ),
        Icon(Icons.arrow_downward, color: Colors.blue),
      ],
    );
  }
}
