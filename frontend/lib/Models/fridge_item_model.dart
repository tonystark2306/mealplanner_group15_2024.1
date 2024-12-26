// FILE: models/food_item_model.dart

class FridgeItem {
  final String id;
  final String name;
  final DateTime expirationDate; 
  final int quantity; 
  final String unit; 
  final String image;
  final String type;
  final String category;
  final String notes;

  FridgeItem({
    required this.id,
    required this.name,
    required this.expirationDate,
    required this.quantity, // Include quantity in the constructor
    required this.unit,
    this.image = '',
    required this.type,
    required this.category,
    required this.notes,
  });

  // Optional: Add a factory constructor if you need to parse from JSON
  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    return FridgeItem(
      id: json['id'],
      name: json['Food']['name'], // Lấy name từ Food
      expirationDate: DateTime.parse(json['expiration_date']),
      quantity: int.tryParse(json['quantity'].toString().split('.')[0]) ?? 0,
      unit: json['unit'],
    );
  }

  // Optional: Add toJson method if needed for API calls
  Map<String, dynamic> toJson() {
    return {
      'itemId': id,
      'newFoodName': name,
      'newExpiration_date': expirationDate.toIso8601String(),
      'newQuantity': quantity, // Include quantity in the JSON representation
    };
  }
}
