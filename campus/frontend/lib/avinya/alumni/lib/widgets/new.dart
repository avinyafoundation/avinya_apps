import 'package:flutter/material.dart';

class AlumniStatusCards extends StatelessWidget {
  final Map<String, int> alumniCounts = {
    "Studying": 45,
    "Working": 30,
    "Not Working": 10,
    "Abroad": 15,
    "Inactive": 5,
  };

  final Map<String, IconData> icons = {
    "Studying": Icons.school,
    "Working": Icons.work,
    "Not Working": Icons.hourglass_empty,
    "Abroad": Icons.flight_takeoff,
    "Inactive": Icons.pause_circle_filled,
  };

  final Map<String, Color> colors = {
    "Studying": Colors.blueAccent,
    "Working": Colors.green,
    "Not Working": Colors.orange,
    "Abroad": Colors.purple,
    "Inactive": Colors.redAccent,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alumni Status")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two cards per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2, // Adjusts card size
          children: alumniCounts.keys.map((status) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              color: colors[status], // Different colors per status
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[status], size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${alumniCounts[status]} Batch",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
