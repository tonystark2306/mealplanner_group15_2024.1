// FILE: models/food_item_model.dart

class FridgeItem {
  final String id;
  final String name;
  final DateTime expirationDate; 
  final int quantity; 
  final String unit; 
  final String image;
  final String type;
  final List<String> category;
  final String notes;

  FridgeItem({
    required this.id,
    required this.name,
    required this.expirationDate,
    required this.quantity, // Include quantity in the constructor
    this.unit = '',
    this.image = '',
    this.type = '',
    this.category = const [],
    this.notes = '',
  });

  // Optional: Add a factory constructor to convert JSON to a FridgeItem object
  factory FridgeItem.fromJson(Map<String, dynamic> json) {
  return FridgeItem(
    id: json['id'] ?? '', // Nếu 'id' là null, sử dụng chuỗi rỗng làm giá trị mặc định
    name: json['Food']['name'] ?? '', // Nếu 'name' là null, sử dụng chuỗi rỗng
    expirationDate: DateTime.parse(json['expiration_date'] ?? DateTime.now().toString()), // Nếu 'expiration_date' là null, sử dụng ngày hiện tại
    quantity: int.tryParse(json['quantity'].toString().split('.')[0]) ?? 0, // Sử dụng 0 nếu 'quantity' là null hoặc không thể parse
    unit: json['Food']['Unit']['name'] ?? '', // Nếu 'Unit' hoặc 'name' là null, sử dụng chuỗi rỗng
    image: json['Food']['image_url'] ?? '', // Nếu 'image_url' là null, sử dụng chuỗi rỗng
    type: json['Food']['type'] ?? '', // Nếu 'type' là null, sử dụng chuỗi rỗng
    // Kiểm tra nếu 'Category' là null, nếu không thì xử lý như bình thường
    category: json['Food']['Category'] != null
        ? (json['Food']['Category'] as List<dynamic>)
            .map((item) => item.toString())
            .toList()
        : [], // Nếu 'Category' là null, trả về danh sách rỗng
    notes: json['Food']['note'] ?? '', // Nếu 'notes' là null, sử dụng chuỗi rỗng
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
