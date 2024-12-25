// FILE: models/food_item_model.dart

class FridgeItem {
  final String id;
  final String name;
  final DateTime expirationDate; // Field for expiration date
  final int quantity; // Add this field for quantity

  FridgeItem({
    required this.id,
    required this.name,
    required this.expirationDate,
    required this.quantity, // Include quantity in the constructor
  });

  // Optional: Add a factory constructor if you need to parse from JSON
  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    return FridgeItem(
      id: json['id'],
      name: json['name'],
      expirationDate: DateTime.parse(json['expirationDate']),
      quantity: json['quantity'], // Ensure quantity is parsed correctly
    );
  }

  // Optional: Add toJson method if needed for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expirationDate': expirationDate.toIso8601String(),
      'quantity': quantity, // Include quantity in the JSON representation
    };
  }
}
