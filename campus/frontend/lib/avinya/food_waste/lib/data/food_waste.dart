import 'dart:convert';
import 'package:gallery/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'food_item.dart';
import 'dummy_data.dart';

class MealServing {
  final int? id;
  final String date;
  final String mealType;
  final int servedCount;
  final String? notes;
  final List<FoodWaste> foodWastes;

  MealServing({
    this.id,
    required this.date,
    required this.mealType,
    required this.servedCount,
    this.notes,
    this.foodWastes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'meal_type': mealType,
      'served_count': servedCount,
      'notes': notes,
      'food_wastes': foodWastes.map((w) => w.toJson()).toList(),
    };
  }

  factory MealServing.fromJson(Map<String, dynamic> json) {
    final foodWastes = (json['food_wastes'] as List<dynamic>? ?? [])
        .map((w) => FoodWaste.fromJson(w))
        .toList();
    return MealServing(
      id: json['id'],
      date: json['date'],
      mealType: json['meal_type'],
      servedCount: json['served_count'],
      notes: json['notes'],
      foodWastes: foodWastes,
    );
  }
}

class FoodWaste {
  final int? id;
  final int? mealServingId;
  final int foodId;
  final int portions;
  final FoodItem foodItem;

  FoodWaste({
    this.id,
    this.mealServingId,
    required this.foodId,
    required this.portions,
    required this.foodItem,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_serving_id': mealServingId,
      'food_id': foodId,
      'portions': portions,
      'food_item': foodItem.toJson(),
    };
  }

  factory FoodWaste.fromJson(Map<String, dynamic> json) {
    // Handle case where food_item might not be included in response
    final foodItem = json['food_item'] != null
        ? FoodItem.fromJson(json['food_item'])
        : FoodItem(
            id: json['food_id'],
            name: 'Unknown',
            costPerPortion: 0.0,
            mealType: 'BREAKFAST',
          );
    return FoodWaste(
      id: json['id'],
      mealServingId: json['meal_serving_id'],
      foodId: json['food_id'] ?? foodItem.id ?? 0,
      portions: json['portions'],
      foodItem: foodItem,
    );
  }
}

// API service functions
class MealServingService {
  static String baseUrl = AppConfig.campusFoodWasteBffApiUrl;

  static Future<List<MealServing>> fetchMealServings() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/meal_servings'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final mealServings =
            data.map((json) => MealServing.fromJson(json)).toList();
        return mealServings;
      } else {
        throw Exception('Failed to load meal servings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meal servings: $e');
    }
  }

  static Future<MealServing> createMealServing(MealServing serving) async {
    try {
      final createData = serving.toJson()
        ..remove('id')
        ..remove('food_wastes');

      final response = await http.post(
        Uri.parse('$baseUrl/meal_servings'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(createData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final createdItem = MealServing.fromJson(data);
        print('Created meal serving with ID: ${createdItem.id}');
        return createdItem;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to create meal serving: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error creating meal serving: $e');
    }
  }

  static Future<FoodWaste> createFoodWaste(FoodWaste item) async {
    try {
      final createData = item.toJson()
        ..remove('id')
        ..remove('food_item');

      final response = await http.post(
        Uri.parse('$baseUrl/food_waste'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(createData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final createdItem = FoodWaste.fromJson(data);
        print('Created food waste with ID: ${createdItem.id}');
        return createdItem;
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to create food waste: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error creating food waste: $e');
    }
  }

  static Future<void> updateMealServing(MealServing serving) async {
    try {
      final updateData = serving.toJson()..remove('food_wastes');

      final response = await http.put(
        Uri.parse('$baseUrl/meal_servings'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully updated meal serving with ID: ${serving.id}');
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to update meal serving: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while updating meal serving: $e');
      throw Exception('Error updating meal serving: $e');
    }
  }

  static Future<void> deleteMealServing(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delete_meal_serving/$id'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Deleted meal serving with ID: $id');
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to delete meal serving: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error deleting meal serving: $e');
    }
  }

  static Future<void> deleteFoodWaste(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delete_food_waste/$id'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Deleted food waste with ID: $id');
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to delete food waste: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error deleting food waste: $e');
    }
  }

  static Future<MealServing> fetchMealServingById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/meal_serving_by_id/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Fetched meal serving with ID: ${data['id']}');
        return MealServing.fromJson(data);
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception('Failed to load meal serving: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchMealServingById: $e');
      throw Exception('Error fetching meal serving: $e');
    }
  }

  static Future<List<MealServing>> fetchMealServingsByDate(String date) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/meal_serving_by_date/$date'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Parsed ${data.length} meal servings from response');
        return data.map((json) => MealServing.fromJson(json)).toList();
      } else {
        print('API Error: Status ${response.statusCode}');
        throw Exception(
            'Failed to load meal servings by date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchMealServingsByDate: $e');
      throw Exception('Error fetching meal servings by date: $e');
    }
  }

  static fetchMockMealServingsByDate(String date) async {
    await Future.delayed(Duration(seconds: 1));
    final List<dynamic> data = json.decode(mealServingByDateResponse);
    return data.map((json) => MealServing.fromJson(json)).toList();
  }

  static fetchMockMealServingById(int id) async {
    await Future.delayed(Duration(seconds: 1));
    final Map<String, dynamic> data = json.decode(mealServingByIdResponse);
    return MealServing.fromJson(data);
  }

  static Future<List<MealServing>> fetchMockMealServings() async {
    await Future.delayed(const Duration(seconds: 1));
    final List<dynamic> data = json.decode(mealServingsListResponse);
    return data.map((json) => MealServing.fromJson(json)).toList();
  }
}
