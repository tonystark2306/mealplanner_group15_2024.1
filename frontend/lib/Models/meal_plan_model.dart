class MealPlan {
  final String id; // ID duy nhất cho mỗi bữa ăn
  final String mealTime; // Bữa sáng, trưa, tối
  final String dish; // Món ăn
  final DateTime date; // Ngày của bữa ăn

  MealPlan({
    required this.id,
    required this.mealTime,
    required this.dish,
    required this.date,
  });

  // Phương thức kiểm tra tính hợp lệ
  bool validate() {
    return mealTime.isNotEmpty && dish.isNotEmpty;
  }

  // Phương thức sao chép đối tượng với giá trị mới
  MealPlan copyWith({
    String? id,
    String? mealTime,
    String? dish,
    DateTime? date,
  }) {
    return MealPlan(
      id: id ?? this.id,
      mealTime: mealTime ?? this.mealTime,
      dish: dish ?? this.dish,
      date: date ?? this.date,
    );
  }

  // Phương thức chuyển đổi đối tượng từ Map
  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      mealTime: map['mealTime'],
      dish: map['dish'],
      date: DateTime.parse(map['date']),
    );
  }

  // Phương thức chuyển đổi đối tượng thành Map để lưu trữ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealTime': mealTime,
      'dish': dish,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MealPlan(id: $id, mealTime: $mealTime, dish: $dish, date: $date)';
  }
}
