import 'package:flutter/material.dart';
import 'package:gallery/avinya/food_waste/lib/widgets/top_items_list.dart';
import 'package:gallery/avinya/food_waste/lib/widgets/waste_trend_chart.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/kpi_card.dart';
import '../widgets/common/button.dart';
import '../data/analytics.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<AnalyticsData> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    _analyticsFuture = AnalyticsService.fetchMockAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<AnalyticsData>(
        future: _analyticsFuture,
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
                      'Failed to load dashboard data',
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
                      onPressed: () {
                        setState(() {
                          _loadAnalytics();
                        });
                      },
                      buttonColor: Colors.blue[700],
                      textColor: Colors.white,
                      height: 48,
                      width: 100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            );
          }

          final analytics = snapshot.data!;

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
                      const PageTitle(
                        title: 'Food Waste Dashboard',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
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

                      // KPI Cards Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final card1 = KpiCard(
                            title: 'Avg Daily Waste Cost (Last Month)',
                            value:
                                'LKR ${analytics.averageDailyWasteCost.toStringAsFixed(2)}',
                            icon: Icons.trending_down,
                            iconColor: Colors.orange,
                            bgColor: Colors.orange[50]!,
                          );

                          final card2 = KpiCard(
                            title: 'Avg Weekly Total Cost (Last Month)',
                            value:
                                'LKR ${analytics.weeklyTotalCost.toStringAsFixed(2)}',
                            icon: Icons.calendar_today,
                            iconColor: Colors.red,
                            bgColor: Colors.red[50]!,
                          );

                          if (constraints.maxWidth > 600) {
                            return Row(
                              children: [
                                Expanded(child: card1),
                                const SizedBox(width: 16),
                                Expanded(child: card2),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              card1,
                              const SizedBox(height: 16),
                              card2,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Chart and Top Items - responsive layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildChartCard(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildTopItemsCard(),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildChartCard(),
                              const SizedBox(height: 16),
                              _buildTopItemsCard(),
                            ],
                          );
                        },
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

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WasteTrendChart(),
        ],
      ),
    );
  }

  Widget _buildTopItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopItemsList(),
        ],
      ),
    );
  }
}
