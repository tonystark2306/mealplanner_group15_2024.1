import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/meal_plan/meal_plan_model.dart';
import '../Models/meal_plan/dish_model.dart';
import './token_storage.dart';

class MealPlanProvider with ChangeNotifier {
  final String apiBaseUrl = 'http://localhost:5000/api';
  List<MealPlanModel> _mealPlans = [];
  bool _isLoading = false;
  bool hasFetched = false;

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
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print(response.statusCode);
      print(response.body);
      print("status code ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("data: $data");

        if (data.containsKey('meal_plan')) {
          final List<dynamic> mealPlansData = data['meal_plan'];

          // Xóa dữ liệu cũ trước khi cập nhật
          _mealPlans.clear();

          _mealPlans = mealPlansData
              .map((json) => MealPlanModel.fromJson(json))
              .toList();
          print("mealPlans: $_mealPlans");
          hasFetched = true;
        } else {
          throw Exception('Meal plan not found in response');
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load meal plans');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  //get meal plan by id
  Future<MealPlanModel> getMealPlanById(String id, String groupId) async {
    final url = Uri.parse('$apiBaseUrl/meal/$groupId/$id');
    Map<String, String> tokenObject = await TokenStorage.getTokens();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mealPlan = MealPlanModel.fromJson(data['meal_plan']);
        return mealPlan;
      } else {
        throw Exception('Failed to load meal plan');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  // Fetch all recipes
  Future<List<Dish>> fetchAllRecipes(String groupId) async {
    final url = Uri.parse('$apiBaseUrl/recipe/$groupId');
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recipes = data['recipes'] as List;
        print('recipes: $recipes');
        final dishes =
            recipes.map((recipe) => Dish.fetchdropdown(recipe)).toList();
        for (var dish in dishes) {
          print ('dishid: ${dish.recipeId}');
          print('dishname: ${dish.recipeName}');
          print('dishservings: ${dish.servings}');
        }
        return dishes;
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  // Add a new meal plan
  Future<void> addMealPlan(MealPlanModel mealPlan, String groupId) async {
    final url = Uri.parse('$apiBaseUrl/meal/$groupId');
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print('Adding meal plan...');
    for (var dish in mealPlan.dishes) {
      print('dish: ${dish.recipeId}');
    }

    print(json.encode(mealPlan.toJson()));
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${tokenObject['accessToken']}', // Thêm token vào header
        },
        body: json.encode(mealPlan.toJson()),
      );
      print('response.statusCode: ${response.statusCode}');
      print('response.body: ${response.body}');
      if (response.statusCode == 201) {
        final id = json.decode(response.body)['meal_plan']['id'];
        final newMealPlan = await getMealPlanById(id, groupId);
        _mealPlans.add(newMealPlan);
        notifyListeners();
      } else {
        throw Exception('Failed to add meal plan');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<String> getRecipeId(String groupId, String keyword) async {
    final url =
        Uri.parse('$apiBaseUrl/recipe/$groupId/search?keyword=$keyword');
    Map<String, String> tokenObject = await TokenStorage.getTokens();

    try {
      print('getRecipeId...');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Duyệt qua mảng recipes và tìm kiếm tên món ăn khớp với keyword
        final recipes = data['recipes'] as List;
        final recipe = recipes.firstWhere(
          (recipe) => recipe['dish_name'] == keyword,
          orElse: () => null,
        );

        if (recipe != null) {
          return recipe['id']; // Trả về id của món ăn tìm được
        } else {
          throw Exception('Không tìm thấy món ăn với tên $keyword');
        }
      } else {
        throw Exception('Failed to get recipe id');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  // Update an existing meal plan
  Future<void> updateMealPlan(MealPlanModel mealPlan, String groupId) async {
    final url = Uri.parse('$apiBaseUrl/meal/$groupId');
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print(json.encode(mealPlan.toPutJson()));
    print('Updating meal plan...');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}', // Thêm token vào header
        },
        body: json.encode(mealPlan.toPutJson()),
      );
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final id = json.decode(response.body)['meal_plan']['id'];
        final newMealPlan = await getMealPlanById(id, groupId);
        _mealPlans.removeWhere((plan) => plan.id == mealPlan.id);
        _mealPlans.add(newMealPlan);
        notifyListeners();
      } else {
        throw Exception('Failed to update meal plan');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  // Delete a meal plan
  Future<void> deleteMealPlan(String id, String groupId) async {
    final url = Uri.parse('$apiBaseUrl/meal/$groupId');
    Map<String, String> tokenObject = await TokenStorage.getTokens();
    print('id:$id');
    print('Deleting meal plan...');
    print('json.encode ${json.encode({'meal_id': id})}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenObject['accessToken']}', // Thêm token vào header
        },
        body: json.encode({'meal_id': id}),
      );
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        _mealPlans.removeWhere((meal) => meal.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete meal plan');
      }
    } catch (error) {
      print(error);
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
