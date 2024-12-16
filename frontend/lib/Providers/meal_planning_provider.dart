import 'package:flutter/material.dart';
import '../Models/meal_plan_model.dart';

class MealPlanningProvider extends ChangeNotifier {
  // The structure is Map<DateTime, Map<String, List<Meal>>>
  // where the key is the date and the value is a map of meal types and their corresponding meals
  final Map<DateTime, Map<String, List<Meal>>> _mealPlans = {};

  // Get the list of meal names for a specific date and meal type
  List<String> getMealsForDateAndType(DateTime date, String mealType) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final mealsForDate = _mealPlans[normalizedDate]?[mealType] ?? [];
    return mealsForDate.map((meal) => meal.name).toList();
  }

  // Update or add meals for a specific date and meal type
  void updateMealsForDateAndType(DateTime date, String mealType, List<String> updatedMeals) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Initialize the meal plan for the day if not already present
    _mealPlans[normalizedDate] ??= {};

    // Remove existing meals for the specified meal type
    _mealPlans[normalizedDate]![mealType] = [];

    // Add the new meals (mapping each meal name to a Meal object)
    _mealPlans[normalizedDate]![mealType] = updatedMeals
        .map((name) => Meal(name: name, type: mealType))
        .toList();

    notifyListeners();
  }

  // Remove all meals for a specific date and meal type
  void removeMealsForDateAndType(DateTime date, String mealType) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Remove the meals for the given date and meal type
    _mealPlans[normalizedDate]?.remove(mealType);

    notifyListeners();
  }
}
