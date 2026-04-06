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
    final map = <String, dynamic>{
      'serving_date': date,
      'meal_type': mealType,
      'served_count': servedCount,
      'notes': notes,
      'food_wastes': foodWastes.map((w) => w.toJson()).toList(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory MealServing.fromJson(Map<String, dynamic> json) {
    final foodWastes = (json['food_wastes'] as List<dynamic>? ?? [])
        .map((w) => FoodWaste.fromJson(w))
        .toList();
    return MealServing(
      id: json['id'],
      date: json['serving_date'] ?? json['date'] ?? '',
      mealType: json['meal_type'] ?? 'BREAKFAST',
      servedCount: json['served_count'] ?? 0,
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
    final map = <String, dynamic>{
      'food_item_id': foodId,
      'wasted_portions': portions,
      'food_item': foodItem.toJson(),
    };
    if (id != null) map['id'] = id;
    if (mealServingId != null) map['meal_serving_id'] = mealServingId;
    return map;
  }

  factory FoodWaste.fromJson(Map<String, dynamic> json) {
    // Handle case where food_item might not be included in response
    final foodItem = json['food_item'] != null
        ? FoodItem.fromJson(json['food_item'])
        : FoodItem(
            id: json['food_item_id'] ?? json['food_id'],
            name: 'Unknown',
            costPerPortion: 0.0,
            mealType: 'BREAKFAST',
          );
    return FoodWaste(
      id: json['id'],
      mealServingId: json['meal_serving_id'],
      foodId: json['food_item_id'] ?? json['food_id'] ?? foodItem.id ?? 0,
      portions: json['wasted_portions'] ?? json['portions'] ?? 0,
      foodItem: foodItem,
    );
  }
}

// API service functions
class MealServingService {
  static String baseUrl = AppConfig.campusFoodWasteBffApiUrl;

  static Future<List<MealServing>> fetchMealServings({
    int organizationId = 2,
    int offset = 0,
    int limit = 100,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      final endpoint = '$baseUrl/meal_servings/organizations/$organizationId';
      final uri = Uri.parse(endpoint);
      final uriWithParams = uri.replace(queryParameters: queryParams);

      final response =
          await http.get(uriWithParams).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Handle both wrapped and direct array responses
        List<dynamic> mealServingsData;
        if (decodedData is Map<String, dynamic>) {
          mealServingsData = decodedData['meal_servings'] ?? [];
        } else if (decodedData is List) {
          mealServingsData = decodedData;
        } else {
          mealServingsData = [];
        }

        final mealServings =
            mealServingsData.map((json) => MealServing.fromJson(json)).toList();
        print('Fetched ${mealServings.length} meal servings');
        return mealServings;
      } else {
        throw Exception('Failed to load meal servings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching meal servings: $e');
      throw Exception('Error fetching meal servings: $e');
    }
  }

  static Future<MealServing> createMealServing(MealServing serving,
      {int organizationId = 2}) async {
    try {
      final Map<String, dynamic> createData = serving.toJson()..remove('id');

      createData['organization_id'] = organizationId;
      createData['meal_type'] = serving.mealType.toLowerCase();

      if (createData.containsKey('food_wastes')) {
        createData['food_wastes'] =
            (createData['food_wastes'] as List).map((fw) {
          final cleanFw = Map<String, dynamic>.from(fw as Map);
          cleanFw.remove('food_item');
          cleanFw.remove('meal_serving_id');
          return cleanFw;
        }).toList();
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/meal_servings'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(createData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Handle wrapper if present
        final Map<String, dynamic> itemData = data['meal_serving'] ?? data;
        final createdItem = MealServing.fromJson(itemData);

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

  static Future<void> updateMealServing(MealServing serving) async {
    try {
      final updateData = serving.toJson()..remove('id');

      if (updateData.containsKey('food_wastes')) {
        updateData['food_wastes'] =
            (updateData['food_wastes'] as List).map((fw) {
          final cleanFw = Map<String, dynamic>.from(fw as Map);
          cleanFw.remove('food_item');
          cleanFw.remove('meal_serving_id');
          return cleanFw;
        }).toList();
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/meal_servings/${serving.id}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(updateData),
          )
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .delete(
            Uri.parse('$baseUrl/meal_servings/$id'),
          )
          .timeout(const Duration(seconds: 10));

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
}
