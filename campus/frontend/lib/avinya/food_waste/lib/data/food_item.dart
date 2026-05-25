import 'dart:convert';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;

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
    final data = {
      'id': id,
      'name': name,
      'cost_per_portion': costPerPortion,
      'meal_type': mealType,
    };
    if (createdAt != null) data['created'] = createdAt;
    if (updatedAt != null) data['updated'] = updatedAt;
    return data;
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      costPerPortion: (json['cost_per_portion'] ?? 0.0).toDouble(),
      mealType: json['meal_type'] ?? 'Breakfast',
      createdAt: json['created'] ?? json['created_at'],
      updatedAt: json['updated'] ?? json['updated_at'],
    );
  }
}

// API service functions
class FoodItemService {
  static String baseUrl = AppConfig.campusFoodWasteBffApiUrl;

  static Future<List<FoodItem>> fetchFoodItems(String mealType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food_items?meal_type=$mealType'),
        headers: {'Authorization': 'Bearer ' + AppConfig.campusBffApiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['food_items'] ?? [];
        final foodItems = items.map((json) => FoodItem.fromJson(json)).toList();
        print('Successfully fetched $mealType items: ${foodItems.length}');
        return foodItems;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to load $mealType items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $mealType items: $e');
    }
  }

  static Future<FoodItem> createFoodItem(FoodItem item) async {
    try {
      final createData = item.toJson()
        ..remove('id')
        ..remove('created')
        ..remove('updated');

      final response = await http.post(
        Uri.parse('$baseUrl/food_items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
        },
        body: json.encode(createData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Handle wrapped response or direct response
        final Map<String, dynamic> data =
            responseData['food_item'] ?? responseData;
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
      if (item.id == null) {
        throw Exception('Cannot update food item without an ID');
      }

      final updateData = {
        'name': item.name,
        'cost_per_portion': item.costPerPortion,
        'meal_type': item.mealType,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/food_items/${item.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
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
      final response = await http.delete(
        Uri.parse('$baseUrl/food_items/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + AppConfig.campusBffApiKey,
        },
      ).timeout(const Duration(seconds: 10));

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
}
