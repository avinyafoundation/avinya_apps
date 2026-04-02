import 'package:flutter/material.dart';
import '../data/analytics.dart';

class TopItemsList extends StatefulWidget {
  const TopItemsList({super.key});

  @override
  State<TopItemsList> createState() => _TopItemsListState();
}

class _TopItemsListState extends State<TopItemsList> {
  late Future<List<TopWastedItem>> _topWastedItemsFuture;

  @override
  void initState() {
    super.initState();
    _topWastedItemsFuture = AnalyticsService.fetchTopWastedItems(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 3 Most Wasted Items (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<TopWastedItem>>(
              future: _topWastedItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load waste data',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final topWastedItems = snapshot.data!;

                if (topWastedItems.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No waste data available yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final colors = [Colors.red, Colors.orange, Colors.amber];

                return Column(
                  children: topWastedItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index < topWastedItems.length - 1 ? 8 : 0),
                      child: _buildWasteItem(
                        '${index + 1}',
                        item.foodName,
                        '${item.totalPortions} portions',
                        'LKR ${item.totalCost.toStringAsFixed(1)}',
                        colors[
                            index < colors.length ? index : colors.length - 1],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteItem(
      String rank, String item, String portions, String cost, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            rank,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                portions,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          cost,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
