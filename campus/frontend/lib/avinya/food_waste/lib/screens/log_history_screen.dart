import 'package:flutter/material.dart';
import '../data/food_waste.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/button.dart';
import 'log_waste.dart';

class LogHistoryScreen extends StatefulWidget {
  const LogHistoryScreen({super.key});

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen> {
  late Future<List<MealServing>> _mealServingsFuture;

  @override
  void initState() {
    super.initState();
    _loadMealServings();
  }

  void _loadMealServings() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _mealServingsFuture = MealServingService.fetchMealServings(
      organizationId: 2,
      offset: 0,
      limit: 100,
      fromDate: '2025-01-01',
      toDate: todayStr,
    );
  }

  void _refresh() {
    setState(() {
      _loadMealServings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<MealServing>>(
        future: _mealServingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.error_outline,
                          color: Colors.red[400], size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to load waste history',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Button(
                      label: 'Retry',
                      onPressed: _refresh,
                      buttonColor: Colors.blue[700],
                      textColor: Colors.white,
                      height: 40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            );
          }

          final mealServings = snapshot.data ?? [];

          return Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Title & Refresh
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PageTitle(
                            title: 'Waste History',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172B4D),
                          ),
                          IconButton(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Empty State
                      if (mealServings.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.history,
                                  size: 56, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No waste logs recorded yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Waste logs will appear here once created',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // History Table
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                    topRight: Radius.circular(7),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 44),
                                    Expanded(
                                      flex: 2,
                                      child: Text('Date',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text('Meal Type',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('Served',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                          textAlign: TextAlign.center),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('Items',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                          textAlign: TextAlign.center),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text('Waste Cost (LKR)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                          textAlign: TextAlign.right),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Text('Top Items',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ),
                                    ),
                                    SizedBox(width: 50),
                                  ],
                                ),
                              ),

                              // Table Rows
                              ...List.generate(mealServings.length, (index) {
                                final serving = mealServings[index];
                                final itemsCount = serving.foodWastes.length;
                                final totalCost =
                                    serving.foodWastes.fold<double>(
                                  0,
                                  (sum, waste) =>
                                      sum +
                                      (waste.portions *
                                          waste.foodItem.costPerPortion),
                                );
                                final topItems = serving.foodWastes
                                    .take(3)
                                    .map((waste) => waste.foodItem.name)
                                    .join(', ');

                                final mealTypeCapitalized =
                                    serving.mealType[0].toUpperCase() +
                                        serving.mealType.substring(1);

                                return InkWell(
                                  onTap: () {
                                    if (serving.id != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LogWasteScreen(
                                            logData: serving.toJson(),
                                            onSave: _refresh,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Row(
                                      children: [
                                        // Icon
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.restaurant_menu,
                                            size: 18,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Date
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            serving.date,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        // Meal Type
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: mealTypeCapitalized ==
                                                          'Breakfast'
                                                      ? Colors.blue[50]
                                                      : Colors.orange[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  mealTypeCapitalized,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        mealTypeCapitalized ==
                                                                'Breakfast'
                                                            ? Colors.blue[700]
                                                            : Colors
                                                                .orange[700],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Served
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${serving.servedCount}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // Items Count
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '$itemsCount',
                                            style:
                                                const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // Total Cost
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            totalCost.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red[600],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        // Top Items
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              topItems,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Chevron
                                        SizedBox(
                                          width: 50,
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
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
        },
      ),
    );
  }
}
