import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/meal_plan_model.dart';
import './token_storage.dart';

class MealPlanProvider with ChangeNotifier {
  final String apiBaseUrl = 'http://localhost:5000/api';
  List<MealPlanModel> _mealPlans = [];
  bool _isLoading = false;

  // Getter for mealPlans
  List<MealPlanModel> get mealPlans => [..._mealPlans];
  
  // Getter for loading status
  bool get isLoading => _isLoading;

  // Method to set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch meal plans by date
  Future<void> fetchMealPlansByDate(DateTime date, String groupId) async {
    final formattedDate = date.toIso8601String().split('T')[0];
    final url = Uri.parse('$apiBaseUrl/meal/$groupId?date=$formattedDate');
    Map<String, String> tokenObject = await TokenStorage.getTokens();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}', // Thêm token vào header
        },
      );
      print(response.statusCode);
      print(response.body);
      print("status code ${response.statusCode}");
      if (response.statusCode == 200) {
        // _mealPlans =sampleMealPlans;
        final List<dynamic> data = json.decode(response.body);
        print("data$data");
        _mealPlans = data.map((json) => MealPlanModel.fromJson(json)).toList();
        print("mealPlans$_mealPlans");
        notifyListeners();
      } else {
        throw Exception('Failed to load meal plans');
      }
    } catch (error) {
      print(error);
      rethrow;
      
    }
  }

  // Add a new meal plan
  Future<void> addMealPlan(MealPlanModel mealPlan, String token, String groupId) async {
    final url = Uri.parse('$apiBaseUrl/meal/$groupId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
        body: json.encode(mealPlan.toJson()),
      );
      if (response.statusCode == 201) {
        final newMealPlan = MealPlanModel.fromJson(json.decode(response.body));
        _mealPlans.add(newMealPlan);
        notifyListeners();
      } else {
        throw Exception('Failed to add meal plan');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Update an existing meal plan
  Future<void> updateMealPlan(String id, MealPlanModel updatedMealPlan, String token) async {
    final url = Uri.parse('$apiBaseUrl/meal-plans/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
        body: json.encode(updatedMealPlan.toJson()),
      );
      if (response.statusCode == 200) {
        final index = _mealPlans.indexWhere((meal) => meal.id == id);
        if (index != -1) {
          _mealPlans[index] = updatedMealPlan;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update meal plan');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Delete a meal plan
  Future<void> deleteMealPlan(String id, String token) async {
    final url = Uri.parse('$apiBaseUrl/meal-plans/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
      );
      if (response.statusCode == 200) {
        _mealPlans.removeWhere((meal) => meal.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete meal plan');
      }
    } catch (error) {
      rethrow;
    }
  }

  //Delete a meal plan state
  void deleteMealPlanState(String id) {
    _mealPlans.removeWhere((meal) => meal.id == id);
    notifyListeners();
  }
}

List<MealPlanModel> sampleMealPlans = [
  MealPlanModel(
    id: '1',
    name: 'Bữa sáng',
    scheduleTime: DateTime.now().add(Duration(hours: 7)),
    description: 'Bữa sáng nhẹ với bánh mì và trứng.',
    dishes: [
      Dish(
        recipeId: 'dish_1',
        recipeName: 'Bánh mì',
        servings: 2,
      ),
      Dish(
        recipeId: 'dish_2',
        recipeName: 'Trứng chiên',
        servings: 2,
      ),
    ],
  ),
  MealPlanModel(
    id: '2',
    name: 'Bữa trưa',
    scheduleTime: DateTime.now().add(Duration(hours: 12)),
    description: 'Bữa trưa với cơm và rau xào.',
    dishes: [
      Dish(
        recipeId: 'dish_3',
        recipeName: 'Cơm trắng',
        servings: 1,
      ),
      Dish(
        recipeId: 'dish_4',
        recipeName: 'Rau xào',
        servings: 1,
      ),
    ],
  ),
];
