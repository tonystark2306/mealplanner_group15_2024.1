import 'package:flutter/material.dart';
import '../Models/meal_plan_model.dart';

class MealPlanningProvider with ChangeNotifier {
  // Danh sách các bữa ăn
  List<MealPlan> _mealPlans = [];

  List<MealPlan> get mealPlans => List.unmodifiable(_mealPlans);

  // Thêm một bữa ăn vào danh sách
  void addMealPlan(MealPlan mealPlan) {
    if (mealPlan.validate()) {
      _mealPlans.add(mealPlan);
      notifyListeners(); // Thông báo UI cập nhật
    } else {
      throw Exception('MealPlan không hợp lệ.');
    }
  }

  // Cập nhật một bữa ăn
  void updateMealPlan(MealPlan updatedMealPlan) {
    final index = _mealPlans.indexWhere((meal) => meal.id == updatedMealPlan.id);
    if (index != -1) {
      _mealPlans[index] = updatedMealPlan;
      notifyListeners(); // Thông báo UI cập nhật
    } else {
      throw Exception('Không tìm thấy MealPlan để cập nhật.');
    }
  }

  // Xóa bữa ăn theo ID
  void deleteMealPlan(String id) {
    final initialLength = _mealPlans.length;
    _mealPlans.removeWhere((meal) => meal.id == id);
    if (_mealPlans.length < initialLength) {
      notifyListeners(); // Thông báo UI cập nhật
    } else {
      throw Exception('Không tìm thấy MealPlan để xóa.');
    }
  }

  // Xóa toàn bộ bữa ăn của một ngày
  void deleteMealPlansByDate(DateTime date) {
    _mealPlans.removeWhere((meal) => meal.date.isSameDay(date));
    notifyListeners();
  }

  // Tải danh sách các bữa ăn từ nguồn dữ liệu (ví dụ từ API)
  void loadMealPlans(List<MealPlan> mealPlans) {
    _mealPlans = mealPlans.where((meal) => meal.validate()).toList();
    notifyListeners(); // Thông báo UI cập nhật
  }

  // Lấy bữa ăn của một ngày cụ thể
  List<MealPlan> getMealPlansByDate(DateTime date) {
    return _mealPlans.where((meal) => meal.date.isSameDay(date)).toList();
  }

  // Lấy toàn bộ bữa ăn (tuỳ chọn: dùng cho debug hoặc hiển thị toàn bộ)
  List<MealPlan> getAllMealPlans() {
    return List.unmodifiable(_mealPlans);
  }
}

extension DateTimeComparison on DateTime {
  // Phương thức mở rộng để so sánh ngày (không tính giờ, phút, giây)
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
