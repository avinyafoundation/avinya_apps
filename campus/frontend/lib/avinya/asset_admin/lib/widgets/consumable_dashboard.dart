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
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 25.0),
            child: LatestConsumableData(),
          ),
        ),
        Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 25.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConsumableBarChart()),
            ))
      ],
    );
  }
}
