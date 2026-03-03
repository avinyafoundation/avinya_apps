import 'package:flutter/material.dart';

class CostBreakdownDialog extends StatelessWidget {
  final Color primaryText;
  final Color secondaryText;
  final List<Map<String, String>> costItems;
  final String totalCost;

  const CostBreakdownDialog({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    required this.costItems,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cost Breakdown",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ...costItems.map((item) => _buildCostItem(
                        item['name']!,
                        item['cost']!,
                      )),
                  const Divider(height: 32),
                  ListTile(
                    title: const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      totalCost,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(String name, String cost) {
    return ListTile(
      leading: const Icon(Icons.receipt_long, color: Colors.blue),
      title: Text(name, style: TextStyle(color: primaryText)),
      trailing: Text(
        cost,
        style: TextStyle(fontWeight: FontWeight.w600, color: primaryText),
      ),
    );
  }
}
