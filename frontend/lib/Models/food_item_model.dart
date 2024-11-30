// FILE: models/food_item_model.dart

class FoodItem {
  final String id;
  final String name;
  final int quantity;
  final DateTime expiryDate;

  FoodItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
  });

  // Method to convert a FoodItem object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  // Method to create a FoodItem object from a map
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      expiryDate: DateTime.parse(map['expiryDate']),
    );
  }
}