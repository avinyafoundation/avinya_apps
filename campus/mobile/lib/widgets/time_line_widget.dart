import 'package:flutter/material.dart';

class TimelineWidget extends StatelessWidget {
  final List<Map<String, String>> workTimeline = [
    {
      "title": "Software Engineer",
      "company": "Google",
      "duration": "2020 - Present"
    },
    {
      "title": "Data Analyst",
      "company": "Microsoft",
      "duration": "2018 - 2020"
    },
    {"title": "Intern", "company": "IBM", "duration": "2016 - 2018"},
    {
      "title": "Project Manager",
      "company": "Amazon",
      "duration": "2015 - 2016"
    },
    {
      "title": "Research Assistant",
      "company": "MIT",
      "duration": "2013 - 2015"
    },
  ];

  final List<Map<String, String>> educationTimeline = [
    {
      "title": "MSc in Data Science",
      "institution": "Stanford University",
      "duration": "2019 - Present"
    },
    {
      "title": "BSc in Computer Science",
      "institution": "MIT",
      "duration": "2012 - 2016"
    },
    {
      "title": "High School Diploma",
      "institution": "XYZ High School",
      "duration": "2008 - 2012"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Text("Your Work & Study Timeline",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: workTimeline
                    .map((item) => _buildTimelineItem(item['title']!,
                        item['company']!, item['duration']!, true))
                    .toList(),
              ),
              _buildTimelineArrow(),
              Column(
                children: educationTimeline
                    .map((item) => _buildTimelineItem(item['title']!,
                        item['institution']!, item['duration']!, false))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String subtitle, String duration, bool isTop) {
    return Column(
      children: [
        if (isTop) _buildConnector(),
        Container(
          width: 150,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          ),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              Text(duration,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
            ],
          ),
        ),
        if (!isTop) _buildConnector(),
      ],
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
