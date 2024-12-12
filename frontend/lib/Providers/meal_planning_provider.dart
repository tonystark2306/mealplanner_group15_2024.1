// meal_planning_provider.dart
import 'package:flutter/material.dart';
import '../Models/meal_plan_model.dart';

class MealPlanningProvider extends ChangeNotifier {
  final Map<DateTime, List<Meal>> _mealPlans = {};

  // Lấy danh sách món theo ngày và loại bữa ăn
  List<String> getMealsForDateAndType(DateTime date, String mealType) {
    final mealsForDate = _mealPlans[DateTime(date.year, date.month, date.day)] ?? [];
    return mealsForDate
        .where((meal) => meal.type == mealType)
        .map((meal) => meal.name)
        .toList();
  }

  // Cập nhật hoặc thêm món vào kế hoạch bữa ăn
  void updateMealPlan(DateTime date, String mealType, List<String> mealNames) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    _mealPlans[normalizedDate] ??= [];
    _mealPlans[normalizedDate]!.removeWhere((meal) => meal.type == mealType);
    _mealPlans[normalizedDate]!.addAll(
      mealNames.map((name) => Meal(name: name, type: mealType)),
    );

    notifyListeners();
  }

  // Xóa một bữa ăn khỏi kế hoạch
  void removeMeal(DateTime date, String mealType) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    _mealPlans[normalizedDate]?.removeWhere((meal) => meal.type == mealType);
    notifyListeners();
  }
}
