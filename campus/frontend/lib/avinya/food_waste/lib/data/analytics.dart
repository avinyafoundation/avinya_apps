import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gallery/config/app_config.dart';
import 'dummy_data.dart';

class AnalyticsData {
  final double averageDailyWasteCost;
  final double weeklyTotalCost;

  AnalyticsData({
    required this.averageDailyWasteCost,
    required this.weeklyTotalCost,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      averageDailyWasteCost:
          (json['average_daily_waste_cost'] ?? 0.0).toDouble(),
      weeklyTotalCost: (json['weekly_total_cost'] ?? 0.0).toDouble(),
    );
  }
}

class TopWastedItem {
  final int foodId;
  final String foodName;
  final int totalPortions;
  final double totalCost;

  TopWastedItem({
    required this.foodId,
    required this.foodName,
    required this.totalPortions,
    required this.totalCost,
  });

  factory TopWastedItem.fromJson(Map<String, dynamic> json) {
    return TopWastedItem(
      foodId: json['food_item_id'] ?? 0,
      foodName: json['food_name'] ?? '',
      totalPortions: json['total_portions'] ?? 0,
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'total_portions': totalPortions,
      'total_cost': totalCost,
    };
  }
}

class DailyWasteData {
  final String date;
  final double totalWaste;

  DailyWasteData({
    required this.date,
    required this.totalWaste,
  });

  factory DailyWasteData.fromJson(Map<String, dynamic> json) {
    return DailyWasteData(
      date: json['date'],
      totalWaste: (json['total_waste'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_waste': totalWaste,
    };
  }
}

class AnalyticsService {
  static String baseUrl = AppConfig.campusFoodWasteBffApiUrl;

  static Future<AnalyticsData> fetchAnalytics({int days = 30}) async {
    try {
      final uri = Uri.parse('$baseUrl/analytics/summary')
          .replace(queryParameters: {'days': days.toString()});
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> analyticsData =
            responseData['getAnalyticsData'] ?? {};
        print('Fetched analytics data: $analyticsData');
        return AnalyticsData.fromJson(analyticsData);
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to load analytics data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error fetching analytics data: $e');
    }
  }

  static Future<List<TopWastedItem>> fetchTopWastedItems(
      {int limit = 5}) async {
    try {
      final uri = Uri.parse('$baseUrl/analytics/top_wasted')
          .replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> items =
            responseData['top_wasted_items_recent_week'] ?? [];
        final topWastedItems =
            items.map((json) => TopWastedItem.fromJson(json)).toList();
        print('Fetched top wasted items: ${topWastedItems.length} items');
        return topWastedItems;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to load top wasted items: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error fetching top wasted items: $e');
    }
  }

  static Future<List<DailyWasteData>> fetchLast7DaysWaste() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/analytics/last_7_days'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final wasteData =
            data.map((json) => DailyWasteData.fromJson(json)).toList();
        print('Fetched last 7 days waste data: $wasteData');
        return wasteData;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to load last 7 days waste data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error fetching last 7 days waste data: $e');
    }
  }

  static Future<List<DailyWasteData>> fetchDailyWaste({int days = 7}) async {
    try {
      final uri = Uri.parse('$baseUrl/analytics/waste')
          .replace(queryParameters: {'days': days.toString()});
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> items = responseData['daily_waste'] ?? [];
        final wasteData =
            items.map((json) => DailyWasteData.fromJson(json)).toList();
        print('Fetched $days days waste data: ${items.length} entries');
        return wasteData;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to load waste data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error fetching waste data: $e');
    }
  }

  static Future<AnalyticsData> fetchMockAnalytics() async {
    await Future.delayed(Duration(seconds: 1));
    final Map<String, dynamic> data = json.decode(analyticsResponse);
    return AnalyticsData.fromJson(data);
  }

  static Future<List<DailyWasteData>> fetchMockLast7DaysWaste() async {
    await Future.delayed(Duration(seconds: 1));
    final List<dynamic> data = json.decode(last7DaysWasteResponse);
    return data.map((json) => DailyWasteData.fromJson(json)).toList();
  }

  static Future<List<TopWastedItem>> fetchMockTopWastedItems() async {
    await Future.delayed(Duration(seconds: 1));
    final List<dynamic> data = json.decode(topWastedItemsResponse);
    return data.map((json) => TopWastedItem.fromJson(json)).toList();
  }
}
