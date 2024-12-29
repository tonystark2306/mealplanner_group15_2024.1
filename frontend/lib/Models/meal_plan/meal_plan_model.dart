import './dish_model.dart';
import 'package:intl/intl.dart';
class MealPlanModel {
  final String id;
  final String name;
  final DateTime scheduleTime;
  final String description;
  final List<Dish> dishes;

  MealPlanModel({
    required this.id,
    required this.name,
    required this.scheduleTime,
    required this.description,
    required this.dishes,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'],
      name: json['name'],
      scheduleTime: DateTime.parse(json['schedule_time']),
      description: json['description'],
      dishes: (json['dishes'] as List)
          .map((dish) => Dish.fromJson(dish))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    // Định dạng ngày thành yyyy-MM-dd HH:mm:ss
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(scheduleTime);
    return {

      'name': name,
      'schedule_time': formattedDate,
      'description': description,
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
      'foods': [],
    };
  }

  Map<String, dynamic> toPutJson() {
    // Định dạng ngày thành yyyy-MM-dd HH:mm:ss
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(scheduleTime);
    return {
      'meal_id': id,
      'new_name': name,
      'new_schedule_time': formattedDate,
      'new_description': description,
      'new_dishes': dishes.map((dish) => dish.toJson()).toList(),
      'new_foods': [],
    };
  }

  static List<MealPlanModel> listFromJson(List<dynamic> json) {
    return json.map((e) => MealPlanModel.fromJson(e)).toList();
  }
}

