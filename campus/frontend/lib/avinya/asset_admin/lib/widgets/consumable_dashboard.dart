import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'consumable_bar_chart.dart';
import 'latest_consumable_data.dart';

class ConsumableDashboard extends StatefulWidget {
  const ConsumableDashboard({super.key});

  @override
  State<ConsumableDashboard> createState() => _ConsumableDashboardState();
}

class _ConsumableDashboardState extends State<ConsumableDashboard> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.grey[200],
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 25.0),
              child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
                  // color: Colors.white,
                  child: LatestConsumableData()),
            ),
          ),
          Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 25.0, right: 5.0),
                child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
                    //color: Colors.white,
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.8,
                    child: ConsumableBarChart()),
              ))
        ],
      ),
    );
  }
}
