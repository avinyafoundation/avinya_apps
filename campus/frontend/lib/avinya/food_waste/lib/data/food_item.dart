import 'dart:convert';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dummy_data.dart';

class FoodItem {
  final int? id;
  final String name;
  final double costPerPortion;
  final String mealType;
  final String? createdAt;
  final String? updatedAt;

  FoodItem({
    this.id,
    required this.name,
    required this.costPerPortion,
    required this.mealType,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost_per_portion': costPerPortion,
      'meal_type': mealType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      costPerPortion: (json['cost_per_portion'] ?? 0.0).toDouble(),
      mealType: json['meal_type'] ?? 'Breakfast',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// API service functions
class FoodItemService {
  static String baseUrl = AppConfig.campusFoodWasteBffApiUrl;

  static Future<List<FoodItem>> fetchBreakfastItems() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/food_items/breakfast'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final foodItems = data.map((json) => FoodItem.fromJson(json)).toList();
        print('Successfully fetched breakfast items: ${foodItems.length}');
        return foodItems;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to load breakfast items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching breakfast items: $e');
    }
  }

  static Future<List<FoodItem>> fetchLunchItems() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/food_items/lunch'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final foodItems = data.map((json) => FoodItem.fromJson(json)).toList();
        print('Successfully fetched lunch items: ${foodItems.length}');
        return foodItems;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to load lunch items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lunch items: $e');
    }
  }

  static Future<FoodItem> createFoodItem(FoodItem item) async {
    try {
      final createData = item.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      final response = await http.post(
        Uri.parse('$baseUrl/food_items'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(createData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final createdItem = FoodItem.fromJson(data);
        print('Successfully created food item: ${createdItem.name}');
        return createdItem;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to create food item: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error creating food item: $e');
    }
  }

  static Future<void> updateFoodItem(FoodItem item) async {
    try {
      final updateData = item.toJson()
        ..remove('created_at')
        ..remove('updated_at');

      final response = await http.put(
        Uri.parse('$baseUrl/food_items'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully updated food item: ${item.name}');
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to update food item: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while updating: $e');
      throw Exception('Failed to update food item: $e');
    }
  }

  static Future<void> deleteFoodItem(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delete_food_item/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully deleted food item with ID: $id');
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to delete food item: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while deleting: $e');
      throw Exception('Failed to delete food item: $e');
    }
  }

    static Future<List<FoodItem>> fetchMockFoodItems() async {
    await Future.delayed(Duration(seconds: 1));
    final List<dynamic> data = json.decode(foodItemsResponse);
    return data.map((json) => FoodItem.fromJson(json)).toList();
  }

  static Future<List<FoodItem>> fetchMockBreakfastItems() async {
    await Future.delayed(Duration(seconds: 1));
    final List<dynamic> data = json.decode(foodItemsResponse);
    return data
        .map((json) => FoodItem.fromJson(json))
        .where((item) => item.mealType == 'BREAKFAST')
        .toList();
  }

  static Future<List<FoodItem>> fetchMockLunchItems() async {
    await Future.delayed(Duration(seconds: 1));
    final List<dynamic> data = json.decode(foodItemsResponse);
    return data
        .map((json) => FoodItem.fromJson(json))
        .where((item) => item.mealType == 'LUNCH')
        .toList();
  }
  
}
