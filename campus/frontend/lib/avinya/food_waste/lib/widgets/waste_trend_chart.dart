import 'package:flutter/material.dart';
import '../data/analytics.dart';

class WasteTrendChart extends StatefulWidget {
  const WasteTrendChart({super.key});

  @override
  State<WasteTrendChart> createState() => _WasteTrendChartState();
}

class _WasteTrendChartState extends State<WasteTrendChart> {
  late Future<List<DailyWasteData>> _wasteDataFuture;

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  // Reload data every time the widget is rebuilt
  @override
  void didUpdateWidget(WasteTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadWasteData();
  }

  void _loadWasteData() {
    _wasteDataFuture = AnalyticsService.fetchMockLast7DaysWaste();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waste Cost Trend (Last 7 Days)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<DailyWasteData>>(
                future: _wasteDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'Failed to load chart data',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final wasteData = snapshot.data!;

                  if (wasteData.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  // Reverse the data so most recent dates are on the right
                  final reversedData = wasteData.reversed.toList();

                  return CustomPaint(
                    painter: _WasteAmountTrendPainter(
                      reversedData.map((data) => _ChartDataPoint(
                        date: _formatDate(data.date),
                        amount: data.totalWaste,
                      )).toList(),
                    ),
                    child: Container(),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ChartDataPoint {
  final String date;
  final double amount;

  _ChartDataPoint({required this.date, required this.amount});
}

class _WasteAmountTrendPainter extends CustomPainter {
  final List<_ChartDataPoint> data;

  _WasteAmountTrendPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.shade200.withValues(alpha: 0.3),
          Colors.green.shade100.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Find max amount for scaling
    final maxAmount = data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    final minAmount = data.map((d) => d.amount).reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;
    
    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedAmount = range > 0 ? (data[i].amount - minAmount) / range : 0.5;
      final y = size.height - (normalizedAmount * size.height * 0.8 + size.height * 0.1);
      points.add(Offset(x, y));
    }

    // Draw gradient area under the line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, size.height);
      path.lineTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      path.lineTo(points.last.dx, size.height);
      path.close();
      canvas.drawPath(path, gradientPaint);
    }

    // Draw the line
    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(linePath, paint);
    }

    // Draw points with values
    final pointPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < points.length; i++) {
      // Draw circle
      canvas.drawCircle(points[i], 4, pointPaint);
      
      // Draw border
      canvas.drawCircle(points[i], 4, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      
      // Draw cost value above point
      if (data[i].amount > 0) {
        textPainter.text = TextSpan(
          text: 'LKR ${data[i].amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        
        final textOffset = Offset(
          points[i].dx - textPainter.width / 2,
          points[i].dy - textPainter.height - 8,
        );
        
        textPainter.paint(canvas, textOffset);
      }
      
      // Draw date below point
      textPainter.text = TextSpan(
        text: data[i].date,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      
      final dateOffset = Offset(
        points[i].dx - textPainter.width / 2,
        points[i].dy + 12,
      );
      
      textPainter.paint(canvas, dateOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}